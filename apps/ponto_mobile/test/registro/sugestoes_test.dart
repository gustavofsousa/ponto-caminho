import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/colecao/biblioteca_page.dart';
import 'package:ponto_mobile/colecao/ponto_page.dart';
import 'package:ponto_mobile/registro/banco_registro.dart';
import 'package:ponto_mobile/registro/colecoes_page.dart';
import 'package:ponto_mobile/registro/guardar_em_colecao_page.dart';
import 'package:ponto_mobile/registro/registro.dart';
import 'package:ponto_mobile/registro/sugestoes_page.dart';
import 'package:ponto_motor/ponto_motor.dart';

import '../colecao_de_teste.dart';
import '../montar_tela.dart';
import 'banco_de_teste.dart';

const _pergunta = 'Quer começar com algumas coleções?';
const _sugeridas = [
  'Pontos para reler',
  'Meditação da semana',
  'Vida profissional',
  'Família',
  'Direção espiritual',
  'Preparação para confissão',
  'Virtudes a trabalhar',
];

void main() {
  late BancoRegistro banco;
  late Registro registro;

  setUp(() {
    banco = abrirBancoDeTela();
    registro = Registro(banco);
  });

  Future<void> tocarColecoesNaBiblioteca(WidgetTester tester) async {
    await montarTela(
      tester,
      BibliotecaPage(colecao: colecaoDeTeste),
      registro: registro,
    );
    await tester.tap(find.text('Coleções'));
    await tester.pumpAndSettle();
  }

  Future<void> tocarGuardarNoPonto(WidgetTester tester) async {
    await montarTela(
      tester,
      PontoPage(
        colecao: colecaoDeTeste,
        inicial: obterPonto(colecaoDeTeste, idDe('caminho', 2))!,
        origem: OrigemDaLeitura.biblioteca,
      ),
      registro: registro,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar em uma coleção'));
    await tester.pumpAndSettle();
  }

  bool habilitado(WidgetTester tester, String rotulo) {
    final botao = find.ancestor(
      of: find.text(rotulo),
      matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
    );
    return tester.widget<ButtonStyleButton>(botao).onPressed != null;
  }

  Future<(Map<String, List<String>>, bool)> estado(WidgetTester tester) async =>
      (await tester.runAsync(
        () async => (
          await lerColecoesGuardadas(banco),
          await registro.colecoes.sugestoesRespondidas(),
        ),
      ))!;

  group('SUG-01: the first contact with collections', () {
    testWidgetsComRegistro('from the library offers the seven, none ticked', (
      tester,
    ) async {
      await tocarColecoesNaBiblioteca(tester);

      expect(find.byType(SugestoesPage), findsOneWidget);
      expect(find.text(_pergunta), findsOneWidget);
      final alturas = [
        for (final nome in _sugeridas) tester.getTopLeft(find.text(nome)).dy,
      ];
      expect(alturas, [...alturas]..sort());
      for (final nome in _sugeridas) {
        final caixa = find.widgetWithText(CheckboxListTile, nome);
        expect(tester.widget<CheckboxListTile>(caixa).value, isFalse);
      }
      expect(habilitado(tester, 'Criar'), isFalse);
      expect(habilitado(tester, 'Agora não'), isTrue);
    });

    testWidgetsComRegistro('from a point offers them too', (tester) async {
      await tocarGuardarNoPonto(tester);

      expect(find.byType(SugestoesPage), findsOneWidget);
      expect(find.byType(GuardarEmColecaoPage), findsNothing);
    });

    testWidgetsComRegistro('Criar turns on once a name is ticked', (
      tester,
    ) async {
      await tocarColecoesNaBiblioteca(tester);

      await tester.tap(find.text('Família'));
      await tester.pump();

      expect(habilitado(tester, 'Criar'), isTrue);
    });
  });

  group('SUG-02: creating the chosen ones', () {
    testWidgetsComRegistro('creates them in the suggested order and goes on', (
      tester,
    ) async {
      await tocarColecoesNaBiblioteca(tester);

      await tester.tap(find.text('Família'));
      await tester.tap(find.text('Pontos para reler'));
      await tester.pump();
      await tester.tap(find.text('Criar'));
      await tester.pumpAndSettle();

      expect(find.byType(SugestoesPage), findsNothing);
      expect(find.byType(ColecoesPage), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Pontos para reler')).dy,
        lessThan(tester.getTopLeft(find.text('Família')).dy),
      );
      final (colecoes, respondidas) = await estado(tester);
      expect(colecoes, {
        'Pontos para reler': <String>[],
        'Família': <String>[],
      });
      expect(respondidas, isTrue);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Coleções'));
      await tester.pumpAndSettle();
      expect(find.byType(SugestoesPage), findsNothing);
      expect(find.byType(ColecoesPage), findsOneWidget);
    });

    testWidgetsComRegistro('from a point, goes on to keep the point', (
      tester,
    ) async {
      await tocarGuardarNoPonto(tester);

      await tester.tap(find.text('Família'));
      await tester.pump();
      await tester.tap(find.text('Criar'));
      await tester.pumpAndSettle();

      expect(find.byType(GuardarEmColecaoPage), findsOneWidget);
      expect(find.widgetWithText(CheckboxListTile, 'Família'), findsOneWidget);
    });
  });

  group('SUG-03: declining', () {
    testWidgetsComRegistro('Agora não creates nothing and goes on', (
      tester,
    ) async {
      await tocarColecoesNaBiblioteca(tester);

      await tester.tap(find.text('Família'));
      await tester.pump();
      await tester.tap(find.text('Agora não'));
      await tester.pumpAndSettle();

      expect(find.byType(ColecoesPage), findsOneWidget);
      final (colecoes, respondidas) = await estado(tester);
      expect(colecoes, isEmpty);
      expect(respondidas, isTrue);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Coleções'));
      await tester.pumpAndSettle();
      expect(find.byType(SugestoesPage), findsNothing);
    });

    testWidgetsComRegistro('going back returns and never asks again', (
      tester,
    ) async {
      await tocarColecoesNaBiblioteca(tester);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(SugestoesPage), findsNothing);
      expect(find.byType(ColecoesPage), findsNothing);
      expect(find.byType(BibliotecaPage), findsOneWidget);
      final (colecoes, respondidas) = await estado(tester);
      expect(colecoes, isEmpty);
      expect(respondidas, isTrue);

      await tester.tap(find.text('Coleções'));
      await tester.pumpAndSettle();
      expect(find.byType(SugestoesPage), findsNothing);
      expect(find.byType(ColecoesPage), findsOneWidget);
    });
  });
}
