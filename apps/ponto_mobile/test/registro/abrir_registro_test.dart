import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/registro/abrir_registro.dart';
import 'package:ponto_mobile/registro/falha_no_registro.dart';

import '../colecao_de_teste.dart';
import '../infra/cofre_de_teste.dart';

const _segredo = 'silêncio-que-ninguém-lê';

void main() {
  late Directory pasta;
  late File arquivo;
  late List<FlutterErrorDetails> relatos;

  setUp(() async {
    pasta = await Directory.systemTemp.createTemp('registro');
    addTearDown(() => pasta.delete(recursive: true));
    arquivo = File('${pasta.path}/registro.db');

    relatos = [];
    final anterior = FlutterError.onError;
    FlutterError.onError = relatos.add;
    addTearDown(() => FlutterError.onError = anterior);
  });

  /// Abre, guarda uma reflexão e fecha: deixa um registro existente na pasta.
  Future<CofreDeTeste> criarRegistroExistente() async {
    final cofre = CofreDeTeste();
    final registro = (await abrirRegistro(pasta: pasta, cofre: cofre))!;
    await registro.reflexoes.escrever(idDe('caminho', 2), _segredo);
    await registro.fechar();
    return cofre;
  }

  Future<void> esperarArquivoIntacto(Future<void> Function() acao) async {
    final bytes = await arquivo.readAsBytes();
    final modificado = await arquivo.lastModified();

    await acao();

    expect(await arquivo.readAsBytes(), bytes);
    expect(await arquivo.lastModified(), modificado);
  }

  test('CIFRA-01: the first registro is born encrypted', () async {
    await criarRegistroExistente();

    final texto = latin1.decode(await arquivo.readAsBytes());
    expect(texto.contains(latin1.decode(utf8.encode(_segredo))), isFalse);
    expect(texto.contains('SQLite format 3'), isFalse);
  });

  test('CIFRA-03: the key is stored before the file exists', () async {
    final arquivoExistiaAoGravar = <bool>[];
    final cofre = CofreDeTeste(
      aoGravar: () => arquivoExistiaAoGravar.add(arquivo.existsSync()),
    );

    final registro = await abrirRegistro(pasta: pasta, cofre: cofre);
    addTearDown(() => registro?.fechar());

    expect(registro, isNotNull);
    expect(arquivoExistiaAoGravar, [false]);
    expect(arquivo.existsSync(), isTrue);
  });

  test(
    'CIFRA-03: reopening uses the same key and reads what was kept',
    () async {
      final cofre = await criarRegistroExistente();

      final reaberto = (await abrirRegistro(pasta: pasta, cofre: cofre))!;
      addTearDown(reaberto.fechar);

      final reflexoes = await reaberto.reflexoes
          .observar(idDe('caminho', 2))
          .first;
      expect(reflexoes.map((r) => r.texto), [_segredo]);
      expect(cofre.gravadas, hasLength(1));
    },
  );

  test(
    'CIFRA-04: a lost key leaves the registro closed and untouched',
    () async {
      await criarRegistroExistente();
      final cofreVazio = CofreDeTeste();

      await esperarArquivoIntacto(() async {
        expect(await abrirRegistro(pasta: pasta, cofre: cofreVazio), isNull);
      });
      expect(cofreVazio.gravadas, isEmpty);
    },
  );

  test(
    'CIFRA-04: a keystore that fails leaves the registro untouched',
    () async {
      await criarRegistroExistente();
      final cofreQuebrado = CofreDeTeste(
        erroAoLer: PlatformException(code: 'unwrap-key'),
      );

      await esperarArquivoIntacto(() async {
        expect(await abrirRegistro(pasta: pasta, cofre: cofreQuebrado), isNull);
      });
      expect(cofreQuebrado.gravadas, isEmpty);
    },
  );

  test('CIFRA-04: a wrong key leaves the registro untouched', () async {
    await criarRegistroExistente();
    final outraChave = CofreDeTeste(chave: 'd4' * 32);

    await esperarArquivoIntacto(() async {
      expect(await abrirRegistro(pasta: pasta, cofre: outraChave), isNull);
    });
    expect(outraChave.gravadas, isEmpty);
  });

  test('CIFRA-04: the failure is logged by type, never by message', () async {
    final cofre = CofreDeTeste(erroAoLer: StateError('contém $_segredo'));

    expect(await abrirRegistro(pasta: pasta, cofre: cofre), isNull);

    final [relato] = relatos;
    expect(relato.exception, isA<FalhaNoRegistro>());
    final escrito = relato.toString();
    expect(escrito, contains('StateError'));
    expect(escrito, isNot(contains(_segredo)));
  });
}
