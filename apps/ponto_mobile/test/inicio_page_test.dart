import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/colecao/biblioteca_page.dart';
import 'package:ponto_mobile/inicio_page.dart';

import 'colecao_de_teste.dart';
import 'montar_tela.dart';

void main() {
  testWidgets(
    'INI-01: the home names the collection and leads to the library',
    (tester) async {
      await montarTela(tester, InicioPage(colecao: colecaoDeTeste));

      expect(find.widgetWithText(AppBar, 'Teste'), findsOneWidget);
      expect(find.byTooltip('Preferências de leitura'), findsOneWidget);

      await tester.tap(find.text('Biblioteca'));
      await tester.pumpAndSettle();

      expect(find.byType(BibliotecaPage), findsOneWidget);
      for (final entrada in [
        'Caminho',
        'Sulco',
        'Forja',
        'Favoritos',
        'Coleções',
      ]) {
        expect(find.text(entrada), findsOneWidget, reason: entrada);
      }
    },
  );
}
