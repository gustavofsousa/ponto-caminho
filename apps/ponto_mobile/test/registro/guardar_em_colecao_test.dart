import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/colecao/ponto_page.dart';
import 'package:ponto_mobile/registro/banco_registro.dart';
import 'package:ponto_mobile/registro/registro.dart';
import 'package:ponto_motor/ponto_motor.dart';

import '../colecao_de_teste.dart';
import '../montar_tela.dart';
import 'banco_de_teste.dart';

void main() {
  late BancoRegistro banco;
  late RelogioDeTeste relogio;
  late Registro registro;
  final caminho2 = idDe('caminho', 2);
  final caminho81 = idDe('caminho', 81);

  setUp(() {
    banco = abrirBancoDeTela();
    relogio = RelogioDeTeste(DateTime.utc(2026, 3, 12, 9));
    registro = Registro(banco, agora: relogio.call);
  });

  Future<void> prepararColecoes(
    WidgetTester tester,
    List<String> nomes, {
    Map<String, List<PontoId>> pontos = const {},
  }) async => tester.runAsync(
    () => semearColecoes(registro, banco, relogio, nomes, pontos: pontos),
  );

  Future<void> abrirPonto(WidgetTester tester, PontoId id) async {
    await montarTela(
      tester,
      PontoPage(
        colecao: colecaoDeTeste,
        inicial: obterPonto(colecaoDeTeste, id)!,
        origem: OrigemDaLeitura.biblioteca,
      ),
      registro: registro,
    );
    await tester.pumpAndSettle();
  }

  Future<void> abrirGuardar(WidgetTester tester) async {
    await abrirPonto(tester, caminho2);
    await tester.tap(find.text('Guardar em uma coleção'));
    await tester.pumpAndSettle();
  }

  Future<void> digitarNome(WidgetTester tester, String nome) async {
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      nome,
    );
    await tester.pump();
  }

  Finder botaoDoDialogo(String rotulo) => find.descendant(
    of: find.byType(AlertDialog),
    matching: find.widgetWithText(TextButton, rotulo),
  );

  bool habilitado(WidgetTester tester, Finder botao) =>
      tester.widget<TextButton>(botao).onPressed != null;

  bool marcada(WidgetTester tester, String nome) => tester
      .widget<CheckboxListTile>(find.widgetWithText(CheckboxListTile, nome))
      .value!;

  Future<Map<String, List<String>>> guardadas(WidgetTester tester) async =>
      (await tester.runAsync(() => lerColecoesGuardadas(banco)))!;

  testWidgetsComRegistro('COL-01: a collection created from a point holds it', (
    tester,
  ) async {
    await prepararColecoes(tester, []);
    await abrirGuardar(tester);

    await tester.tap(find.text('Nova coleção'));
    await tester.pumpAndSettle();
    await digitarNome(tester, 'Família');
    await tester.tap(botaoDoDialogo('Criar'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(marcada(tester, 'Família'), isTrue);
    expect(await guardadas(tester), {
      'Família': ['$caminho2'],
    });
  });

  testWidgetsComRegistro('COL-02: a point can be kept in several collections', (
    tester,
  ) async {
    await prepararColecoes(tester, ['Família', 'Pontos para reler']);
    await abrirGuardar(tester);
    expect(marcada(tester, 'Família'), isFalse);
    expect(marcada(tester, 'Pontos para reler'), isFalse);

    await tester.tap(find.text('Família'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pontos para reler'));
    await tester.pumpAndSettle();
    expect(marcada(tester, 'Família'), isTrue);
    expect(marcada(tester, 'Pontos para reler'), isTrue);
    expect(await guardadas(tester), {
      'Família': ['$caminho2'],
      'Pontos para reler': ['$caminho2'],
    });

    await tester.tap(find.text('Família'));
    await tester.pumpAndSettle();
    expect(marcada(tester, 'Família'), isFalse);
    expect(await guardadas(tester), {
      'Família': <String>[],
      'Pontos para reler': ['$caminho2'],
    });
  });

  group('COL-03: the name rule in the dialog', () {
    testWidgetsComRegistro('a repeated name is refused with a message', (
      tester,
    ) async {
      await prepararColecoes(tester, ['Família']);
      await abrirGuardar(tester);
      await tester.tap(find.text('Nova coleção'));
      await tester.pumpAndSettle();

      await digitarNome(tester, '  família ');

      expect(find.text('Já existe uma coleção com esse nome.'), findsOneWidget);
      expect(habilitado(tester, botaoDoDialogo('Criar')), isFalse);
    });

    testWidgetsComRegistro('an empty name cannot be confirmed', (tester) async {
      await prepararColecoes(tester, []);
      await abrirGuardar(tester);
      await tester.tap(find.text('Nova coleção'));
      await tester.pumpAndSettle();

      expect(habilitado(tester, botaoDoDialogo('Criar')), isFalse);
      await digitarNome(tester, '   ');
      expect(habilitado(tester, botaoDoDialogo('Criar')), isFalse);
    });

    testWidgetsComRegistro('the field takes at most 60 characters', (
      tester,
    ) async {
      await prepararColecoes(tester, []);
      await abrirGuardar(tester);
      await tester.tap(find.text('Nova coleção'));
      await tester.pumpAndSettle();

      await digitarNome(tester, 'a' * 61);

      final campo = tester.widget<TextField>(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
      );
      expect(campo.controller!.text, 'a' * 60);
    });

    testWidgetsComRegistro('the ends of the name are trimmed', (tester) async {
      await prepararColecoes(tester, []);
      await abrirGuardar(tester);
      await tester.tap(find.text('Nova coleção'));
      await tester.pumpAndSettle();

      await digitarNome(tester, '  Trabalho ');
      await tester.tap(botaoDoDialogo('Criar'));
      await tester.pumpAndSettle();

      expect(await guardadas(tester), {
        'Trabalho': ['$caminho2'],
      });
    });

    testWidgetsComRegistro('Cancelar creates nothing', (tester) async {
      await prepararColecoes(tester, []);
      await abrirGuardar(tester);
      await tester.tap(find.text('Nova coleção'));
      await tester.pumpAndSettle();

      await digitarNome(tester, 'Família');
      await tester.tap(botaoDoDialogo('Cancelar'));
      await tester.pumpAndSettle();

      expect(await guardadas(tester), isEmpty);
    });
  });

  testWidgetsComRegistro(
    'PAG-01: the page names the collections of the point',
    (tester) async {
      await prepararColecoes(
        tester,
        ['Pontos para reler', 'Trabalho', 'Família'],
        pontos: {
          'Família': [caminho2],
          'Pontos para reler': [caminho2],
        },
      );

      await abrirPonto(tester, caminho2);

      expect(
        find.text('Nas coleções: Pontos para reler · Família'),
        findsOneWidget,
      );
    },
  );

  testWidgetsComRegistro('PAG-01: a point in no collection has no such line', (
    tester,
  ) async {
    await prepararColecoes(
      tester,
      ['Família'],
      pontos: {
        'Família': [caminho2],
      },
    );

    await abrirPonto(tester, caminho81);

    expect(find.textContaining('Nas coleções'), findsNothing);
  });

  testWidgetsComRegistro(
    'COL-02: the keep page meets the tap target guidelines',
    (tester) async {
      await prepararColecoes(tester, ['Família', 'Pontos para reler']);
      await abrirGuardar(tester);

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    },
  );
}
