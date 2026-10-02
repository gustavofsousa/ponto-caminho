import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/colecao/biblioteca_page.dart';
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
  final sulco1 = idDe('sulco', 1);

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

  Future<void> abrirColecoes(WidgetTester tester) async {
    await montarTela(
      tester,
      BibliotecaPage(colecao: colecaoDeTeste),
      registro: registro,
    );
    await tester.tap(find.text('Coleções'));
    await tester.pumpAndSettle();
  }

  Future<void> abrirColecao(WidgetTester tester, String nome) async {
    await abrirColecoes(tester);
    await tester.tap(find.text(nome));
    await tester.pumpAndSettle();
  }

  double altura(WidgetTester tester, String texto) =>
      tester.getTopLeft(find.text(texto)).dy;

  group('COL-04: the list of collections', () {
    testWidgetsComRegistro('comes in creation order with each count', (
      tester,
    ) async {
      await prepararColecoes(
        tester,
        ['Pontos para reler', 'Família', 'Trabalho'],
        pontos: {
          'Pontos para reler': [caminho2, sulco1],
          'Família': [caminho2],
        },
      );

      await abrirColecoes(tester);

      expect(
        altura(tester, 'Pontos para reler'),
        lessThan(altura(tester, 'Família')),
      );
      expect(altura(tester, 'Família'), lessThan(altura(tester, 'Trabalho')));
      final contagens = {
        'Pontos para reler': '2 pontos',
        'Família': '1 ponto',
        'Trabalho': 'Nenhum ponto',
      };
      for (final MapEntry(key: nome, value: contagem) in contagens.entries) {
        expect(
          find.descendant(
            of: find.widgetWithText(ListTile, nome),
            matching: find.text(contagem),
          ),
          findsOneWidget,
          reason: '$nome deveria mostrar "$contagem"',
        );
      }
      expect(find.text('Nova coleção'), findsOneWidget);
    });

    testWidgetsComRegistro('Nova coleção adds an empty collection at the end', (
      tester,
    ) async {
      await prepararColecoes(tester, ['Família']);
      await abrirColecoes(tester);

      await tester.tap(find.text('Nova coleção'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
        'Amigos',
      );
      await tester.pump();
      await tester.tap(find.widgetWithText(TextButton, 'Criar'));
      await tester.pumpAndSettle();

      expect(altura(tester, 'Família'), lessThan(altura(tester, 'Amigos')));
      expect(await tester.runAsync(() => lerColecoesGuardadas(banco)), {
        'Família': <String>[],
        'Amigos': <String>[],
      });
    });

    testWidgetsComRegistro('with no collection, invites to create one', (
      tester,
    ) async {
      await prepararColecoes(tester, []);

      await abrirColecoes(tester);

      expect(
        find.text(
          'Crie uma coleção para reunir pontos sobre o que você quiser trabalhar.',
        ),
        findsOneWidget,
      );
      expect(find.text('Nova coleção'), findsOneWidget);
    });
  });

  group('COL-05: the points of a collection', () {
    testWidgetsComRegistro('come latest first, with reference and text', (
      tester,
    ) async {
      await prepararColecoes(
        tester,
        ['Pontos para reler', 'Família'],
        pontos: {
          'Pontos para reler': [caminho2, sulco1],
          'Família': [idDe('caminho', 81)],
        },
      );

      await abrirColecao(tester, 'Pontos para reler');

      final sulco = 'Sulco, capítulo Sinceridade, ponto 1';
      final carater = 'Caminho, capítulo Caráter, ponto 2';
      expect(altura(tester, sulco), lessThan(altura(tester, carater)));
      expect(find.text('O único ponto do sulco.'), findsOneWidget);
      expect(find.text('Segundo ponto do caráter.'), findsOneWidget);
      expect(find.text('Caminho, capítulo Oração, ponto 81'), findsNothing);
    });

    testWidgetsComRegistro('a point opens its page', (tester) async {
      await prepararColecoes(
        tester,
        ['Pontos para reler'],
        pontos: {
          'Pontos para reler': [sulco1],
        },
      );
      await abrirColecao(tester, 'Pontos para reler');

      await tester.tap(find.text('Sulco, capítulo Sinceridade, ponto 1'));
      await tester.pumpAndSettle();

      expect(find.byType(PontoPage), findsOneWidget);
      expect(find.text('O único ponto do sulco.'), findsOneWidget);
    });

    testWidgetsComRegistro('an empty collection invites', (tester) async {
      await prepararColecoes(tester, ['Trabalho']);

      await abrirColecao(tester, 'Trabalho');

      expect(
        find.text('Nada aqui ainda. O que você salvar aparece nesta lista.'),
        findsOneWidget,
      );
    });
  });

  Finder noDialogo(Finder alvo) =>
      find.descendant(of: find.byType(AlertDialog), matching: alvo);

  Future<void> escolherNoMenu(WidgetTester tester, String acao) async {
    await tester.tap(find.byTooltip('Mais opções'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(acao));
    await tester.pumpAndSettle();
  }

  group('COL-06: renaming a collection', () {
    testWidgetsComRegistro('shows the new name everywhere, points kept', (
      tester,
    ) async {
      await prepararColecoes(
        tester,
        ['Familia', 'Trabalho'],
        pontos: {
          'Familia': [caminho2],
        },
      );
      await abrirColecao(tester, 'Familia');

      await escolherNoMenu(tester, 'Renomear');
      final campo = noDialogo(find.byType(TextField));
      expect(tester.widget<TextField>(campo).controller!.text, 'Familia');
      await tester.enterText(campo, 'Família');
      await tester.pump();
      await tester.tap(noDialogo(find.widgetWithText(TextButton, 'Renomear')));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Família'), findsOneWidget);
      expect(await tester.runAsync(() => lerColecoesGuardadas(banco)), {
        'Família': ['$caminho2'],
        'Trabalho': <String>[],
      });

      await tester.tap(find.text('Caminho, capítulo Caráter, ponto 2'));
      await tester.pumpAndSettle();
      expect(find.text('Nas coleções: Família'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ListTile, 'Família'), findsOneWidget);
      expect(find.text('Familia'), findsNothing);
    });

    testWidgetsComRegistro('refuses the name of another collection', (
      tester,
    ) async {
      await prepararColecoes(tester, ['Familia', 'Trabalho']);
      await abrirColecao(tester, 'Familia');

      await escolherNoMenu(tester, 'Renomear');
      await tester.enterText(noDialogo(find.byType(TextField)), 'TRABALHO');
      await tester.pump();

      expect(find.text('Já existe uma coleção com esse nome.'), findsOneWidget);
      final renomear = noDialogo(find.widgetWithText(TextButton, 'Renomear'));
      expect(tester.widget<TextButton>(renomear).onPressed, isNull);
    });
  });

  group('COL-07: deleting a collection', () {
    Future<void> prepararTrabalho(WidgetTester tester) async {
      await prepararColecoes(
        tester,
        ['Trabalho', 'Família'],
        pontos: {
          'Trabalho': [caminho2],
          'Família': [caminho2],
        },
      );
      await tester.runAsync(() async {
        await registro.favoritos.favoritar(caminho2);
        await registro.reflexoes.escrever(caminho2, 'Quero ser útil hoje.');
      });
    }

    const pergunta =
        'Excluir a coleção Trabalho? Os pontos e as reflexões continuam.';

    testWidgetsComRegistro('asks first, and Cancelar keeps everything', (
      tester,
    ) async {
      await prepararTrabalho(tester);
      await abrirColecao(tester, 'Trabalho');

      await escolherNoMenu(tester, 'Excluir coleção');
      expect(noDialogo(find.text(pergunta)), findsOneWidget);
      await tester.tap(noDialogo(find.text('Cancelar')));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.widgetWithText(AppBar, 'Trabalho'), findsOneWidget);
      expect(await tester.runAsync(() => lerColecoesGuardadas(banco)), {
        'Trabalho': ['$caminho2'],
        'Família': ['$caminho2'],
      });
    });

    testWidgetsComRegistro('Excluir removes only the collection', (
      tester,
    ) async {
      await prepararTrabalho(tester);
      await abrirColecao(tester, 'Trabalho');

      await escolherNoMenu(tester, 'Excluir coleção');
      await tester.tap(noDialogo(find.text('Excluir')));
      await tester.pumpAndSettle();

      expect(find.text('Coleções'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Trabalho'), findsNothing);
      expect(find.widgetWithText(ListTile, 'Família'), findsOneWidget);
      final (colecoes, favoritos, reflexoes) = (await tester.runAsync(
        () async => (
          await lerColecoesGuardadas(banco),
          await banco.select(banco.favoritos).get(),
          await banco.select(banco.reflexoes).get(),
        ),
      ))!;
      expect(colecoes, {
        'Família': ['$caminho2'],
      });
      expect(favoritos.map((f) => f.pontoId), ['$caminho2']);
      expect(reflexoes.map((r) => r.texto), ['Quero ser útil hoje.']);

      await tester.tap(find.text('Família'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Caminho, capítulo Caráter, ponto 2'));
      await tester.pumpAndSettle();
      expect(find.text('Nas coleções: Família'), findsOneWidget);
      expect(find.textContaining('Trabalho'), findsNothing);
    });
  });
}
