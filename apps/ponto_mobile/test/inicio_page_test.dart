import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/colecao/biblioteca_page.dart';
import 'package:ponto_mobile/inicio_page.dart';
import 'package:ponto_mobile/registro/registro.dart';
import 'package:ponto_motor/ponto_motor.dart';

import 'colecao_de_teste.dart';
import 'montar_tela.dart';
import 'registro/banco_de_teste.dart';

const _referencia = 'Caminho, capítulo Caráter, ponto 2';

/// Tudo o que a tela inicial pode escrever com uma leitura em sequência.
/// Qualquer outro texto — uma falta, uma contagem, uma data — não pertence a
/// ela (regra 4, `tom-de-voz.md` §1).
const _textosPermitidos = {
  'Teste',
  'Continue de onde parou',
  _referencia,
  'Um ponto para agora',
  'Todas as obras',
  'Caminho',
  'Sulco',
  'Biblioteca',
};

void main() {
  Future<Registro> registroQueLeu(WidgetTester tester) async {
    final registro = Registro(abrirBancoDeTela());
    await tester.runAsync(
      () => registro.leituras.registrar(
        idDe('caminho', 2),
        OrigemDaLeitura.biblioteca,
      ),
    );
    return registro;
  }

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

  testWidgetsComRegistro(
    'INI-01: continue, then a point for now, then the library — and nothing else',
    (tester) async {
      await montarTela(
        tester,
        InicioPage(colecao: colecaoDeTeste),
        registro: await registroQueLeu(tester),
      );
      await tester.pumpAndSettle();

      double altura(String texto) => tester.getTopLeft(find.text(texto)).dy;
      expect(
        altura('Continue de onde parou'),
        lessThan(altura('Um ponto para agora')),
      );
      expect(altura('Um ponto para agora'), lessThan(altura('Todas as obras')));
      expect(altura('Todas as obras'), lessThan(altura('Biblioteca')));
      final textos = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? '');
      expect(_textosPermitidos, containsAll(textos));
    },
  );

  testWidgetsComRegistro(
    'INI-03: the home fits 320 px with very large text, reference whole',
    (tester) async {
      usarTelaEstreita(tester);
      tester.platformDispatcher.textScaleFactorTestValue = 2.6;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await montarTela(
        tester,
        InicioPage(colecao: colecaoDeTeste),
        registro: await registroQueLeu(tester),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        tester
            .renderObject<RenderParagraph>(find.text(_referencia))
            .didExceedMaxLines,
        isFalse,
      );
      for (final alvo in [
        find.widgetWithText(ChoiceChip, 'Todas as obras'),
        find.widgetWithText(ChoiceChip, 'Sulco'),
        find.text('Biblioteca'),
      ]) {
        await tester.scrollUntilVisible(alvo, 100);
        await tester.pumpAndSettle();
        expect(alvo.hitTestable(), findsOneWidget, reason: '$alvo');
      }
      expect(tester.takeException(), isNull);
    },
  );
}
