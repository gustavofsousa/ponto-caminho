import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/preferencias/preferencias_controller.dart';
import 'package:ponto_mobile/preferencias/preferencias_repositorio.dart';
import 'package:ponto_mobile/registro/registro.dart';
import 'package:ponto_mobile/registro/registro_escopo.dart';
import 'package:ponto_mobile/tema.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferências reais sobre o armazenamento falso do pacote. Fora do relógio falso do teste.
Future<PreferenciasController> criarPreferencias(
  WidgetTester tester, [
  Map<String, Object> gravado = const {},
]) async {
  final controller = await tester.runAsync(() async {
    SharedPreferences.setMockInitialValues(gravado);
    return PreferenciasController(
      PreferenciasRepositorio(await SharedPreferences.getInstance()),
    );
  });
  return controller!;
}

/// Monta uma tela como o app a monta: escopos de preferências e de registro +
/// tema de leitura. Sem [registro], o registro está indisponível.
Future<PreferenciasController> montarTela(
  WidgetTester tester,
  Widget tela, {
  PreferenciasController? preferencias,
  Registro? registro,
}) async {
  final controller = preferencias ?? await criarPreferencias(tester);
  await tester.pumpWidget(
    PreferenciasEscopo(
      controller: controller,
      child: RegistroEscopo(
        registro: registro,
        child: MaterialApp(theme: temaClaro(), home: tela),
      ),
    ),
  );
  return controller;
}

/// Tela estreita de celular pequeno (UX DoD: 320 px sem rolagem horizontal).
void usarTelaEstreita(WidgetTester tester) {
  tester.view.devicePixelRatio = 2;
  tester.view.physicalSize = const Size(320 * 2, 640 * 2);
  addTearDown(tester.view.reset);
}
