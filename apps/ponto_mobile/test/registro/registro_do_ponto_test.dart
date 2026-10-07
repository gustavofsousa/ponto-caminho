import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/colecao/biblioteca_page.dart';
import 'package:ponto_mobile/colecao/ponto_page.dart';
import 'package:ponto_mobile/registro/banco_registro.dart';
import 'package:ponto_mobile/registro/registro.dart';
import 'package:ponto_mobile/registro/sugestoes_page.dart';
import 'package:ponto_motor/ponto_motor.dart';

import '../colecao_de_teste.dart';
import '../montar_tela.dart';
import 'banco_de_teste.dart';

const _indisponivel =
    'Não foi possível abrir o que você guardou. Feche o app e abra de novo.';

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

  Future<void> abrirPonto(
    WidgetTester tester,
    PontoId id, {
    Registro? comRegistro,
  }) async {
    await montarTela(
      tester,
      PontoPage(
        colecao: colecaoDeTeste,
        inicial: obterPonto(colecaoDeTeste, id)!,
        origem: OrigemDaLeitura.biblioteca,
      ),
      registro: comRegistro,
    );
    await tester.pumpAndSettle();
  }

  Future<void> tocar(WidgetTester tester, Finder alvo) async {
    await tester.ensureVisible(alvo);
    await tester.pumpAndSettle();
    await tester.tap(alvo);
    await tester.pumpAndSettle();
  }

  testWidgetsComRegistro('PAG-02: the page shows what changed on coming back', (
    tester,
  ) async {
    await tester.runAsync(
      () => semearColecoes(registro, banco, relogio, ['Família']),
    );
    await abrirPonto(tester, caminho2, comRegistro: registro);

    await tocar(tester, find.text('Escrever uma reflexão'));
    await tester.enterText(find.byType(TextField), 'Sobre o dois.');
    await tester.pump();
    await tocar(tester, find.widgetWithText(TextButton, 'Guardar'));

    await tocar(tester, find.byTooltip('Favoritar'));

    await tocar(tester, find.text('Guardar em uma coleção'));
    await tocar(tester, find.text('Família'));
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Sobre o dois.'), findsOneWidget);
    expect(find.byTooltip('Remover dos favoritos'), findsOneWidget);
    expect(find.text('Nas coleções: Família'), findsOneWidget);

    await tocar(tester, find.text('Sobre o dois.'));
    await tocar(tester, find.widgetWithText(TextButton, 'Excluir'));
    await tocar(
      tester,
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Excluir'),
      ),
    );
    expect(find.text('Sobre o dois.'), findsNothing);
  });

  testWidgetsComRegistro(
    'PAG-02: Próximo brings the registro of the next point',
    (tester) async {
      await tester.runAsync(() async {
        await semearColecoes(
          registro,
          banco,
          relogio,
          ['Família', 'Trabalho'],
          pontos: {
            'Família': [caminho2],
            'Trabalho': [caminho81],
          },
        );
        await registro.favoritos.favoritar(caminho2);
        await registro.reflexoes.escrever(caminho2, 'Sobre o dois.');
        await registro.reflexoes.escrever(caminho81, 'Sobre o oitenta e um.');
      });
      await abrirPonto(tester, caminho2, comRegistro: registro);
      expect(find.text('Sobre o dois.'), findsOneWidget);

      await tester.tap(find.text('Próximo'));
      await tester.pumpAndSettle();

      expect(find.text('Caminho, capítulo Oração, ponto 81'), findsOneWidget);
      expect(find.byTooltip('Favoritar'), findsOneWidget);
      expect(find.byTooltip('Remover dos favoritos'), findsNothing);
      expect(find.text('Nas coleções: Trabalho'), findsOneWidget);
      expect(find.text('Nas coleções: Família'), findsNothing);
      expect(find.text('Sobre o oitenta e um.'), findsOneWidget);
      expect(find.text('Sobre o dois.'), findsNothing);
    },
  );

  group('CIFRA-04: an unavailable registro', () {
    testWidgets('leaves the point readable and says so on the page', (
      tester,
    ) async {
      await abrirPonto(tester, caminho2);

      expect(find.text('Segundo ponto do caráter.'), findsOneWidget);
      expect(find.text(_indisponivel), findsOneWidget);
      expect(find.byTooltip('Favoritar'), findsNothing);
      expect(find.text('Guardar em uma coleção'), findsNothing);
      expect(find.text('Escrever uma reflexão'), findsNothing);
    });

    for (final entrada in ['Favoritos', 'Coleções']) {
      testWidgets('says so in $entrada', (tester) async {
        await montarTela(tester, BibliotecaPage(colecao: colecaoDeTeste));

        await tester.tap(find.text(entrada));
        await tester.pumpAndSettle();

        expect(find.text(_indisponivel), findsOneWidget);
        expect(find.byType(SugestoesPage), findsNothing);
      });
    }
  });

  testWidgetsComRegistro('PAG-02: the page with its registro fits 320 px with '
      'very large text', (tester) async {
    usarTelaEstreita(tester);
    tester.platformDispatcher.textScaleFactorTestValue = 2.6;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.runAsync(() async {
      await semearColecoes(
        registro,
        banco,
        relogio,
        ['Preparação para confissão', 'Virtudes a trabalhar'],
        pontos: {
          'Preparação para confissão': [caminho2],
          'Virtudes a trabalhar': [caminho2],
        },
      );
      await registro.favoritos.favoritar(caminho2);
      await registro.reflexoes.escrever(caminho2, 'Sobre o dois.');
    });

    await abrirPonto(tester, caminho2, comRegistro: registro);
    await tester.scrollUntilVisible(find.text('Sobre o dois.'), 200);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
