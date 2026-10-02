import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/colecao/ponto_page.dart';
import 'package:ponto_mobile/registro/banco_registro.dart';
import 'package:ponto_mobile/registro/editor_de_reflexao_page.dart';
import 'package:ponto_mobile/registro/falha_no_registro.dart';
import 'package:ponto_mobile/registro/registro.dart';
import 'package:ponto_motor/ponto_motor.dart';

import '../colecao_de_teste.dart';
import '../montar_tela.dart';
import 'banco_de_teste.dart';

const _falhaAoGuardar = 'Não foi possível guardar agora. Tente de novo.';

void main() {
  late BancoRegistro banco;
  late RelogioDeTeste relogio;
  late Registro registro;

  setUp(() {
    banco = abrirBancoDeTela();
    relogio = RelogioDeTeste(DateTime(2026, 3, 12, 6, 40).toUtc());
    registro = Registro(banco, agora: relogio.call);
  });

  Future<void> abrirPonto(WidgetTester tester, String obra, int numero) =>
      montarTela(
        tester,
        PontoPage(
          colecao: colecaoDeTeste,
          inicial: obterPonto(colecaoDeTeste, idDe(obra, numero))!,
        ),
        registro: registro,
      );

  Future<void> abrirEditor(WidgetTester tester) async {
    await tester.tap(find.text('Escrever uma reflexão'));
    await tester.pumpAndSettle();
  }

  Finder guardar() => find.widgetWithText(TextButton, 'Guardar');

  bool podeGuardar(WidgetTester tester) =>
      tester.widget<TextButton>(guardar()).onPressed != null;

  Future<List<String>> textosGuardados(WidgetTester tester) async {
    final linhas = await tester.runAsync(
      () => banco.select(banco.reflexoes).get(),
    );
    return [for (final linha in linhas!) linha.texto];
  }

  testWidgetsComRegistro(
    'REF-01: a reflection written on a point shows on its page',
    (tester) async {
      await abrirPonto(tester, 'caminho', 2);
      await abrirEditor(tester);

      await tester.enterText(find.byType(TextField), 'Quero ser útil hoje.');
      await tester.pump();
      await tester.tap(guardar());
      await tester.pumpAndSettle();

      expect(find.byType(EditorDeReflexaoPage), findsNothing);
      expect(find.text('Caminho, capítulo Caráter, ponto 2'), findsOneWidget);
      expect(find.text('Quero ser útil hoje.'), findsOneWidget);
      expect(
        find.text('Escrito em 12 de março de 2026, 6h40.'),
        findsOneWidget,
      );
    },
  );

  testWidgetsComRegistro(
    'REF-01: a double tap on Guardar keeps one reflection',
    (tester) async {
      await abrirPonto(tester, 'caminho', 2);
      await abrirEditor(tester);
      await tester.enterText(find.byType(TextField), 'Quero ser útil hoje.');
      await tester.pump();

      // Dois `tester.tap` seguidos não entregam o segundo toque; chamar o
      // callback duas vezes antes da reconstrução é o toque duplo real.
      final tocarGuardar = tester.widget<TextButton>(guardar()).onPressed!;
      tocarGuardar();
      tocarGuardar();
      await tester.pumpAndSettle();

      expect(await textosGuardados(tester), ['Quero ser útil hoje.']);
      expect(find.text('Caminho, capítulo Caráter, ponto 2'), findsOneWidget);
    },
  );

  testWidgetsComRegistro(
    'REF-02: Guardar stays off until there is text to keep',
    (tester) async {
      await abrirPonto(tester, 'caminho', 2);
      await abrirEditor(tester);
      expect(podeGuardar(tester), isFalse);

      await tester.enterText(find.byType(TextField), '  \n ');
      await tester.pump();
      expect(podeGuardar(tester), isFalse);

      await tester.enterText(find.byType(TextField), '  Com espaços.\n');
      await tester.pump();
      expect(podeGuardar(tester), isTrue);

      await tester.tap(guardar());
      await tester.pumpAndSettle();
      expect(await textosGuardados(tester), ['Com espaços.']);
    },
  );

  testWidgetsComRegistro(
    'REF-06: a point shows only its reflections, oldest first',
    (tester) async {
      await tester.runAsync(() async {
        relogio.agora = DateTime(2026, 4, 20, 7).toUtc();
        await registro.reflexoes.escrever(
          idDe('caminho', 2),
          'Escrita em abril.',
        );
        relogio.agora = DateTime(2026, 3, 12, 6, 40).toUtc();
        await registro.reflexoes.escrever(
          idDe('caminho', 2),
          'Escrita em março.',
        );
        await registro.reflexoes.escrever(
          idDe('caminho', 81),
          'De outro ponto.',
        );
      });

      await abrirPonto(tester, 'caminho', 2);
      await tester.pumpAndSettle();

      final marco = tester.getTopLeft(find.text('Escrita em março.')).dy;
      final abril = tester.getTopLeft(find.text('Escrita em abril.')).dy;
      expect(marco, lessThan(abril));
      expect(
        find.text('Escrito em 12 de março de 2026, 6h40.'),
        findsOneWidget,
      );
      expect(find.text('Escrito em 20 de abril de 2026, 7h.'), findsOneWidget);
      expect(find.text('De outro ponto.'), findsNothing);
    },
  );

  for (final (falha, provocar)
      in <(String, Future<void> Function(BancoRegistro))>[
        (
          'a missing table',
          (banco) => banco.customStatement('DROP TABLE reflexoes'),
        ),
        ('a closed database', (banco) => banco.close()),
      ]) {
    testWidgetsComRegistro(
      'REF-08: a failed save ($falha) keeps the text and says so',
      (tester) async {
        const texto = 'Um texto que só eu leio.';
        await abrirPonto(tester, 'caminho', 2);
        await abrirEditor(tester);
        await tester.enterText(find.byType(TextField), texto);
        await tester.pump();
        await tester.runAsync(() => provocar(banco));

        await tester.tap(guardar());
        await tester.pumpAndSettle();

        expect(find.byType(EditorDeReflexaoPage), findsOneWidget);
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          texto,
        );
        expect(find.text(_falhaAoGuardar), findsOneWidget);
        final relatado = tester.takeException();
        expect(relatado, isA<FalhaNoRegistro>());
        expect(relatado.toString(), isNot(contains(texto)));
      },
    );
  }

  testWidgetsComRegistro(
    'REF-01: page and editor fit 320 px with very large text',
    (tester) async {
      usarTelaEstreita(tester);
      tester.platformDispatcher.textScaleFactorTestValue = 2.6;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.runAsync(
        () => registro.reflexoes.escrever(
          idDe('caminho', 2),
          'Uma reflexão longa o bastante para quebrar em várias linhas numa '
          'tela estreita com o texto muito grande.',
        ),
      );

      await abrirPonto(tester, 'caminho', 2);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final escrever = find.text('Escrever uma reflexão');
      await tester.scrollUntilVisible(escrever, 200);
      await tester.ensureVisible(escrever);
      await tester.pumpAndSettle();
      await abrirEditor(tester);
      expect(tester.takeException(), isNull);
      expect(
        find.text('Deixe aqui um rastro da sua meditação.'),
        findsOneWidget,
      );
    },
  );

  testWidgetsComRegistro(
    'REF-01: a long reflection scrolls in the editor and shows whole on the '
    'page at 320 px with very large text',
    (tester) async {
      usarTelaEstreita(tester);
      tester.platformDispatcher.textScaleFactorTestValue = 2.6;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final longa = List.filled(
        30,
        'Uma linha da meditação que segue.',
      ).join(' ');
      await abrirPonto(tester, 'caminho', 2);
      final escrever = find.text('Escrever uma reflexão');
      await tester.scrollUntilVisible(escrever, 200);
      await tester.ensureVisible(escrever);
      await tester.pumpAndSettle();
      await abrirEditor(tester);

      await tester.enterText(find.byType(TextField), longa);
      await tester.pump();

      expect(tester.takeException(), isNull);
      final lista = find.descendant(
        of: find.byType(EditorDeReflexaoPage),
        matching: find.byType(Scrollable),
      );
      expect(
        tester.state<ScrollableState>(lista.first).position.maxScrollExtent,
        greaterThan(0),
      );

      await tester.tap(guardar());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final guardada = tester.widget<Text>(find.text(longa));
      expect(guardada.maxLines, isNull);
      expect(guardada.overflow, isNot(TextOverflow.ellipsis));
    },
  );
}
