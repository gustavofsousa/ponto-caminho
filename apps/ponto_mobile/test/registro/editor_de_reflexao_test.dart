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
  late RelogioDeTeste relogio;
  late Registro registro;
  final caminho2 = idDe('caminho', 2);

  setUp(() {
    banco = abrirBancoDeTela();
    relogio = RelogioDeTeste(DateTime(2026, 3, 12, 6, 40).toUtc());
    registro = Registro(banco, agora: relogio.call);
  });

  Future<void> abrirPagina(WidgetTester tester) async {
    await montarTela(
      tester,
      PontoPage(
        colecao: colecaoDeTeste,
        inicial: obterPonto(colecaoDeTeste, caminho2)!,
      ),
      registro: registro,
    );
    await tester.pumpAndSettle();
  }

  /// Guarda reflexões no Caminho 2 (às 6h40 de 12/03) e abre a primeira no editor.
  Future<void> abrirEditorDe(WidgetTester tester, List<String> textos) async {
    await tester.runAsync(() async {
      for (final texto in textos) {
        await registro.reflexoes.escrever(caminho2, texto);
      }
    });
    await abrirPagina(tester);
    await tester.tap(find.text(textos.first));
    await tester.pumpAndSettle();
  }

  Finder noDialogo(String texto) =>
      find.descendant(of: find.byType(AlertDialog), matching: find.text(texto));

  Future<List<LinhaDeReflexao>> linhas(WidgetTester tester) async =>
      (await tester.runAsync(() => banco.select(banco.reflexoes).get()))!;

  Future<void> abrirEditorNovo(WidgetTester tester) async {
    await abrirPagina(tester);
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

  group('REF-04: editing a reflection', () {
    testWidgetsComRegistro(
      'opens with its text and keeps when it was written',
      (tester) async {
        await abrirEditorDe(tester, ['Quero ser útil hoje.']);
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          'Quero ser útil hoje.',
        );

        relogio.agora = DateTime(2026, 3, 14, 21, 5).toUtc();
        await escrever(tester, 'Quero ser útil.');
        await tester.tap(find.widgetWithText(TextButton, 'Guardar'));
        await tester.pumpAndSettle();

        expect(find.byType(EditorDeReflexaoPage), findsNothing);
        expect(find.text('Quero ser útil.'), findsOneWidget);
        expect(find.text('Quero ser útil hoje.'), findsNothing);
        expect(
          find.text(
            'Escrito em 12 de março de 2026, 6h40 · '
            'editado em 14 de março de 2026, 21h05.',
          ),
          findsOneWidget,
        );
        expect(await linhas(tester), hasLength(1));
      },
    );

    testWidgetsComRegistro('saving it unchanged records no edit', (
      tester,
    ) async {
      await abrirEditorDe(tester, ['Quero ser útil hoje.']);

      relogio.agora = DateTime(2026, 3, 14, 21, 5).toUtc();
      await tester.tap(find.widgetWithText(TextButton, 'Guardar'));
      await tester.pumpAndSettle();

      expect(
        find.text('Escrito em 12 de março de 2026, 6h40.'),
        findsOneWidget,
      );
      final [linha] = await linhas(tester);
      expect(linha.editadaEm, isNull);
    });

    testWidgetsComRegistro('REF-03: leaving an unchanged edit does not ask', (
      tester,
    ) async {
      await abrirEditorDe(tester, ['Quero ser útil hoje.']);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text(_descartar), findsNothing);
      expect(find.byType(EditorDeReflexaoPage), findsNothing);
    });

    testWidgetsComRegistro('REF-03: leaving a changed edit asks first', (
      tester,
    ) async {
      await abrirEditorDe(tester, ['Quero ser útil hoje.']);
      await escrever(tester, 'Quero ser útil.');

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text(_descartar), findsOneWidget);
    });
  });

  group('REF-05: deleting a reflection', () {
    testWidgetsComRegistro('asks first, and Cancelar keeps it', (tester) async {
      await abrirEditorDe(tester, ['Primeira.', 'Segunda.']);

      await tester.tap(find.widgetWithText(TextButton, 'Excluir'));
      await tester.pumpAndSettle();
      expect(
        noDialogo('Excluir esta reflexão? Não dá para desfazer.'),
        findsOneWidget,
      );

      await tester.tap(noDialogo('Cancelar'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(EditorDeReflexaoPage), findsOneWidget);
      expect((await linhas(tester)).map((l) => l.texto), [
        'Primeira.',
        'Segunda.',
      ]);
    });

    testWidgetsComRegistro('Excluir removes only that reflection', (
      tester,
    ) async {
      await abrirEditorDe(tester, ['Primeira.', 'Segunda.']);

      await tester.tap(find.widgetWithText(TextButton, 'Excluir'));
      await tester.pumpAndSettle();
      await tester.tap(noDialogo('Excluir'));
      await tester.pumpAndSettle();

      expect(find.byType(EditorDeReflexaoPage), findsNothing);
      expect(find.text('Primeira.'), findsNothing);
      expect(find.text('Segunda.'), findsOneWidget);
      expect((await linhas(tester)).map((l) => l.texto), ['Segunda.']);
    });

    testWidgetsComRegistro('a new reflection has nothing to delete', (
      tester,
    ) async {
      await abrirEditorNovo(tester);

      expect(find.widgetWithText(TextButton, 'Excluir'), findsNothing);
    });
  });
}
