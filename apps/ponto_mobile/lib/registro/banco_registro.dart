import 'package:drift/drift.dart';

part 'banco_registro.g.dart';

// INVARIANT: tudo que é do leitor se ancora em `PontoId.toString()`, nunca em
// posição nem em id de conteúdo (docs/dominios.md, regra 2). Datas sempre em UTC.

@DataClassName('LinhaDeReflexao')
@TableIndex(name: 'reflexoes_por_ponto', columns: {#pontoId})
class Reflexoes extends Table {
  TextColumn get id => text()();
  TextColumn get pontoId => text()();
  TextColumn get texto => text()();
  DateTimeColumn get criadaEm => dateTime()();
  DateTimeColumn get editadaEm => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('LinhaDeFavorito')
class Favoritos extends Table {
  TextColumn get pontoId => text()();
  DateTimeColumn get favoritadoEm => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {pontoId};
}

/// Nunca "colecoes": a coleção de conteúdo é outra coisa (docs/dominios.md, regra 3).
@DataClassName('LinhaDeColecao')
class ColecoesPessoais extends Table {
  TextColumn get id => text()();
  TextColumn get nome => text()();
  DateTimeColumn get criadaEm => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('LinhaDePontoNaColecao')
class PontosDaColecao extends Table {
  TextColumn get colecaoId =>
      text().references(ColecoesPessoais, #id, onDelete: KeyAction.cascade)();
  TextColumn get pontoId => text()();
  DateTimeColumn get guardadoEm => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {colecaoId, pontoId};
}

/// Fatos que acontecem uma vez só na vida do registro (ex.: o leitor já
/// respondeu às coleções sugeridas).
@DataClassName('LinhaDeMarco')
class Marcos extends Table {
  TextColumn get chave => text()();
  DateTimeColumn get em => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {chave};
}

@DriftDatabase(
  tables: [Reflexoes, Favoritos, ColecoesPessoais, PontosDaColecao, Marcos],
)
final class BancoRegistro extends _$BancoRegistro {
  BancoRegistro(super.executor);

  // Mudar o schema = subir a versão e escrever o `onUpgrade`; nunca recriar o
  // banco, porque isso apagaria as reflexões do leitor.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (_) => customStatement('PRAGMA foreign_keys = ON'),
  );
}
