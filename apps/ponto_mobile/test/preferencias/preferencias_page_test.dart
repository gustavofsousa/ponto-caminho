import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/preferencias/preferencias.dart';
import 'package:ponto_mobile/preferencias/preferencias_page.dart';

import '../montar_tela.dart';

void main() {
  testWidgets(
    'PREF-01: choosing Escuro changes the theme and shows it chosen',
    (tester) async {
      final preferencias = await montarTela(tester, const PreferenciasPage());

      await tester.tap(find.text('Escuro'));
      await tester.pump();

      expect(preferencias.value.tema, Tema.escuro);
      expect(
        tester
            .widget<RadioGroup<Tema>>(find.byType(RadioGroup<Tema>))
            .groupValue,
        Tema.escuro,
      );
    },
  );

  testWidgets(
    'PREF-02: choosing Grande changes the text size and shows it chosen',
    (tester) async {
      final preferencias = await montarTela(tester, const PreferenciasPage());

      await tester.tap(find.text('Grande'));
      await tester.pump();

      expect(preferencias.value.tamanhoTexto, TamanhoTexto.grande);
      expect(
        tester
            .widget<RadioGroup<TamanhoTexto>>(
              find.byType(RadioGroup<TamanhoTexto>),
            )
            .groupValue,
        TamanhoTexto.grande,
      );
    },
  );

  testWidgets('PREF-01/02: every option is labelled and fits a 320 px screen', (
    tester,
  ) async {
    usarTelaEstreita(tester);

    await montarTela(tester, const PreferenciasPage());

    for (final rotulo in [
      ...Tema.values.map((t) => t.rotulo),
      ...TamanhoTexto.values.map((t) => t.rotulo),
    ]) {
      expect(find.text(rotulo), findsOneWidget, reason: rotulo);
    }
    expect(tester.takeException(), isNull);
  });
}
