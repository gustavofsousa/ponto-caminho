import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart';

/// 32 bytes em hexadecimal minúsculo — o formato que a guarda da chave gera.
final _formatoDaChave = RegExp(r'^[0-9a-f]{64}$');

/// Abre [arquivo] cifrado com [chave], num isolate à parte (a derivação da
/// chave custa caro). Nada é lido nem escrito antes da cifra estar ativa.
QueryExecutor abrirBancoCifrado(File arquivo, String chave) =>
    NativeDatabase.createInBackground(
      arquivo,
      setup: (bruto) => prepararCifra(bruto, chave),
    );

/// Liga a cifra numa conexão recém-aberta, ou lança — nunca segue em claro.
void prepararCifra(Database bruto, String chave) {
  // SECURITY: só hexadecimal entra no PRAGMA (não há como injetar SQL), e a
  // mensagem nunca carrega a chave.
  if (!_formatoDaChave.hasMatch(chave)) {
    throw ArgumentError('a chave do registro não está no formato esperado');
  }
  bruto.execute("PRAGMA key = '$chave';");
  // Um SQLite sem SQLite3MultipleCiphers ignora o PRAGMA acima e não conhece
  // este: sem resposta, o banco seria gravado em claro.
  if (bruto.select('PRAGMA cipher;').isEmpty) {
    throw StateError('SQLite sem cifra: o registro não abre em claro');
  }
}
