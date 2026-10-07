import 'dart:io';

import 'package:ponto_mobile/infra/banco_cifrado.dart';
import 'package:sqlite3/sqlite3.dart';

/// O schema 1 do registro (v0.3), congelado: o `sqlite_master` de um banco novo
/// no commit 25b2296, capturado antes de a v0.4 mexer no banco (AD-011).
/// Nunca editar — é o arquivo que um leitor da v0.3 tem no aparelho.
const schemaV1 = [
  'CREATE TABLE "colecoes_pessoais" ("id" TEXT NOT NULL, "nome" TEXT NOT NULL, "criada_em" TEXT NOT NULL, PRIMARY KEY ("id"))',
  'CREATE TABLE "favoritos" ("ponto_id" TEXT NOT NULL, "favoritado_em" TEXT NOT NULL, PRIMARY KEY ("ponto_id"))',
  'CREATE TABLE "marcos" ("chave" TEXT NOT NULL, "em" TEXT NOT NULL, PRIMARY KEY ("chave"))',
  'CREATE TABLE "pontos_da_colecao" ("colecao_id" TEXT NOT NULL REFERENCES colecoes_pessoais (id) ON DELETE CASCADE, "ponto_id" TEXT NOT NULL, "guardado_em" TEXT NOT NULL, PRIMARY KEY ("colecao_id", "ponto_id"))',
  'CREATE TABLE "reflexoes" ("id" TEXT NOT NULL, "ponto_id" TEXT NOT NULL, "texto" TEXT NOT NULL, "criada_em" TEXT NOT NULL, "editada_em" TEXT NULL, PRIMARY KEY ("id"))',
  'CREATE INDEX reflexoes_por_ponto ON reflexoes (ponto_id)',
];

const tabelasV1 = [
  'colecoes_pessoais',
  'favoritos',
  'marcos',
  'pontos_da_colecao',
  'reflexoes',
];

/// Abre [arquivo] direto no SQLite, já com a cifra ligada por [chave].
Database abrirBruto(File arquivo, String chave) {
  final bruto = sqlite3.open(arquivo.path);
  prepararCifra(bruto, chave);
  return bruto;
}

/// Grava em [arquivo] um registro cifrado igual ao que a v0.3 deixa: schema 1,
/// `user_version` = 1 e o que um leitor guardou — duas reflexões (uma editada),
/// um favorito, uma coleção com um ponto e o marco das sugestões.
void criarRegistroV1(
  File arquivo,
  String chave, {
  List<String> alemDoSchema = const [],
}) {
  final bruto = abrirBruto(arquivo, chave);
  try {
    for (final instrucao in [...schemaV1, ...alemDoSchema]) {
      bruto.execute(instrucao);
    }
    bruto
      ..execute(
        "INSERT INTO reflexoes VALUES ('r1', 'ponto:teste/caminho/2', "
        "'Uma reflexão antiga.', '2026-03-12T06:40:00.000Z', "
        "'2026-03-14T21:05:00.000Z')",
      )
      ..execute(
        "INSERT INTO reflexoes VALUES ('r2', 'ponto:teste/caminho/81', "
        "'Outra, nunca editada.', '2026-04-20T07:00:00.000Z', NULL)",
      )
      ..execute(
        "INSERT INTO favoritos VALUES ('ponto:teste/sulco/1', "
        "'2026-03-13T08:00:00.000Z')",
      )
      ..execute(
        "INSERT INTO colecoes_pessoais VALUES ('c1', 'Família', "
        "'2026-03-15T09:00:00.000Z')",
      )
      ..execute(
        "INSERT INTO pontos_da_colecao VALUES ('c1', 'ponto:teste/caminho/81', "
        "'2026-03-15T09:01:00.000Z')",
      )
      ..execute(
        "INSERT INTO marcos VALUES ('sugestoes-respondidas', "
        "'2026-03-15T08:59:00.000Z')",
      )
      ..execute('PRAGMA user_version = 1');
  } finally {
    bruto.close();
  }
}

/// Todas as linhas de cada tabela da v0.3, na ordem em que foram gravadas.
Map<String, List<Map<String, Object?>>> lerLinhasV1(
  File arquivo,
  String chave,
) {
  final bruto = abrirBruto(arquivo, chave);
  try {
    return {
      for (final tabela in tabelasV1)
        tabela: [
          for (final linha in bruto.select(
            'SELECT * FROM $tabela ORDER BY rowid',
          ))
            Map.of(linha),
        ],
    };
  } finally {
    bruto.close();
  }
}

/// O schema de [bruto] no formato de [schemaV1], para comparar versões.
List<String> lerSchema(Database bruto) => [
  for (final linha in bruto.select(
    'SELECT sql FROM sqlite_master WHERE sql IS NOT NULL ORDER BY type DESC, name',
  ))
    linha['sql'] as String,
];

int lerVersao(File arquivo, String chave) {
  final bruto = abrirBruto(arquivo, chave);
  try {
    return bruto.select('PRAGMA user_version').single['user_version'] as int;
  } finally {
    bruto.close();
  }
}
