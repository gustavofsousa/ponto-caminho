import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/colecao/ponto_page.dart';
import 'package:ponto_mobile/registro/banco_registro.dart';
import 'package:ponto_mobile/registro/editor_de_reflexao_page.dart';
import 'package:ponto_mobile/registro/registro.dart';
import 'package:ponto_motor/ponto_motor.dart';

import '../colecao_de_teste.dart';
import '../montar_tela.dart';
import 'banco_de_teste.dart';

const _descartar = 'Descartar o que você escreveu?';

void main() {
  late BancoRegistro banco;
  late Registro registro;

  setUp(() {
    banco = abrirBancoDeTela();
    registro = Registro(banco);
  });

  Future<void> abrirEditorNovo(WidgetTester tester) async {
    await montarTela(
      tester,
      PontoPage(
        colecao: colecaoDeTeste,
        inicial: obterPonto(colecaoDeTeste, idDe('caminho', 2))!,
      ),
      registro: registro,
    );
    await tester.tap(find.text('Escrever uma reflexão'));
    await tester.pumpAndSettle();
  }

  Future<void> escrever(WidgetTester tester, String texto) async {
    await tester.enterText(find.byType(TextField), texto);
    await tester.pump();
  }

  Future<int> reflexoesGuardadas(WidgetTester tester) async =>
      (await tester.runAsync(
        () => banco.select(banco.reflexoes).get(),
      ))!.length;

  group('REF-03: leaving with unsaved text', () {
    testWidgetsComRegistro('asks first, and Continuar escrevendo keeps it', (
      tester,
    ) async {
      await abrirEditorNovo(tester);
      await escrever(tester, 'Ainda pensando.');

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text(_descartar), findsOneWidget);

      await tester.tap(find.text('Continuar escrevendo'));
      await tester.pumpAndSettle();
      expect(find.text(_descartar), findsNothing);
      expect(find.byType(EditorDeReflexaoPage), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Ainda pensando.',
      );
    });

    testWidgetsComRegistro('Descartar leaves without saving', (tester) async {
      await abrirEditorNovo(tester);
      await escrever(tester, 'Ainda pensando.');

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Descartar'));
      await tester.pumpAndSettle();

      expect(find.byType(EditorDeReflexaoPage), findsNothing);
      expect(find.text('Caminho, capítulo Caráter, ponto 2'), findsOneWidget);
      expect(find.text('Ainda pensando.'), findsNothing);
      expect(await reflexoesGuardadas(tester), 0);
    });

    testWidgetsComRegistro('the system back also asks first', (tester) async {
      await abrirEditorNovo(tester);
      await escrever(tester, 'Ainda pensando.');

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text(_descartar), findsOneWidget);
      expect(find.byType(EditorDeReflexaoPage), findsOneWidget);
    });
  });

  group('REF-03: leaving with nothing new', () {
    for (final (caso, texto) in [('empty', ''), ('only spaces', '  \n ')]) {
      testWidgetsComRegistro('$caso text leaves without asking', (
        tester,
      ) async {
        await abrirEditorNovo(tester);
        await escrever(tester, texto);

        await tester.pageBack();
        await tester.pumpAndSettle();

        expect(find.text(_descartar), findsNothing);
        expect(find.byType(EditorDeReflexaoPage), findsNothing);
      });
    }
  });
}
