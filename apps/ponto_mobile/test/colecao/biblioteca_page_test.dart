import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/colecao/biblioteca_page.dart';
import 'package:ponto_mobile/preferencias/preferencias_page.dart';

import '../colecao_de_teste.dart';
import '../montar_tela.dart';

Future<void> _abrir(WidgetTester tester) =>
    montarTela(tester, BibliotecaPage(colecao: colecaoDeTeste));

void main() {
  testWidgets(
    'LER-01: the works appear in the collection\'s order, not alphabetical',
    (tester) async {
      await _abrir(tester);

      final alturas = [
        for (final obra in ['Caminho', 'Sulco', 'Forja'])
          tester.getTopLeft(find.text(obra)).dy,
      ];
      expect(alturas, orderedEquals([...alturas]..sort()));
    },
  );

  testWidgets('LER-01: tapping a work opens its chapters', (tester) async {
    await _abrir(tester);

    await tester.tap(find.text('Sulco'));
    await tester.pumpAndSettle();

    expect(find.text('Sinceridade'), findsOneWidget);
  });

  testWidgets('PREF-01: reading preferences open from the library', (
    tester,
  ) async {
    await _abrir(tester);

    await tester.tap(find.byTooltip('Preferências de leitura'));
    await tester.pumpAndSettle();

    expect(find.byType(PreferenciasPage), findsOneWidget);
  });
}
