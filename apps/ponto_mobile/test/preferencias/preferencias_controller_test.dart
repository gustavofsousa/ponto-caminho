import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/preferencias/preferencias.dart';
import 'package:ponto_mobile/preferencias/preferencias_controller.dart';
import 'package:ponto_mobile/preferencias/preferencias_repositorio.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<(PreferenciasController, PreferenciasRepositorio)> _controller() async {
  SharedPreferences.setMockInitialValues({});
  final repositorio = PreferenciasRepositorio(
    await SharedPreferences.getInstance(),
  );
  return (PreferenciasController(repositorio), repositorio);
}

void main() {
  test('PREF-03: choosing a theme changes it now and stores it', () async {
    final (controller, repositorio) = await _controller();

    await controller.mudarTema(Tema.escuro);

    expect(controller.value.tema, Tema.escuro);
    expect(repositorio.ler().tema, Tema.escuro);
  });

  test('PREF-03: choosing a text size changes it now and stores it', () async {
    final (controller, repositorio) = await _controller();

    await controller.mudarTamanho(TamanhoTexto.grande);

    expect(controller.value.tamanhoTexto, TamanhoTexto.grande);
    expect(repositorio.ler().tamanhoTexto, TamanhoTexto.grande);
  });

  testWidgets('PREF-03: widgets under the scope rebuild with the new value', (
    tester,
  ) async {
    final (controller, _) = (await tester.runAsync(_controller))!;
    await tester.pumpWidget(
      PreferenciasEscopo(
        controller: controller,
        child: Builder(
          builder: (context) => Text(
            PreferenciasEscopo.of(context).value.tema.rotulo,
            textDirection: TextDirection.ltr,
          ),
        ),
      ),
    );
    expect(find.text('Sistema'), findsOneWidget);

    await tester.runAsync(() => controller.mudarTema(Tema.claro));
    await tester.pump();

    expect(find.text('Claro'), findsOneWidget);
  });
}
