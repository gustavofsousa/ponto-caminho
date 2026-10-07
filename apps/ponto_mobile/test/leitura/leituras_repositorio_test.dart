import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/registro/abrir_registro.dart';
import 'package:ponto_mobile/registro/banco_registro.dart';
import 'package:ponto_mobile/registro/registro.dart';
import 'package:ponto_motor/ponto_motor.dart';

import '../colecao_de_teste.dart';
import '../infra/cofre_de_teste.dart';
import '../registro/banco_de_teste.dart';

void main() {
  late BancoRegistro banco;
  late RelogioDeTeste relogio;
  late Registro registro;
  final a = idDe('caminho', 1);
  final b = idDe('caminho', 2);
  final c = idDe('caminho', 81);
  final d = idDe('caminho', 82);
  final e = idDe('sulco', 1);

  setUp(() {
    banco = abrirBancoDeTeste();
    relogio = RelogioDeTeste(DateTime.utc(2026, 10, 7, 9, 15));
    registro = Registro(banco, agora: relogio.call);
  });

  Future<void> ler(PontoId ponto, OrigemDaLeitura origem) =>
      registro.leituras.registrar(ponto, origem);

  test(
    'LEI-01: a reading keeps the point id, the origin and the time',
    () async {
      await ler(b, OrigemDaLeitura.biblioteca);

      final linha = (await banco.select(banco.leituras).get()).single;
      expect(linha.pontoId, 'ponto:teste/caminho/2');
      expect(linha.origem, OrigemDaLeitura.biblioteca);
      expect(linha.lidoEm, DateTime.utc(2026, 10, 7, 9, 15));
      expect(linha.lidoEm.isUtc, isTrue);
    },
  );

  test('LEI-01: reading the same point again is a new reading', () async {
    await ler(b, OrigemDaLeitura.biblioteca);
    await ler(b, OrigemDaLeitura.biblioteca);

    expect(await banco.select(banco.leituras).get(), hasLength(2));
  });

  test(
    'AGORA-03: recent points are distinct, newest first, any origin',
    () async {
      await ler(a, OrigemDaLeitura.biblioteca);
      await ler(b, OrigemDaLeitura.continuacao);
      await ler(c, OrigemDaLeitura.aleatorio);
      await ler(a, OrigemDaLeitura.favoritos);
      await ler(e, OrigemDaLeitura.colecao);

      expect(await registro.leituras.listarRecentes(limite: 10), [e, a, c, b]);
    },
  );

  test(
    'AGORA-03: recent points stop at the limit, keeping the newest',
    () async {
      final pontos = [
        for (var n = 1; n <= 12; n++) PontoId('teste', 'caminho', n),
      ];
      for (final ponto in pontos) {
        await ler(ponto, OrigemDaLeitura.aleatorio);
      }

      expect(
        await registro.leituras.listarRecentes(limite: 10),
        pontos.reversed.take(10).toList(),
      );
    },
  );

  test(
    'the order is the order of recording, even if the clock goes back',
    () async {
      await ler(a, OrigemDaLeitura.biblioteca);
      relogio.agora = relogio.agora.subtract(const Duration(days: 3));
      await ler(b, OrigemDaLeitura.biblioteca);

      expect(await registro.leituras.listarRecentes(limite: 10), [b, a]);
      expect(
        await registro.leituras.observarLidosEmSequencia(limite: 10).first,
        [b, a],
      );
    },
  );

  test('CONT-01: only readings in sequence say where the reader is', () async {
    await ler(a, OrigemDaLeitura.biblioteca);
    await ler(b, OrigemDaLeitura.continuacao);
    await ler(c, OrigemDaLeitura.aleatorio);
    await ler(d, OrigemDaLeitura.favoritos);
    await ler(e, OrigemDaLeitura.colecao);

    expect(await registro.leituras.observarLidosEmSequencia(limite: 10).first, [
      b,
      a,
    ]);
  });

  test(
    'CONT-01: rereading a point by a detour does not move the place',
    () async {
      await ler(a, OrigemDaLeitura.biblioteca);
      await ler(b, OrigemDaLeitura.biblioteca);
      await ler(a, OrigemDaLeitura.aleatorio);

      expect(
        await registro.leituras.observarLidosEmSequencia(limite: 10).first,
        [b, a],
      );
    },
  );

  test('CONT-01: points in sequence stop at the limit', () async {
    await ler(a, OrigemDaLeitura.biblioteca);
    await ler(b, OrigemDaLeitura.biblioteca);
    await ler(c, OrigemDaLeitura.biblioteca);

    expect(await registro.leituras.observarLidosEmSequencia(limite: 2).first, [
      c,
      b,
    ]);
  });

  test('CONT-02: the place emits again after a new reading', () async {
    final lugares = registro.leituras.observarLidosEmSequencia(limite: 10);
    final esperado = expectLater(
      lugares,
      emitsInOrder([
        <PontoId>[],
        [a],
      ]),
    );

    await pumpEventQueue();
    await ler(a, OrigemDaLeitura.biblioteca);
    await esperado;
  });

  test('a reading with a broken point id is skipped and kept', () async {
    await ler(a, OrigemDaLeitura.biblioteca);
    await banco.customStatement(
      "INSERT INTO leituras (ponto_id, lido_em, origem) "
      "VALUES ('estragado', '2026-10-07T09:16:00.000Z', 'biblioteca')",
    );

    expect(await registro.leituras.listarRecentes(limite: 10), [a]);
    expect(await registro.leituras.observarLidosEmSequencia(limite: 10).first, [
      a,
    ]);
    expect(await banco.select(banco.leituras).get(), hasLength(2));
  });

  test('CONT-03: the place survives closing and reopening the file', () async {
    final pasta = await Directory.systemTemp.createTemp('leituras');
    addTearDown(() => pasta.delete(recursive: true));
    final arquivo = File('${pasta.path}/registro.db');

    final primeiro = BancoRegistro(NativeDatabase(arquivo));
    await Registro(primeiro).leituras.registrar(a, OrigemDaLeitura.biblioteca);
    await Registro(primeiro).leituras.registrar(b, OrigemDaLeitura.biblioteca);
    await primeiro.close();

    final reaberto = BancoRegistro(NativeDatabase(arquivo));
    addTearDown(reaberto.close);
    expect(
      await Registro(
        reaberto,
      ).leituras.observarLidosEmSequencia(limite: 10).first,
      [b, a],
    );
  });

  test('LEI-08: the point read never reaches the file in the clear', () async {
    final pasta = await Directory.systemTemp.createTemp('leituras');
    addTearDown(() => pasta.delete(recursive: true));
    const lido = PontoId('caminho-sulco-forja', 'caminho', 7);

    final cifrado = (await abrirRegistro(pasta: pasta, cofre: CofreDeTeste()))!;
    await cifrado.leituras.registrar(lido, OrigemDaLeitura.biblioteca);
    await cifrado.fechar();

    final bytes = latin1.decode(
      await File('${pasta.path}/registro.db').readAsBytes(),
    );
    expect(bytes.contains(lido.toString()), isFalse);
    expect(bytes.contains('SQLite format 3'), isFalse);
  });
}
