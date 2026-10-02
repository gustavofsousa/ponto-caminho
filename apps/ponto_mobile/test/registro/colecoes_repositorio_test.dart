import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/registro/banco_registro.dart';
import 'package:ponto_mobile/registro/colecoes_repositorio.dart';
import 'package:ponto_mobile/registro/registro.dart';
import 'package:ponto_motor/ponto_motor.dart';

import '../colecao_de_teste.dart';
import 'banco_de_teste.dart';

void main() {
  late BancoRegistro banco;
  late RelogioDeTeste relogio;
  late Registro registro;
  late ColecoesRepositorio colecoes;
  final caminho2 = idDe('caminho', 2);
  final caminho81 = idDe('caminho', 81);
  final sulco1 = idDe('sulco', 1);

  setUp(() {
    banco = abrirBancoDeTeste();
    relogio = RelogioDeTeste(DateTime.utc(2026, 3, 12, 9));
    registro = Registro(banco, agora: relogio.call);
    colecoes = registro.colecoes;
  });

  Future<List<ColecaoPessoal>> atuais() => colecoes.observar().first;

  Future<ColecaoPessoal> chamada(String nome) async =>
      (await atuais()).singleWhere((c) => c.nome == nome);

  Matcher recusadoPor<T extends NomeDeColecao>() => throwsA(
    isA<NomeDeColecaoInvalido>().having((e) => e.motivo, 'motivo', isA<T>()),
  );

  group('criar', () {
    test(
      'COL-01: a collection created from a point already holds it',
      () async {
        await colecoes.criar('Família', comPonto: caminho2);

        final [familia] = await atuais();
        expect(familia.nome, 'Família');
        expect(familia.pontos, [caminho2]);
      },
    );

    test(
      'COL-01: a refused name creates neither the collection nor the link',
      () async {
        await colecoes.criar('Família', comPonto: caminho2);

        await expectLater(
          colecoes.criar('  família ', comPonto: caminho81),
          recusadoPor<NomeRepetido>(),
        );

        final [familia] = await atuais();
        expect(familia.pontos, [caminho2]);
      },
    );

    test('COL-03: the name is stored without the spaces at its ends', () async {
      await colecoes.criar('  Trabalho ');

      expect((await atuais()).map((c) => c.nome), ['Trabalho']);
    });

    test('COL-03: an empty or too long name is refused', () async {
      await expectLater(colecoes.criar('   '), recusadoPor<NomeVazio>());
      await expectLater(colecoes.criar('a' * 61), recusadoPor<NomeLongo>());

      expect(await atuais(), isEmpty);
    });
  });

  group('guardar e tirar', () {
    test('COL-02: one point can be in several collections', () async {
      await colecoes.criar('Família');
      await colecoes.criar('Pontos para reler');
      final familia = await chamada('Família');
      final reler = await chamada('Pontos para reler');

      await colecoes.guardar(familia.id, caminho2);
      await colecoes.guardar(reler.id, caminho2);
      expect((await chamada('Família')).pontos, [caminho2]);
      expect((await chamada('Pontos para reler')).pontos, [caminho2]);

      await colecoes.tirar(familia.id, caminho2);
      expect((await chamada('Família')).pontos, isEmpty);
      expect((await chamada('Pontos para reler')).pontos, [caminho2]);
    });

    test('COL-02: taking one point out keeps the other points', () async {
      await colecoes.criar('Família', comPonto: caminho2);
      final familia = await chamada('Família');
      await colecoes.guardar(familia.id, caminho81);

      await colecoes.tirar(familia.id, caminho2);

      expect((await chamada('Família')).pontos, [caminho81]);
    });

    test(
      'COL-02: keeping a point twice in a collection keeps it once',
      () async {
        await colecoes.criar('Família', comPonto: caminho2);
        final familia = await chamada('Família');

        await colecoes.guardar(familia.id, caminho2);

        expect((await chamada('Família')).pontos, [caminho2]);
      },
    );
  });

  group('observar', () {
    test('COL-04: collections come in the order they were created', () async {
      await colecoes.criar('Pontos para reler');
      relogio.agora = DateTime.utc(2026, 3, 13);
      await colecoes.criar('Família');
      relogio.agora = DateTime.utc(2026, 3, 14);
      await colecoes.criar('Trabalho');

      expect((await atuais()).map((c) => c.nome), [
        'Pontos para reler',
        'Família',
        'Trabalho',
      ]);
    });

    test(
      'COL-04: collections created at the same moment keep their order',
      () async {
        for (final nome in ['Trabalho', 'Família', 'Amigos']) {
          await colecoes.criar(nome);
        }

        expect((await atuais()).map((c) => c.nome), [
          'Trabalho',
          'Família',
          'Amigos',
        ]);
      },
    );

    test('COL-05: the latest kept point of a collection comes first', () async {
      await colecoes.criar('Pontos para reler', comPonto: caminho2);
      final reler = await chamada('Pontos para reler');
      relogio.agora = DateTime.utc(2026, 3, 13);
      await colecoes.guardar(reler.id, sulco1);

      expect((await chamada('Pontos para reler')).pontos, [sulco1, caminho2]);
    });

    test('COL-05: a stored id that is not a PontoId is skipped', () async {
      await colecoes.criar('Família', comPonto: caminho2);
      final familia = await chamada('Família');
      await banco
          .into(banco.pontosDaColecao)
          .insert(
            PontosDaColecaoCompanion.insert(
              colecaoId: familia.id,
              pontoId: 'não é um ponto',
              guardadoEm: relogio.agora,
            ),
          );

      expect((await chamada('Família')).pontos, [caminho2]);
    });
  });

  group('renomear e excluir', () {
    test('COL-06: renaming changes the name and keeps the points', () async {
      await colecoes.criar('Familia', comPonto: caminho2);
      final familia = await chamada('Familia');

      await colecoes.renomear(familia.id, 'Família');

      final [renomeada] = await atuais();
      expect(renomeada.id, familia.id);
      expect(renomeada.nome, 'Família');
      expect(renomeada.pontos, [caminho2]);
    });

    test('COL-06: renaming to another collection name is refused', () async {
      await colecoes.criar('Família');
      await colecoes.criar('Trabalho');
      final trabalho = await chamada('Trabalho');

      await expectLater(
        colecoes.renomear(trabalho.id, 'FAMÍLIA'),
        recusadoPor<NomeRepetido>(),
      );

      expect((await atuais()).map((c) => c.nome), ['Família', 'Trabalho']);
    });

    test(
      'COL-07: deleting a collection keeps points, favourites and reflections',
      () async {
        await colecoes.criar('Trabalho', comPonto: caminho2);
        await colecoes.criar('Família', comPonto: caminho2);
        await registro.favoritos.favoritar(caminho2);
        await registro.reflexoes.escrever(caminho2, 'Quero ser útil hoje.');
        final trabalho = await chamada('Trabalho');

        await colecoes.excluir(trabalho.id);

        final [familia] = await atuais();
        expect(familia.nome, 'Família');
        expect(familia.pontos, [caminho2]);
        expect(await registro.favoritos.observar().first, [caminho2]);
        final reflexoes = await registro.reflexoes.observar(caminho2).first;
        expect(reflexoes.map((r) => r.texto), ['Quero ser útil hoje.']);
        final vinculos = await banco.select(banco.pontosDaColecao).get();
        expect(vinculos.map((v) => v.colecaoId), [familia.id]);
      },
    );
  });

  group('sugestões', () {
    test(
      'SUG-02: answering creates the chosen names in the given order',
      () async {
        expect(await colecoes.sugestoesRespondidas(), isFalse);

        await colecoes.responderSugestoes(['Pontos para reler', 'Família']);

        expect((await atuais()).map((c) => c.nome), [
          'Pontos para reler',
          'Família',
        ]);
        expect(await colecoes.sugestoesRespondidas(), isTrue);
      },
    );

    test(
      'SUG-03: declining creates nothing and still counts as answered',
      () async {
        await colecoes.responderSugestoes([]);

        expect(await atuais(), isEmpty);
        expect(await colecoes.sugestoesRespondidas(), isTrue);
      },
    );

    test(
      'SUG-02: the answer survives closing and reopening the database',
      () async {
        final pasta = await Directory.systemTemp.createTemp('registro');
        addTearDown(() => pasta.delete(recursive: true));
        final arquivo = File('${pasta.path}/registro.db');

        final primeiro = Registro(BancoRegistro(NativeDatabase(arquivo)));
        await primeiro.colecoes.responderSugestoes(['Família']);
        await primeiro.fechar();

        final reaberto = Registro(BancoRegistro(NativeDatabase(arquivo)));
        addTearDown(reaberto.fechar);
        expect(await reaberto.colecoes.sugestoesRespondidas(), isTrue);
        final nomes = (await reaberto.colecoes.observar().first).map(
          (c) => c.nome,
        );
        expect(nomes, ['Família']);
      },
    );
  });
}
