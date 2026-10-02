import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ponto_motor/ponto_motor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'infra/guarda_da_chave.dart';
import 'preferencias/preferencias_repositorio.dart';
import 'registro/abrir_registro.dart';

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
      abrirRegistro: () async => abrirRegistro(
        pasta: await getApplicationSupportDirectory(),
        cofre: const CofreDoSistema(),
      ),
    ),
  );
}
