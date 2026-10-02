import 'dart:convert';

import 'colecao.dart';
import 'ler_colecao.dart';

/// Como ler um arquivo de `livros/` pelo nome — quem chama decide de onde (asset, disco, rede).
typedef LerArquivo = Future<String> Function(String arquivo);

/// Carrega a coleção no formato de `livros/`: `colecao.json` lista as obras e
/// cada obra mora em `<id>.json`. O motor é o único dono desse formato (AD-003).
Future<Colecao> carregarColecao(LerArquivo lerArquivo) async {
  final colecaoJson = await _lerObjeto(lerArquivo, 'colecao.json');
  final obrasJson = <String, Object?>{
    for (final obraId in _obrasListadas(colecaoJson))
      obraId: await _lerObjeto(lerArquivo, '$obraId.json'),
  };
  return lerColecao(colecaoJson, obrasJson);
}

/// Só o que dá para pedir como arquivo; o resto [lerColecao] recusa com a mensagem certa.
Iterable<String> _obrasListadas(Map<String, Object?> colecaoJson) =>
    switch (colecaoJson['obras']) {
      final List<Object?> ids => ids.whereType<String>(),
      _ => const [],
    };

Future<Map<String, Object?>> _lerObjeto(
  LerArquivo lerArquivo,
  String arquivo,
) async {
  final dados = jsonDecode(await lerArquivo(arquivo));
  if (dados is! Map<String, Object?>) {
    throw FormatException('$arquivo: não é um objeto JSON');
  }
  return dados;
}
