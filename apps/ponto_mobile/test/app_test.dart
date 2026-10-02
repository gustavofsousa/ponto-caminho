import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/app.dart';
import 'package:ponto_mobile/colecao/biblioteca_page.dart';
import 'package:ponto_mobile/preferencias/preferencias.dart';
import 'package:ponto_mobile/preferencias/preferencias_repositorio.dart';
import 'package:ponto_motor/ponto_motor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'colecao_de_teste.dart';

/// Abre o app como o `main` abre, com preferências já gravadas e um carregador de livros.
Future<void> _abrirApp(
  WidgetTester tester, {
  Future<Colecao> Function()? carregarLivros,
  Map<String, Object> gravado = const {},
}) async {
  final app = await tester.runAsync(() async {
    SharedPreferences.setMockInitialValues(gravado);
    return abrirApp(
      carregarLivros: carregarLivros ?? () async => colecaoDeTeste,
      repositorio: PreferenciasRepositorio(
        await SharedPreferences.getInstance(),
      ),
    );
  });
  await tester.pumpWidget(app!);
  await tester.pumpAndSettle();
}

Brightness _brilho(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(BibliotecaPage))).brightness;

void main() {
  testWidgets(
    'BASE-05: a load failure shows a humane message, never the exception',
    (tester) async {
      await _abrirApp(
        tester,
        carregarLivros: () async =>
            throw const FormatException('caminho: ponto 3 repetido'),
      );

      expect(
        find.text(
          'Não foi possível abrir os livros. Feche o app e abra de novo.',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('repetido'), findsNothing);
      expect(
        tester.takeException(),
        isA<FormatException>(),
        reason: 'vai para o log',
      );
    },
  );

  testWidgets(
    'BASE-05: any load failure, such as a missing asset, shows the humane message',
    (tester) async {
      await _abrirApp(
        tester,
        carregarLivros: () => carregarColecao(
          (arquivo) =>
              rootBundle.loadString('assets/livros/nao-existe-$arquivo'),
        ),
      );

      expect(
        find.text(
          'Não foi possível abrir os livros. Feche o app e abra de novo.',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('nao-existe'), findsNothing);
      expect(
        tester.takeException(),
        isA<FlutterError>(),
        reason: 'vai para o log',
      );
    },
  );

  testWidgets('LER-01: a successful load opens on the library', (tester) async {
    await _abrirApp(tester);

    expect(find.byType(BibliotecaPage), findsOneWidget);
  });

  testWidgets(
    'BASE-04: the bundled livros/ open through the motor on the library',
    (tester) async {
      await _abrirApp(
        tester,
        carregarLivros: () => carregarColecao(lerLivroEmpacotado),
      );

      for (final obra in ['Caminho', 'Sulco', 'Forja']) {
        expect(find.text(obra), findsOneWidget, reason: obra);
      }
    },
  );

  testWidgets(
    'PREF-01: Escuro paints the app dark and a new choice repaints it',
    (tester) async {
      await _abrirApp(tester, gravado: {'preferencias.tema': 'escuro'});
      expect(_brilho(tester), Brightness.dark);

      await tester.tap(find.byTooltip('Preferências de leitura'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Claro'));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(_brilho(tester), Brightness.light);
    },
  );

  for (final aparelho in Brightness.values) {
    testWidgets('PREF-01: Sistema follows a ${aparelho.name} device', (
      tester,
    ) async {
      tester.platformDispatcher.platformBrightnessTestValue = aparelho;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      await _abrirApp(tester);

      expect(_brilho(tester), aparelho);
    });
  }

  testWidgets('PREF-02: system scale 1.5 times Grande gives 1.725', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await _abrirApp(
      tester,
      gravado: {'preferencias.tamanhoTexto': TamanhoTexto.grande.name},
    );

    final escala = MediaQuery.textScalerOf(
      tester.element(find.byType(BibliotecaPage)),
    );
    expect(escala.scale(10), closeTo(17.25, 1e-9));
  });

  testWidgets('TD-001: invented text is labelled as provisional', (
    tester,
  ) async {
    await _abrirApp(tester);

    await tester.tap(find.text('Caminho'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Caráter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Primeiro ponto do caráter.'));
    await tester.pumpAndSettle();

    expect(find.text('Texto provisório (mock)'), findsOneWidget);
  });

  testWidgets('the Literata license ships with the app', (tester) async {
    registrarLicencas();

    final pacotes = await tester.runAsync(
      () => LicenseRegistry.licenses
          .expand((licenca) => licenca.packages)
          .toList(),
    );

    expect(pacotes, contains('Literata'));
  });
}
