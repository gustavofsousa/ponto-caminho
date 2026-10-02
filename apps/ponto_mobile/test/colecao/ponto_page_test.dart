import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/colecao/ponto_page.dart';
import 'package:ponto_mobile/preferencias/preferencias_page.dart';
import 'package:ponto_motor/ponto_motor.dart';

import '../colecao_de_teste.dart';
import '../montar_tela.dart';

Future<void> _abrir(WidgetTester tester, String obra, int numero) => montarTela(
  tester,
  PontoPage(
    colecao: colecaoDeTeste,
    inicial: obterPonto(colecaoDeTeste, idDe(obra, numero))!,
  ),
);

void main() {
  testWidgets(
    'LER-07: Próximo at the end of a chapter opens the next available point',
    (tester) async {
      await _abrir(tester, 'caminho', 2);

      await tester.tap(find.text('Próximo'));
      await tester.pumpAndSettle();

      expect(find.text('Caminho, capítulo Oração, ponto 81'), findsOneWidget);
      expect(find.text('Primeiro ponto da oração.'), findsOneWidget);
    },
  );

  testWidgets('LER-08: Anterior goes back across the chapter gap', (
    tester,
  ) async {
    await _abrir(tester, 'caminho', 81);

    await tester.tap(find.text('Anterior'));
    await tester.pumpAndSettle();

    expect(find.text('Caminho, capítulo Caráter, ponto 2'), findsOneWidget);
    expect(find.text('Segundo ponto do caráter.'), findsOneWidget);
  });

  testWidgets('LER-09: the first point of a work has no Anterior', (
    tester,
  ) async {
    await _abrir(tester, 'caminho', 1);

    expect(find.text('Anterior'), findsNothing);
    expect(find.text('Próximo'), findsOneWidget);
  });

  testWidgets('LER-09: the last point of a work has no Próximo', (
    tester,
  ) async {
    await _abrir(tester, 'caminho', 82);

    expect(find.text('Próximo'), findsNothing);
    expect(find.text('Anterior'), findsOneWidget);
  });

  testWidgets('LER-09: the only point of a work has neither', (tester) async {
    await _abrir(tester, 'sulco', 1);

    expect(find.text('Anterior'), findsNothing);
    expect(find.text('Próximo'), findsNothing);
  });

  testWidgets('LER-07: a new point starts at the top of the page', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 4;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _abrir(tester, 'caminho', 1);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(
      tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position
          .pixels,
      greaterThan(0),
    );

    await tester.tap(find.text('Próximo'));
    await tester.pumpAndSettle();

    expect(
      tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position
          .pixels,
      0,
    );
  });

  testWidgets('TIPO-01: the point text is set in Literata', (tester) async {
    await _abrir(tester, 'caminho', 81);

    final texto = tester.widget<Text>(find.text('Primeiro ponto da oração.'));
    expect(texto.style?.fontFamily, 'Literata');
  });

  testWidgets(
    'LER-06: the reference is a semantic header and big text still fits 320 px',
    (tester) async {
      usarTelaEstreita(tester);
      tester.platformDispatcher.textScaleFactorTestValue = 2.6;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await _abrir(tester, 'caminho', 81);

      expect(
        tester.getSemantics(find.text('Caminho, capítulo Oração, ponto 81')),
        isSemantics(isHeader: true),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('PREF-01: reading preferences open from the point page', (
    tester,
  ) async {
    await _abrir(tester, 'caminho', 81);

    await tester.tap(find.byTooltip('Preferências de leitura'));
    await tester.pumpAndSettle();

    expect(find.byType(PreferenciasPage), findsOneWidget);
  });
}
