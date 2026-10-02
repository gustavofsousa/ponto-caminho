import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_motor/ponto_motor.dart';
import 'package:ponto_mobile/main.dart';

void main() {
  testWidgets('opens on the first point, read from the bundled livros/', (
    tester,
  ) async {
    // Asset loading is real I/O, so it has to run outside the fake test clock.
    final colecao = await tester.runAsync(
      () => carregarColecao(
        (arquivo) => rootBundle.loadString('assets/livros/$arquivo'),
      ),
    );

    await tester.pumpWidget(PontoApp(colecao: Future.value(colecao!)));
    await tester.pumpAndSettle();

    expect(find.text('Caminho, capítulo Caráter, ponto 1'), findsOneWidget);
    expect(
      find.textContaining('Não deixes que o dia passe sem um rasto.'),
      findsOneWidget,
    );
    expect(find.text('Texto provisório (mock)'), findsOneWidget);
  });
}
