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
  final caminho81 = idDe('caminho', 81);

  setUp(() {
    banco = abrirBancoDeTela();
    relogio = RelogioDeTeste(DateTime.utc(2026, 3, 12, 9));
    registro = Registro(banco, agora: relogio.call);
  });

  Future<List<String>> favoritosGuardados(WidgetTester tester) async {
    final linhas = await tester.runAsync(
      () => banco.select(banco.favoritos).get(),
    );
    return [for (final linha in linhas!) linha.pontoId];
  }

  Future<void> abrirFavoritos(WidgetTester tester) async {
    await montarTela(
      tester,
      BibliotecaPage(colecao: colecaoDeTeste),
      registro: registro,
    );
    await tester.tap(find.text('Favoritos'));
    await tester.pumpAndSettle();
  }

  testWidgetsComRegistro('FAV-01: favouriting on the point page toggles', (
    tester,
  ) async {
    await montarTela(
      tester,
      PontoPage(
        colecao: colecaoDeTeste,
        inicial: obterPonto(colecaoDeTeste, caminho2)!,
      ),
      registro: registro,
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.star_border), findsOneWidget);

    await tester.tap(find.byTooltip('Favoritar'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Remover dos favoritos'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);
    expect(await favoritosGuardados(tester), [caminho2.toString()]);

    await tester.tap(find.byTooltip('Remover dos favoritos'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Favoritar'), findsOneWidget);
    expect(find.byIcon(Icons.star_border), findsOneWidget);
    expect(await favoritosGuardados(tester), isEmpty);
  });

  testWidgetsComRegistro(
    'FAV-01: the point page actions meet the tap target guidelines',
    (tester) async {
      await montarTela(
        tester,
        PontoPage(
          colecao: colecaoDeTeste,
          inicial: obterPonto(colecaoDeTeste, caminho2)!,
        ),
        registro: registro,
      );
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    },
  );

  testWidgetsComRegistro('FAV-02: favourites list the latest first', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await registro.favoritos.favoritar(caminho2);
      relogio.agora = DateTime.utc(2026, 3, 13, 9);
      await registro.favoritos.favoritar(caminho81);
    });

    await abrirFavoritos(tester);

    final oracao = find.text('Caminho, capítulo Oração, ponto 81');
    final carater = find.text('Caminho, capítulo Caráter, ponto 2');
    expect(oracao, findsOneWidget);
    expect(carater, findsOneWidget);
    expect(
      tester.getTopLeft(oracao).dy,
      lessThan(tester.getTopLeft(carater).dy),
    );
    expect(find.text('Primeiro ponto da oração.'), findsOneWidget);
    expect(find.text('Segundo ponto do caráter.'), findsOneWidget);
    expect(find.textContaining('ponto:'), findsNothing);
  });

  testWidgetsComRegistro('FAV-02: a favourite opens its point', (tester) async {
    await tester.runAsync(() => registro.favoritos.favoritar(caminho81));
    await abrirFavoritos(tester);

    await tester.tap(find.text('Caminho, capítulo Oração, ponto 81'));
    await tester.pumpAndSettle();

    expect(find.byType(PontoPage), findsOneWidget);
    expect(find.text('Primeiro ponto da oração.'), findsOneWidget);
  });

  testWidgetsComRegistro('FAV-02: no favourites shows an invitation', (
    tester,
  ) async {
    await abrirFavoritos(tester);

    expect(
      find.text('Os pontos que você favoritar ficam aqui.'),
      findsOneWidget,
    );
  });

  testWidgetsComRegistro('FAV-02: a favourite missing from the books is not '
      'listed', (tester) async {
    await tester.runAsync(() async {
      await registro.favoritos.favoritar(idDe('caminho', 3));
      await registro.favoritos.favoritar(caminho2);
    });

    await abrirFavoritos(tester);

    expect(find.byType(ListTile), findsOneWidget);
    expect(find.text('Caminho, capítulo Caráter, ponto 2'), findsOneWidget);
    expect(await favoritosGuardados(tester), hasLength(2));
  });
}
