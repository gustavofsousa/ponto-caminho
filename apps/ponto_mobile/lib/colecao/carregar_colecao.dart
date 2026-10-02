import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:ponto_motor/ponto_motor.dart';

/// Borda de I/O: lê os JSON empacotados e entrega ao motor.
Future<Colecao> carregarColecao(AssetBundle bundle) async {
  Future<Map<String, Object?>> ler(String nome) async =>
      jsonDecode(await bundle.loadString('assets/livros/$nome.json'))
          as Map<String, Object?>;

  final colecaoJson = await ler('colecao');
  final obraIds = (colecaoJson['obras'] as List).cast<String>();
  final obrasJson = {for (final id in obraIds) id: await ler(id)};
  return lerColecao(colecaoJson, obrasJson);
}
