import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/colecao/capitulo_page.dart';

import '../colecao_de_teste.dart';
import '../montar_tela.dart';

Future<void> _abrir(WidgetTester tester, int capitulo) {
  final caminho = colecaoDeTeste.obra('caminho')!;
  return montarTela(
    tester,
    CapituloPage(
      colecao: colecaoDeTeste,
      obra: caminho,
      capitulo: caminho.capitulo(capitulo)!,
    ),
  );
}

void main() {
  testWidgets(
    'LER-03: lists only this chapter\'s points, in order, with a short preview',
    (tester) async {
      await _abrir(tester, 3);

      expect(find.text('Oração'), findsOneWidget);
      final p81 = find.text('Primeiro ponto da oração.');
      final p82 = find.text('Segundo ponto da oração.');
      expect(find.text('81'), findsOneWidget);
      expect(find.text('82'), findsOneWidget);
      expect(tester.getTopLeft(p81).dy, lessThan(tester.getTopLeft(p82).dy));
      expect(tester.widget<Text>(p81).maxLines, 2);
      expect(find.text('Segundo ponto do caráter.'), findsNothing);
    },
  );

  testWidgets('LER-04: a chapter with no available points says so calmly', (
    tester,
  ) async {
    await _abrir(tester, 2);

    expect(
      find.text('Os pontos deste capítulo ainda não estão disponíveis.'),
      findsOneWidget,
    );
  });

  testWidgets('LER-05: tapping a point opens that point', (tester) async {
    await _abrir(tester, 3);

    await tester.tap(find.text('Segundo ponto da oração.'));
    await tester.pumpAndSettle();

    expect(find.text('Caminho, capítulo Oração, ponto 82'), findsOneWidget);
  });
}
