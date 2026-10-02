import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/colecao/obra_page.dart';

import '../colecao_de_teste.dart';
import '../montar_tela.dart';

Future<void> _abrir(WidgetTester tester, String obra) => montarTela(
  tester,
  ObraPage(colecao: colecaoDeTeste, obra: colecaoDeTeste.obra(obra)!),
);

void main() {
  testWidgets(
    'LER-02: every chapter in order, with title and editorial count',
    (tester) async {
      await _abrir(tester, 'caminho');

      final titulos = ['Caráter', 'Direção', 'Oração', 'Capítulo 4'];
      final alturas = [
        for (final t in titulos) tester.getTopLeft(find.text(t)).dy,
      ];
      expect(alturas, orderedEquals([...alturas]..sort()));
      expect(find.text('55 pontos'), findsOneWidget);
      expect(
        find.text('25 pontos'),
        findsOneWidget,
        reason: 'Direção, sem pontos disponíveis',
      );
      expect(find.text('37 pontos'), findsOneWidget);
    },
  );

  testWidgets(
    'LER-02: an untitled chapter is named by number and an open range has no count',
    (tester) async {
      await _abrir(tester, 'caminho');

      final capitulo4 = find.ancestor(
        of: find.text('Capítulo 4'),
        matching: find.byType(ListTile),
      );
      expect(capitulo4, findsOneWidget);
      expect(
        find.descendant(of: capitulo4, matching: find.textContaining('ponto')),
        findsNothing,
      );
    },
  );

  testWidgets('LER-02: a one-point chapter reads "1 ponto"', (tester) async {
    await _abrir(tester, 'forja');

    expect(find.text('1 ponto'), findsOneWidget);
  });

  testWidgets('LER-02: tapping a chapter opens it', (tester) async {
    await _abrir(tester, 'caminho');

    await tester.tap(find.text('Oração'));
    await tester.pumpAndSettle();

    expect(find.text('Primeiro ponto da oração.'), findsOneWidget);
  });
}
