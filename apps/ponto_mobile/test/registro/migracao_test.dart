import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/infra/banco_cifrado.dart';
import 'package:ponto_mobile/registro/abrir_registro.dart';
import 'package:ponto_mobile/registro/banco_registro.dart';
import 'package:ponto_mobile/registro/falha_no_registro.dart';
import 'package:ponto_motor/ponto_motor.dart';

import '../infra/cofre_de_teste.dart';
import 'schema_v1.dart';

final _chave = 'ab' * 32;

void main() {
  late Directory pasta;
  late File arquivo;
  late CofreDeTeste cofre;
  late List<FlutterErrorDetails> relatos;

  setUp(() async {
    pasta = await Directory.systemTemp.createTemp('migracao');
    addTearDown(() => pasta.delete(recursive: true));
    arquivo = File('${pasta.path}/registro.db');
    cofre = CofreDeTeste(chave: _chave);

    relatos = [];
    final anterior = FlutterError.onError;
    FlutterError.onError = relatos.add;
    addTearDown(() => FlutterError.onError = anterior);
  });

  test('LEI-06: migrating keeps every row the v0.3 registro kept', () async {
    criarRegistroV1(arquivo, _chave);
    final antes = lerLinhasV1(arquivo, _chave);

    final registro = await abrirRegistro(pasta: pasta, cofre: cofre);
    expect(registro, isNotNull);
    await registro!.fechar();

    expect(lerLinhasV1(arquivo, _chave), antes);
    expect(antes['reflexoes'], hasLength(2));
    expect(lerVersao(arquivo, _chave), 2);
    expect(cofre.gravadas, isEmpty);
    expect(relatos, isEmpty);
    final bytes = latin1.decode(await arquivo.readAsBytes());
    expect(bytes.contains('SQLite format 3'), isFalse);
    expect(bytes.contains('Uma reflexão antiga.'), isFalse);
  });

  test(
    'LEI-06: a migrated registro records and reads back a reading',
    () async {
      criarRegistroV1(arquivo, _chave);
      (await abrirRegistro(pasta: pasta, cofre: cofre))!.fechar();

      final banco = BancoRegistro(abrirBancoCifrado(arquivo, _chave));
      addTearDown(banco.close);
      await banco
          .into(banco.leituras)
          .insert(
            LeiturasCompanion.insert(
              pontoId: 'ponto:teste/caminho/2',
              lidoEm: DateTime.utc(2026, 10, 7, 9, 15),
              origem: OrigemDaLeitura.biblioteca,
            ),
          );

      final lidas = await banco.select(banco.leituras).get();
      expect(lidas.single.pontoId, 'ponto:teste/caminho/2');
      expect(lidas.single.lidoEm, DateTime.utc(2026, 10, 7, 9, 15));
      expect(lidas.single.origem, OrigemDaLeitura.biblioteca);
    },
  );

  test('LEI-06: a migrated schema is the schema of a new registro', () async {
    criarRegistroV1(arquivo, _chave);
    (await abrirRegistro(pasta: pasta, cofre: cofre))!.fechar();

    final novo = BancoRegistro(NativeDatabase.memory());
    addTearDown(novo.close);
    final schemaNovo = await novo
        .customSelect(
          'SELECT sql FROM sqlite_master WHERE sql IS NOT NULL '
          'ORDER BY type DESC, name',
        )
        .map((linha) => linha.read<String>('sql'))
        .get();

    final bruto = abrirBruto(arquivo, _chave);
    addTearDown(bruto.close);
    expect(lerSchema(bruto), schemaNovo);
    expect(schemaNovo, isNot(schemaV1));
  });

  test(
    'LEI-07: a migration that fails leaves the v0.3 file as it was',
    () async {
      // Um índice com o nome da tabela nova faz o CREATE TABLE falhar — mesmo
      // com IF NOT EXISTS, que só ignora tabela ou view já existente.
      criarRegistroV1(
        arquivo,
        _chave,
        alemDoSchema: ['CREATE INDEX leituras ON favoritos (favoritado_em)'],
      );
      final antes = lerLinhasV1(arquivo, _chave);
      final bruto = abrirBruto(arquivo, _chave);
      final schemaAntes = lerSchema(bruto);
      bruto.close();

      final registro = await abrirRegistro(pasta: pasta, cofre: cofre);

      expect(registro, isNull);
      expect(relatos.single.exception, isA<FalhaNoRegistro>());
      expect(lerVersao(arquivo, _chave), 1);
      expect(lerLinhasV1(arquivo, _chave), antes);
      final depois = abrirBruto(arquivo, _chave);
      addTearDown(depois.close);
      expect(lerSchema(depois), schemaAntes);
      expect(cofre.gravadas, isEmpty);
    },
  );
}
