import 'package:flutter/material.dart';
import 'package:ponto_motor/ponto_motor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'preferencias/preferencias_repositorio.dart';

/// Só liga as dependências reais; a decisão de abertura mora em `app.dart`.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registrarLicencas();
  final repositorio = PreferenciasRepositorio(
    await SharedPreferences.getInstance(),
  );
  runApp(
    await abrirApp(
      carregarLivros: () => carregarColecao(lerLivroEmpacotado),
      repositorio: repositorio,
    ),
  );
}
