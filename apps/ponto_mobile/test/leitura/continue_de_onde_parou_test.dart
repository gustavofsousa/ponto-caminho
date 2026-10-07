import 'dart:io';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/colecao/ponto_page.dart';
import 'package:ponto_mobile/inicio_page.dart';
import 'package:ponto_mobile/registro/banco_registro.dart';
import 'package:ponto_mobile/registro/falha_no_registro.dart';
import 'package:ponto_mobile/registro/registro.dart';
import 'package:ponto_motor/ponto_motor.dart';

import '../colecao_de_teste.dart';
import '../montar_tela.dart';
import '../registro/banco_de_teste.dart';

const _continue = 'Continue de onde parou';

/// Tudo o que a tela inicial pode escrever. Qualquer outro texto — uma falta,
/// uma contagem, uma data — não pertence a ela (regra 4, `tom-de-voz.md` §1).
const _textosDaTelaInicial = {
  'Teste',
  _continue,
  'Um ponto para agora',
  'Todas as obras',
  'Caminho',
  'Sulco',
  'Biblioteca',
};

void main() {
  late BancoRegistro banco;
  late Registro registro;
  final caminho1 = idDe('caminho', 1);
  final caminho2 = idDe('caminho', 2);
  final caminho81 = idDe('caminho', 81);
  final caminho82 = idDe('caminho', 82);
  final sulco1 = idDe('sulco', 1);
  const referencia2 = 'Caminho, capítulo Caráter, ponto 2';

  setUp(() {
    banco = abrirBancoDeTela();
    registro = Registro(banco);
  });

  Future<void> ler(
    WidgetTester tester,
    List<(PontoId, OrigemDaLeitura)> leituras, {
    Registro? em,
  }) => tester.runAsync(() async {
    for (final (ponto, origem) in leituras) {
      await (em ?? registro).leituras.registrar(ponto, origem);
    }
  });

  Future<void> abrirInicio(WidgetTester tester, {Registro? com}) async {
    await montarTela(
      tester,
      InicioPage(colecao: colecaoDeTeste),
      registro: com,
    );
    await tester.pumpAndSettle();
  }

  Iterable<String> textosNaTela(WidgetTester tester) => tester
      .widgetList<Text>(find.byType(Text))
      .map((texto) => texto.data ?? '');

  testWidgetsComRegistro(
    'CONT-01: continue shows and opens the last point read in sequence',
    (tester) async {
      await ler(tester, [
        (caminho1, OrigemDaLeitura.biblioteca),
        (caminho2, OrigemDaLeitura.biblioteca),
        (caminho81, OrigemDaLeitura.aleatorio),
        (sulco1, OrigemDaLeitura.favoritos),
        (caminho82, OrigemDaLeitura.colecao),
      ]);
      await abrirInicio(tester, com: registro);

      expect(find.text(_continue), findsOneWidget);
      expect(find.text(referencia2), findsOneWidget);
      expect(textosNaTela(tester), isNot(contains(contains('ponto 81'))));
      expect(textosNaTela(tester), isNot(contains(contains('ponto 82'))));
      expect(textosNaTela(tester), isNot(contains(contains('Sulco,'))));

      await tester.tap(find.text(_continue));
      await tester.pumpAndSettle();

      expect(find.byType(PontoPage), findsOneWidget);
      expect(find.text(referencia2), findsOneWidget);
      expect(find.text('Segundo ponto do caráter.'), findsOneWidget);
    },
  );

  testWidgetsComRegistro('LEI-02: a point opened by continue says so', (
    tester,
  ) async {
    await ler(tester, [(caminho2, OrigemDaLeitura.biblioteca)]);
    await abrirInicio(tester, com: registro);

    await tester.tap(find.text(_continue));
    await tester.pumpAndSettle();

    final ultima = await tester.runAsync(
      () =>
          (banco.select(banco.leituras)
                ..orderBy([(l) => OrderingTerm.desc(l.id)])
                ..limit(1))
              .getSingle(),
    );
    expect(ultima!.pontoId, caminho2.toString());
    expect(ultima.origem, OrigemDaLeitura.continuacao);
  });

  testWidgetsComRegistro(
    'CONT-02: continue follows the reading without reopening the app',
    (tester) async {
      await ler(tester, [(caminho2, OrigemDaLeitura.biblioteca)]);
      await abrirInicio(tester, com: registro);

      await tester.tap(find.text(_continue));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Próximo'));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(InicioPage), findsOneWidget);
      expect(find.text('Caminho, capítulo Oração, ponto 81'), findsOneWidget);
      expect(find.text(referencia2), findsNothing);
    },
  );

  testWidgetsComRegistro('CONT-03: continue survives closing the app', (
    tester,
  ) async {
    final pasta = (await tester.runAsync(
      () => Directory.systemTemp.createTemp('continue'),
    ))!;
    addTearDown(() => pasta.delete(recursive: true));
    final arquivo = File('${pasta.path}/registro.db');
    await tester.runAsync(() async {
      final antes = BancoRegistro(NativeDatabase(arquivo));
      await Registro(
        antes,
      ).leituras.registrar(caminho2, OrigemDaLeitura.biblioteca);
      await antes.close();
    });

    await abrirInicio(
      tester,
      com: Registro(BancoRegistro(NativeDatabase(arquivo))),
    );

    expect(find.text(_continue), findsOneWidget);
    expect(find.text(referencia2), findsOneWidget);
  });

  for (final (caso, leituras) in <(String, List<(PontoId, OrigemDaLeitura)>)>[
    ('nothing read', []),
    (
      'only detours',
      [
        (caminho1, OrigemDaLeitura.aleatorio),
        (caminho2, OrigemDaLeitura.favoritos),
        (sulco1, OrigemDaLeitura.colecao),
      ],
    ),
  ]) {
    testWidgetsComRegistro(
      'CONT-04: with $caso in sequence, continue is not there',
      (tester) async {
        await ler(tester, leituras);
        await abrirInicio(tester, com: registro);

        expect(find.text(_continue), findsNothing);
        expect(find.text('Um ponto para agora'), findsOneWidget);
        expect(find.text('Biblioteca'), findsOneWidget);
        expect(_textosDaTelaInicial, containsAll(textosNaTela(tester)));
      },
    );
  }

  testWidgetsComRegistro(
    'CONT-05: a point missing from the books is skipped, not deleted',
    (tester) async {
      await ler(tester, [
        (caminho2, OrigemDaLeitura.biblioteca),
        (idDe('caminho', 999), OrigemDaLeitura.biblioteca),
      ]);
      await abrirInicio(tester, com: registro);

      expect(find.text(referencia2), findsOneWidget);
      final guardadas = await tester.runAsync(
        () => banco.select(banco.leituras).get(),
      );
      expect(guardadas!.map((l) => l.pontoId), [
        caminho2.toString(),
        idDe('caminho', 999).toString(),
      ]);
    },
  );

  testWidgets('CONT-06: without a registro, continue is gone with no warning', (
    tester,
  ) async {
    await abrirInicio(tester);

    expect(find.text(_continue), findsNothing);
    expect(find.text('Biblioteca'), findsOneWidget);
    expect(find.textContaining('Não foi possível'), findsNothing);
    expect(_textosDaTelaInicial, containsAll(textosNaTela(tester)));
  });

  testWidgetsComRegistro(
    'CONT-06: a registro that fails to answer hides continue and logs the type',
    (tester) async {
      await ler(tester, [(caminho2, OrigemDaLeitura.biblioteca)]);
      await tester.runAsync(() => banco.customStatement('DROP TABLE leituras'));

      await abrirInicio(tester, com: registro);

      expect(find.text(_continue), findsNothing);
      expect(find.text('Biblioteca'), findsOneWidget);
      final relatado = tester.takeException();
      expect(relatado, isA<FalhaNoRegistro>());
      expect(relatado.toString(), isNot(contains('leituras')));
    },
  );
}
