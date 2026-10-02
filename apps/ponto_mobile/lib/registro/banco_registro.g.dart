// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banco_registro.dart';

// ignore_for_file: type=lint
class $ReflexoesTable extends Reflexoes
    with TableInfo<$ReflexoesTable, LinhaDeReflexao> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReflexoesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pontoIdMeta = const VerificationMeta(
    'pontoId',
  );
  @override
  late final GeneratedColumn<String> pontoId = GeneratedColumn<String>(
    'ponto_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textoMeta = const VerificationMeta('texto');
  @override
  late final GeneratedColumn<String> texto = GeneratedColumn<String>(
    'texto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _criadaEmMeta = const VerificationMeta(
    'criadaEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadaEm = GeneratedColumn<DateTime>(
    'criada_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _editadaEmMeta = const VerificationMeta(
    'editadaEm',
  );
  @override
  late final GeneratedColumn<DateTime> editadaEm = GeneratedColumn<DateTime>(
    'editada_em',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pontoId,
    texto,
    criadaEm,
    editadaEm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reflexoes';
  @override
  VerificationContext validateIntegrity(
    Insertable<LinhaDeReflexao> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('ponto_id')) {
      context.handle(
        _pontoIdMeta,
        pontoId.isAcceptableOrUnknown(data['ponto_id']!, _pontoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pontoIdMeta);
    }
    if (data.containsKey('texto')) {
      context.handle(
        _textoMeta,
        texto.isAcceptableOrUnknown(data['texto']!, _textoMeta),
      );
    } else if (isInserting) {
      context.missing(_textoMeta);
    }
    if (data.containsKey('criada_em')) {
      context.handle(
        _criadaEmMeta,
        criadaEm.isAcceptableOrUnknown(data['criada_em']!, _criadaEmMeta),
      );
    } else if (isInserting) {
      context.missing(_criadaEmMeta);
    }
    if (data.containsKey('editada_em')) {
      context.handle(
        _editadaEmMeta,
        editadaEm.isAcceptableOrUnknown(data['editada_em']!, _editadaEmMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LinhaDeReflexao map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LinhaDeReflexao(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      pontoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ponto_id'],
      )!,
      texto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}texto'],
      )!,
      criadaEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criada_em'],
      )!,
      editadaEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}editada_em'],
      ),
    );
  }

  @override
  $ReflexoesTable createAlias(String alias) {
    return $ReflexoesTable(attachedDatabase, alias);
  }
}

class LinhaDeReflexao extends DataClass implements Insertable<LinhaDeReflexao> {
  final String id;
  final String pontoId;
  final String texto;
  final DateTime criadaEm;
  final DateTime? editadaEm;
  const LinhaDeReflexao({
    required this.id,
    required this.pontoId,
    required this.texto,
    required this.criadaEm,
    this.editadaEm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['ponto_id'] = Variable<String>(pontoId);
    map['texto'] = Variable<String>(texto);
    map['criada_em'] = Variable<DateTime>(criadaEm);
    if (!nullToAbsent || editadaEm != null) {
      map['editada_em'] = Variable<DateTime>(editadaEm);
    }
    return map;
  }

  ReflexoesCompanion toCompanion(bool nullToAbsent) {
    return ReflexoesCompanion(
      id: Value(id),
      pontoId: Value(pontoId),
      texto: Value(texto),
      criadaEm: Value(criadaEm),
      editadaEm: editadaEm == null && nullToAbsent
          ? const Value.absent()
          : Value(editadaEm),
    );
  }

  factory LinhaDeReflexao.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LinhaDeReflexao(
      id: serializer.fromJson<String>(json['id']),
      pontoId: serializer.fromJson<String>(json['pontoId']),
      texto: serializer.fromJson<String>(json['texto']),
      criadaEm: serializer.fromJson<DateTime>(json['criadaEm']),
      editadaEm: serializer.fromJson<DateTime?>(json['editadaEm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'pontoId': serializer.toJson<String>(pontoId),
      'texto': serializer.toJson<String>(texto),
      'criadaEm': serializer.toJson<DateTime>(criadaEm),
      'editadaEm': serializer.toJson<DateTime?>(editadaEm),
    };
  }

  LinhaDeReflexao copyWith({
    String? id,
    String? pontoId,
    String? texto,
    DateTime? criadaEm,
    Value<DateTime?> editadaEm = const Value.absent(),
  }) => LinhaDeReflexao(
    id: id ?? this.id,
    pontoId: pontoId ?? this.pontoId,
    texto: texto ?? this.texto,
    criadaEm: criadaEm ?? this.criadaEm,
    editadaEm: editadaEm.present ? editadaEm.value : this.editadaEm,
  );
  LinhaDeReflexao copyWithCompanion(ReflexoesCompanion data) {
    return LinhaDeReflexao(
      id: data.id.present ? data.id.value : this.id,
      pontoId: data.pontoId.present ? data.pontoId.value : this.pontoId,
      texto: data.texto.present ? data.texto.value : this.texto,
      criadaEm: data.criadaEm.present ? data.criadaEm.value : this.criadaEm,
      editadaEm: data.editadaEm.present ? data.editadaEm.value : this.editadaEm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LinhaDeReflexao(')
          ..write('id: $id, ')
          ..write('pontoId: $pontoId, ')
          ..write('texto: $texto, ')
          ..write('criadaEm: $criadaEm, ')
          ..write('editadaEm: $editadaEm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, pontoId, texto, criadaEm, editadaEm);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LinhaDeReflexao &&
          other.id == this.id &&
          other.pontoId == this.pontoId &&
          other.texto == this.texto &&
          other.criadaEm == this.criadaEm &&
          other.editadaEm == this.editadaEm);
}

class ReflexoesCompanion extends UpdateCompanion<LinhaDeReflexao> {
  final Value<String> id;
  final Value<String> pontoId;
  final Value<String> texto;
  final Value<DateTime> criadaEm;
  final Value<DateTime?> editadaEm;
  final Value<int> rowid;
  const ReflexoesCompanion({
    this.id = const Value.absent(),
    this.pontoId = const Value.absent(),
    this.texto = const Value.absent(),
    this.criadaEm = const Value.absent(),
    this.editadaEm = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReflexoesCompanion.insert({
    required String id,
    required String pontoId,
    required String texto,
    required DateTime criadaEm,
    this.editadaEm = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       pontoId = Value(pontoId),
       texto = Value(texto),
       criadaEm = Value(criadaEm);
  static Insertable<LinhaDeReflexao> custom({
    Expression<String>? id,
    Expression<String>? pontoId,
    Expression<String>? texto,
    Expression<DateTime>? criadaEm,
    Expression<DateTime>? editadaEm,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pontoId != null) 'ponto_id': pontoId,
      if (texto != null) 'texto': texto,
      if (criadaEm != null) 'criada_em': criadaEm,
      if (editadaEm != null) 'editada_em': editadaEm,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReflexoesCompanion copyWith({
    Value<String>? id,
    Value<String>? pontoId,
    Value<String>? texto,
    Value<DateTime>? criadaEm,
    Value<DateTime?>? editadaEm,
    Value<int>? rowid,
  }) {
    return ReflexoesCompanion(
      id: id ?? this.id,
      pontoId: pontoId ?? this.pontoId,
      texto: texto ?? this.texto,
      criadaEm: criadaEm ?? this.criadaEm,
      editadaEm: editadaEm ?? this.editadaEm,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (pontoId.present) {
      map['ponto_id'] = Variable<String>(pontoId.value);
    }
    if (texto.present) {
      map['texto'] = Variable<String>(texto.value);
    }
    if (criadaEm.present) {
      map['criada_em'] = Variable<DateTime>(criadaEm.value);
    }
    if (editadaEm.present) {
      map['editada_em'] = Variable<DateTime>(editadaEm.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReflexoesCompanion(')
          ..write('id: $id, ')
          ..write('pontoId: $pontoId, ')
          ..write('texto: $texto, ')
          ..write('criadaEm: $criadaEm, ')
          ..write('editadaEm: $editadaEm, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FavoritosTable extends Favoritos
    with TableInfo<$FavoritosTable, LinhaDeFavorito> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoritosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pontoIdMeta = const VerificationMeta(
    'pontoId',
  );
  @override
  late final GeneratedColumn<String> pontoId = GeneratedColumn<String>(
    'ponto_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _favoritadoEmMeta = const VerificationMeta(
    'favoritadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> favoritadoEm = GeneratedColumn<DateTime>(
    'favoritado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [pontoId, favoritadoEm];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favoritos';
  @override
  VerificationContext validateIntegrity(
    Insertable<LinhaDeFavorito> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('ponto_id')) {
      context.handle(
        _pontoIdMeta,
        pontoId.isAcceptableOrUnknown(data['ponto_id']!, _pontoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pontoIdMeta);
    }
    if (data.containsKey('favoritado_em')) {
      context.handle(
        _favoritadoEmMeta,
        favoritadoEm.isAcceptableOrUnknown(
          data['favoritado_em']!,
          _favoritadoEmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_favoritadoEmMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pontoId};
  @override
  LinhaDeFavorito map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LinhaDeFavorito(
      pontoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ponto_id'],
      )!,
      favoritadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}favoritado_em'],
      )!,
    );
  }

  @override
  $FavoritosTable createAlias(String alias) {
    return $FavoritosTable(attachedDatabase, alias);
  }
}

class LinhaDeFavorito extends DataClass implements Insertable<LinhaDeFavorito> {
  final String pontoId;
  final DateTime favoritadoEm;
  const LinhaDeFavorito({required this.pontoId, required this.favoritadoEm});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['ponto_id'] = Variable<String>(pontoId);
    map['favoritado_em'] = Variable<DateTime>(favoritadoEm);
    return map;
  }

  FavoritosCompanion toCompanion(bool nullToAbsent) {
    return FavoritosCompanion(
      pontoId: Value(pontoId),
      favoritadoEm: Value(favoritadoEm),
    );
  }

  factory LinhaDeFavorito.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LinhaDeFavorito(
      pontoId: serializer.fromJson<String>(json['pontoId']),
      favoritadoEm: serializer.fromJson<DateTime>(json['favoritadoEm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pontoId': serializer.toJson<String>(pontoId),
      'favoritadoEm': serializer.toJson<DateTime>(favoritadoEm),
    };
  }

  LinhaDeFavorito copyWith({String? pontoId, DateTime? favoritadoEm}) =>
      LinhaDeFavorito(
        pontoId: pontoId ?? this.pontoId,
        favoritadoEm: favoritadoEm ?? this.favoritadoEm,
      );
  LinhaDeFavorito copyWithCompanion(FavoritosCompanion data) {
    return LinhaDeFavorito(
      pontoId: data.pontoId.present ? data.pontoId.value : this.pontoId,
      favoritadoEm: data.favoritadoEm.present
          ? data.favoritadoEm.value
          : this.favoritadoEm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LinhaDeFavorito(')
          ..write('pontoId: $pontoId, ')
          ..write('favoritadoEm: $favoritadoEm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(pontoId, favoritadoEm);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LinhaDeFavorito &&
          other.pontoId == this.pontoId &&
          other.favoritadoEm == this.favoritadoEm);
}

class FavoritosCompanion extends UpdateCompanion<LinhaDeFavorito> {
  final Value<String> pontoId;
  final Value<DateTime> favoritadoEm;
  final Value<int> rowid;
  const FavoritosCompanion({
    this.pontoId = const Value.absent(),
    this.favoritadoEm = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoritosCompanion.insert({
    required String pontoId,
    required DateTime favoritadoEm,
    this.rowid = const Value.absent(),
  }) : pontoId = Value(pontoId),
       favoritadoEm = Value(favoritadoEm);
  static Insertable<LinhaDeFavorito> custom({
    Expression<String>? pontoId,
    Expression<DateTime>? favoritadoEm,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (pontoId != null) 'ponto_id': pontoId,
      if (favoritadoEm != null) 'favoritado_em': favoritadoEm,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoritosCompanion copyWith({
    Value<String>? pontoId,
    Value<DateTime>? favoritadoEm,
    Value<int>? rowid,
  }) {
    return FavoritosCompanion(
      pontoId: pontoId ?? this.pontoId,
      favoritadoEm: favoritadoEm ?? this.favoritadoEm,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pontoId.present) {
      map['ponto_id'] = Variable<String>(pontoId.value);
    }
    if (favoritadoEm.present) {
      map['favoritado_em'] = Variable<DateTime>(favoritadoEm.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoritosCompanion(')
          ..write('pontoId: $pontoId, ')
          ..write('favoritadoEm: $favoritadoEm, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ColecoesPessoaisTable extends ColecoesPessoais
    with TableInfo<$ColecoesPessoaisTable, LinhaDeColecao> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ColecoesPessoaisTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _criadaEmMeta = const VerificationMeta(
    'criadaEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadaEm = GeneratedColumn<DateTime>(
    'criada_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, nome, criadaEm];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'colecoes_pessoais';
  @override
  VerificationContext validateIntegrity(
    Insertable<LinhaDeColecao> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('criada_em')) {
      context.handle(
        _criadaEmMeta,
        criadaEm.isAcceptableOrUnknown(data['criada_em']!, _criadaEmMeta),
      );
    } else if (isInserting) {
      context.missing(_criadaEmMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LinhaDeColecao map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LinhaDeColecao(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      criadaEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criada_em'],
      )!,
    );
  }

  @override
  $ColecoesPessoaisTable createAlias(String alias) {
    return $ColecoesPessoaisTable(attachedDatabase, alias);
  }
}

class LinhaDeColecao extends DataClass implements Insertable<LinhaDeColecao> {
  final String id;
  final String nome;
  final DateTime criadaEm;
  const LinhaDeColecao({
    required this.id,
    required this.nome,
    required this.criadaEm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['nome'] = Variable<String>(nome);
    map['criada_em'] = Variable<DateTime>(criadaEm);
    return map;
  }

  ColecoesPessoaisCompanion toCompanion(bool nullToAbsent) {
    return ColecoesPessoaisCompanion(
      id: Value(id),
      nome: Value(nome),
      criadaEm: Value(criadaEm),
    );
  }

  factory LinhaDeColecao.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LinhaDeColecao(
      id: serializer.fromJson<String>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
      criadaEm: serializer.fromJson<DateTime>(json['criadaEm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nome': serializer.toJson<String>(nome),
      'criadaEm': serializer.toJson<DateTime>(criadaEm),
    };
  }

  LinhaDeColecao copyWith({String? id, String? nome, DateTime? criadaEm}) =>
      LinhaDeColecao(
        id: id ?? this.id,
        nome: nome ?? this.nome,
        criadaEm: criadaEm ?? this.criadaEm,
      );
  LinhaDeColecao copyWithCompanion(ColecoesPessoaisCompanion data) {
    return LinhaDeColecao(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      criadaEm: data.criadaEm.present ? data.criadaEm.value : this.criadaEm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LinhaDeColecao(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('criadaEm: $criadaEm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nome, criadaEm);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LinhaDeColecao &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.criadaEm == this.criadaEm);
}

class ColecoesPessoaisCompanion extends UpdateCompanion<LinhaDeColecao> {
  final Value<String> id;
  final Value<String> nome;
  final Value<DateTime> criadaEm;
  final Value<int> rowid;
  const ColecoesPessoaisCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.criadaEm = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ColecoesPessoaisCompanion.insert({
    required String id,
    required String nome,
    required DateTime criadaEm,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nome = Value(nome),
       criadaEm = Value(criadaEm);
  static Insertable<LinhaDeColecao> custom({
    Expression<String>? id,
    Expression<String>? nome,
    Expression<DateTime>? criadaEm,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (criadaEm != null) 'criada_em': criadaEm,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ColecoesPessoaisCompanion copyWith({
    Value<String>? id,
    Value<String>? nome,
    Value<DateTime>? criadaEm,
    Value<int>? rowid,
  }) {
    return ColecoesPessoaisCompanion(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      criadaEm: criadaEm ?? this.criadaEm,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (criadaEm.present) {
      map['criada_em'] = Variable<DateTime>(criadaEm.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ColecoesPessoaisCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('criadaEm: $criadaEm, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PontosDaColecaoTable extends PontosDaColecao
    with TableInfo<$PontosDaColecaoTable, LinhaDePontoNaColecao> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PontosDaColecaoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _colecaoIdMeta = const VerificationMeta(
    'colecaoId',
  );
  @override
  late final GeneratedColumn<String> colecaoId = GeneratedColumn<String>(
    'colecao_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES colecoes_pessoais (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _pontoIdMeta = const VerificationMeta(
    'pontoId',
  );
  @override
  late final GeneratedColumn<String> pontoId = GeneratedColumn<String>(
    'ponto_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _guardadoEmMeta = const VerificationMeta(
    'guardadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> guardadoEm = GeneratedColumn<DateTime>(
    'guardado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [colecaoId, pontoId, guardadoEm];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pontos_da_colecao';
  @override
  VerificationContext validateIntegrity(
    Insertable<LinhaDePontoNaColecao> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('colecao_id')) {
      context.handle(
        _colecaoIdMeta,
        colecaoId.isAcceptableOrUnknown(data['colecao_id']!, _colecaoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_colecaoIdMeta);
    }
    if (data.containsKey('ponto_id')) {
      context.handle(
        _pontoIdMeta,
        pontoId.isAcceptableOrUnknown(data['ponto_id']!, _pontoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pontoIdMeta);
    }
    if (data.containsKey('guardado_em')) {
      context.handle(
        _guardadoEmMeta,
        guardadoEm.isAcceptableOrUnknown(data['guardado_em']!, _guardadoEmMeta),
      );
    } else if (isInserting) {
      context.missing(_guardadoEmMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {colecaoId, pontoId};
  @override
  LinhaDePontoNaColecao map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LinhaDePontoNaColecao(
      colecaoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}colecao_id'],
      )!,
      pontoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ponto_id'],
      )!,
      guardadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}guardado_em'],
      )!,
    );
  }

  @override
  $PontosDaColecaoTable createAlias(String alias) {
    return $PontosDaColecaoTable(attachedDatabase, alias);
  }
}

class LinhaDePontoNaColecao extends DataClass
    implements Insertable<LinhaDePontoNaColecao> {
  final String colecaoId;
  final String pontoId;
  final DateTime guardadoEm;
  const LinhaDePontoNaColecao({
    required this.colecaoId,
    required this.pontoId,
    required this.guardadoEm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['colecao_id'] = Variable<String>(colecaoId);
    map['ponto_id'] = Variable<String>(pontoId);
    map['guardado_em'] = Variable<DateTime>(guardadoEm);
    return map;
  }

  PontosDaColecaoCompanion toCompanion(bool nullToAbsent) {
    return PontosDaColecaoCompanion(
      colecaoId: Value(colecaoId),
      pontoId: Value(pontoId),
      guardadoEm: Value(guardadoEm),
    );
  }

  factory LinhaDePontoNaColecao.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LinhaDePontoNaColecao(
      colecaoId: serializer.fromJson<String>(json['colecaoId']),
      pontoId: serializer.fromJson<String>(json['pontoId']),
      guardadoEm: serializer.fromJson<DateTime>(json['guardadoEm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'colecaoId': serializer.toJson<String>(colecaoId),
      'pontoId': serializer.toJson<String>(pontoId),
      'guardadoEm': serializer.toJson<DateTime>(guardadoEm),
    };
  }

  LinhaDePontoNaColecao copyWith({
    String? colecaoId,
    String? pontoId,
    DateTime? guardadoEm,
  }) => LinhaDePontoNaColecao(
    colecaoId: colecaoId ?? this.colecaoId,
    pontoId: pontoId ?? this.pontoId,
    guardadoEm: guardadoEm ?? this.guardadoEm,
  );
  LinhaDePontoNaColecao copyWithCompanion(PontosDaColecaoCompanion data) {
    return LinhaDePontoNaColecao(
      colecaoId: data.colecaoId.present ? data.colecaoId.value : this.colecaoId,
      pontoId: data.pontoId.present ? data.pontoId.value : this.pontoId,
      guardadoEm: data.guardadoEm.present
          ? data.guardadoEm.value
          : this.guardadoEm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LinhaDePontoNaColecao(')
          ..write('colecaoId: $colecaoId, ')
          ..write('pontoId: $pontoId, ')
          ..write('guardadoEm: $guardadoEm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(colecaoId, pontoId, guardadoEm);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LinhaDePontoNaColecao &&
          other.colecaoId == this.colecaoId &&
          other.pontoId == this.pontoId &&
          other.guardadoEm == this.guardadoEm);
}

class PontosDaColecaoCompanion extends UpdateCompanion<LinhaDePontoNaColecao> {
  final Value<String> colecaoId;
  final Value<String> pontoId;
  final Value<DateTime> guardadoEm;
  final Value<int> rowid;
  const PontosDaColecaoCompanion({
    this.colecaoId = const Value.absent(),
    this.pontoId = const Value.absent(),
    this.guardadoEm = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PontosDaColecaoCompanion.insert({
    required String colecaoId,
    required String pontoId,
    required DateTime guardadoEm,
    this.rowid = const Value.absent(),
  }) : colecaoId = Value(colecaoId),
       pontoId = Value(pontoId),
       guardadoEm = Value(guardadoEm);
  static Insertable<LinhaDePontoNaColecao> custom({
    Expression<String>? colecaoId,
    Expression<String>? pontoId,
    Expression<DateTime>? guardadoEm,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (colecaoId != null) 'colecao_id': colecaoId,
      if (pontoId != null) 'ponto_id': pontoId,
      if (guardadoEm != null) 'guardado_em': guardadoEm,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PontosDaColecaoCompanion copyWith({
    Value<String>? colecaoId,
    Value<String>? pontoId,
    Value<DateTime>? guardadoEm,
    Value<int>? rowid,
  }) {
    return PontosDaColecaoCompanion(
      colecaoId: colecaoId ?? this.colecaoId,
      pontoId: pontoId ?? this.pontoId,
      guardadoEm: guardadoEm ?? this.guardadoEm,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (colecaoId.present) {
      map['colecao_id'] = Variable<String>(colecaoId.value);
    }
    if (pontoId.present) {
      map['ponto_id'] = Variable<String>(pontoId.value);
    }
    if (guardadoEm.present) {
      map['guardado_em'] = Variable<DateTime>(guardadoEm.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PontosDaColecaoCompanion(')
          ..write('colecaoId: $colecaoId, ')
          ..write('pontoId: $pontoId, ')
          ..write('guardadoEm: $guardadoEm, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MarcosTable extends Marcos with TableInfo<$MarcosTable, LinhaDeMarco> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MarcosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chaveMeta = const VerificationMeta('chave');
  @override
  late final GeneratedColumn<String> chave = GeneratedColumn<String>(
    'chave',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emMeta = const VerificationMeta('em');
  @override
  late final GeneratedColumn<DateTime> em = GeneratedColumn<DateTime>(
    'em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [chave, em];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'marcos';
  @override
  VerificationContext validateIntegrity(
    Insertable<LinhaDeMarco> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chave')) {
      context.handle(
        _chaveMeta,
        chave.isAcceptableOrUnknown(data['chave']!, _chaveMeta),
      );
    } else if (isInserting) {
      context.missing(_chaveMeta);
    }
    if (data.containsKey('em')) {
      context.handle(_emMeta, em.isAcceptableOrUnknown(data['em']!, _emMeta));
    } else if (isInserting) {
      context.missing(_emMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chave};
  @override
  LinhaDeMarco map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LinhaDeMarco(
      chave: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chave'],
      )!,
      em: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}em'],
      )!,
    );
  }

  @override
  $MarcosTable createAlias(String alias) {
    return $MarcosTable(attachedDatabase, alias);
  }
}

class LinhaDeMarco extends DataClass implements Insertable<LinhaDeMarco> {
  final String chave;
  final DateTime em;
  const LinhaDeMarco({required this.chave, required this.em});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chave'] = Variable<String>(chave);
    map['em'] = Variable<DateTime>(em);
    return map;
  }

  MarcosCompanion toCompanion(bool nullToAbsent) {
    return MarcosCompanion(chave: Value(chave), em: Value(em));
  }

  factory LinhaDeMarco.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LinhaDeMarco(
      chave: serializer.fromJson<String>(json['chave']),
      em: serializer.fromJson<DateTime>(json['em']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chave': serializer.toJson<String>(chave),
      'em': serializer.toJson<DateTime>(em),
    };
  }

  LinhaDeMarco copyWith({String? chave, DateTime? em}) =>
      LinhaDeMarco(chave: chave ?? this.chave, em: em ?? this.em);
  LinhaDeMarco copyWithCompanion(MarcosCompanion data) {
    return LinhaDeMarco(
      chave: data.chave.present ? data.chave.value : this.chave,
      em: data.em.present ? data.em.value : this.em,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LinhaDeMarco(')
          ..write('chave: $chave, ')
          ..write('em: $em')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(chave, em);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LinhaDeMarco &&
          other.chave == this.chave &&
          other.em == this.em);
}

class MarcosCompanion extends UpdateCompanion<LinhaDeMarco> {
  final Value<String> chave;
  final Value<DateTime> em;
  final Value<int> rowid;
  const MarcosCompanion({
    this.chave = const Value.absent(),
    this.em = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MarcosCompanion.insert({
    required String chave,
    required DateTime em,
    this.rowid = const Value.absent(),
  }) : chave = Value(chave),
       em = Value(em);
  static Insertable<LinhaDeMarco> custom({
    Expression<String>? chave,
    Expression<DateTime>? em,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chave != null) 'chave': chave,
      if (em != null) 'em': em,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MarcosCompanion copyWith({
    Value<String>? chave,
    Value<DateTime>? em,
    Value<int>? rowid,
  }) {
    return MarcosCompanion(
      chave: chave ?? this.chave,
      em: em ?? this.em,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chave.present) {
      map['chave'] = Variable<String>(chave.value);
    }
    if (em.present) {
      map['em'] = Variable<DateTime>(em.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MarcosCompanion(')
          ..write('chave: $chave, ')
          ..write('em: $em, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$BancoRegistro extends GeneratedDatabase {
  _$BancoRegistro(QueryExecutor e) : super(e);
  $BancoRegistroManager get managers => $BancoRegistroManager(this);
  late final $ReflexoesTable reflexoes = $ReflexoesTable(this);
  late final $FavoritosTable favoritos = $FavoritosTable(this);
  late final $ColecoesPessoaisTable colecoesPessoais = $ColecoesPessoaisTable(
    this,
  );
  late final $PontosDaColecaoTable pontosDaColecao = $PontosDaColecaoTable(
    this,
  );
  late final $MarcosTable marcos = $MarcosTable(this);
  late final Index reflexoesPorPonto = Index(
    'reflexoes_por_ponto',
    'CREATE INDEX reflexoes_por_ponto ON reflexoes (ponto_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    reflexoes,
    favoritos,
    colecoesPessoais,
    pontosDaColecao,
    marcos,
    reflexoesPorPonto,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'colecoes_pessoais',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pontos_da_colecao', kind: UpdateKind.delete)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$ReflexoesTableCreateCompanionBuilder =
    ReflexoesCompanion Function({
      required String id,
      required String pontoId,
      required String texto,
      required DateTime criadaEm,
      Value<DateTime?> editadaEm,
      Value<int> rowid,
    });
typedef $$ReflexoesTableUpdateCompanionBuilder =
    ReflexoesCompanion Function({
      Value<String> id,
      Value<String> pontoId,
      Value<String> texto,
      Value<DateTime> criadaEm,
      Value<DateTime?> editadaEm,
      Value<int> rowid,
    });

class $$ReflexoesTableFilterComposer
    extends Composer<_$BancoRegistro, $ReflexoesTable> {
  $$ReflexoesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pontoId => $composableBuilder(
    column: $table.pontoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get texto => $composableBuilder(
    column: $table.texto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadaEm => $composableBuilder(
    column: $table.criadaEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get editadaEm => $composableBuilder(
    column: $table.editadaEm,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReflexoesTableOrderingComposer
    extends Composer<_$BancoRegistro, $ReflexoesTable> {
  $$ReflexoesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pontoId => $composableBuilder(
    column: $table.pontoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get texto => $composableBuilder(
    column: $table.texto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadaEm => $composableBuilder(
    column: $table.criadaEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get editadaEm => $composableBuilder(
    column: $table.editadaEm,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReflexoesTableAnnotationComposer
    extends Composer<_$BancoRegistro, $ReflexoesTable> {
  $$ReflexoesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get pontoId =>
      $composableBuilder(column: $table.pontoId, builder: (column) => column);

  GeneratedColumn<String> get texto =>
      $composableBuilder(column: $table.texto, builder: (column) => column);

  GeneratedColumn<DateTime> get criadaEm =>
      $composableBuilder(column: $table.criadaEm, builder: (column) => column);

  GeneratedColumn<DateTime> get editadaEm =>
      $composableBuilder(column: $table.editadaEm, builder: (column) => column);
}

class $$ReflexoesTableTableManager
    extends
        RootTableManager<
          _$BancoRegistro,
          $ReflexoesTable,
          LinhaDeReflexao,
          $$ReflexoesTableFilterComposer,
          $$ReflexoesTableOrderingComposer,
          $$ReflexoesTableAnnotationComposer,
          $$ReflexoesTableCreateCompanionBuilder,
          $$ReflexoesTableUpdateCompanionBuilder,
          (
            LinhaDeReflexao,
            BaseReferences<_$BancoRegistro, $ReflexoesTable, LinhaDeReflexao>,
          ),
          LinhaDeReflexao,
          PrefetchHooks Function()
        > {
  $$ReflexoesTableTableManager(_$BancoRegistro db, $ReflexoesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReflexoesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReflexoesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReflexoesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> pontoId = const Value.absent(),
                Value<String> texto = const Value.absent(),
                Value<DateTime> criadaEm = const Value.absent(),
                Value<DateTime?> editadaEm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReflexoesCompanion(
                id: id,
                pontoId: pontoId,
                texto: texto,
                criadaEm: criadaEm,
                editadaEm: editadaEm,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String pontoId,
                required String texto,
                required DateTime criadaEm,
                Value<DateTime?> editadaEm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReflexoesCompanion.insert(
                id: id,
                pontoId: pontoId,
                texto: texto,
                criadaEm: criadaEm,
                editadaEm: editadaEm,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReflexoesTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoRegistro,
      $ReflexoesTable,
      LinhaDeReflexao,
      $$ReflexoesTableFilterComposer,
      $$ReflexoesTableOrderingComposer,
      $$ReflexoesTableAnnotationComposer,
      $$ReflexoesTableCreateCompanionBuilder,
      $$ReflexoesTableUpdateCompanionBuilder,
      (
        LinhaDeReflexao,
        BaseReferences<_$BancoRegistro, $ReflexoesTable, LinhaDeReflexao>,
      ),
      LinhaDeReflexao,
      PrefetchHooks Function()
    >;
typedef $$FavoritosTableCreateCompanionBuilder =
    FavoritosCompanion Function({
      required String pontoId,
      required DateTime favoritadoEm,
      Value<int> rowid,
    });
typedef $$FavoritosTableUpdateCompanionBuilder =
    FavoritosCompanion Function({
      Value<String> pontoId,
      Value<DateTime> favoritadoEm,
      Value<int> rowid,
    });

class $$FavoritosTableFilterComposer
    extends Composer<_$BancoRegistro, $FavoritosTable> {
  $$FavoritosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get pontoId => $composableBuilder(
    column: $table.pontoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get favoritadoEm => $composableBuilder(
    column: $table.favoritadoEm,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoritosTableOrderingComposer
    extends Composer<_$BancoRegistro, $FavoritosTable> {
  $$FavoritosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get pontoId => $composableBuilder(
    column: $table.pontoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get favoritadoEm => $composableBuilder(
    column: $table.favoritadoEm,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoritosTableAnnotationComposer
    extends Composer<_$BancoRegistro, $FavoritosTable> {
  $$FavoritosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get pontoId =>
      $composableBuilder(column: $table.pontoId, builder: (column) => column);

  GeneratedColumn<DateTime> get favoritadoEm => $composableBuilder(
    column: $table.favoritadoEm,
    builder: (column) => column,
  );
}

class $$FavoritosTableTableManager
    extends
        RootTableManager<
          _$BancoRegistro,
          $FavoritosTable,
          LinhaDeFavorito,
          $$FavoritosTableFilterComposer,
          $$FavoritosTableOrderingComposer,
          $$FavoritosTableAnnotationComposer,
          $$FavoritosTableCreateCompanionBuilder,
          $$FavoritosTableUpdateCompanionBuilder,
          (
            LinhaDeFavorito,
            BaseReferences<_$BancoRegistro, $FavoritosTable, LinhaDeFavorito>,
          ),
          LinhaDeFavorito,
          PrefetchHooks Function()
        > {
  $$FavoritosTableTableManager(_$BancoRegistro db, $FavoritosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoritosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoritosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoritosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> pontoId = const Value.absent(),
                Value<DateTime> favoritadoEm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FavoritosCompanion(
                pontoId: pontoId,
                favoritadoEm: favoritadoEm,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String pontoId,
                required DateTime favoritadoEm,
                Value<int> rowid = const Value.absent(),
              }) => FavoritosCompanion.insert(
                pontoId: pontoId,
                favoritadoEm: favoritadoEm,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoritosTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoRegistro,
      $FavoritosTable,
      LinhaDeFavorito,
      $$FavoritosTableFilterComposer,
      $$FavoritosTableOrderingComposer,
      $$FavoritosTableAnnotationComposer,
      $$FavoritosTableCreateCompanionBuilder,
      $$FavoritosTableUpdateCompanionBuilder,
      (
        LinhaDeFavorito,
        BaseReferences<_$BancoRegistro, $FavoritosTable, LinhaDeFavorito>,
      ),
      LinhaDeFavorito,
      PrefetchHooks Function()
    >;
typedef $$ColecoesPessoaisTableCreateCompanionBuilder =
    ColecoesPessoaisCompanion Function({
      required String id,
      required String nome,
      required DateTime criadaEm,
      Value<int> rowid,
    });
typedef $$ColecoesPessoaisTableUpdateCompanionBuilder =
    ColecoesPessoaisCompanion Function({
      Value<String> id,
      Value<String> nome,
      Value<DateTime> criadaEm,
      Value<int> rowid,
    });

final class $$ColecoesPessoaisTableReferences
    extends
        BaseReferences<
          _$BancoRegistro,
          $ColecoesPessoaisTable,
          LinhaDeColecao
        > {
  $$ColecoesPessoaisTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$PontosDaColecaoTable, List<LinhaDePontoNaColecao>>
  _pontosDaColecaoRefsTable(_$BancoRegistro db) =>
      MultiTypedResultKey.fromTable(
        db.pontosDaColecao,
        aliasName: 'colecoes_pessoais__id__pontos_da_colecao__colecao_id',
      );

  $$PontosDaColecaoTableProcessedTableManager get pontosDaColecaoRefs {
    final manager = $$PontosDaColecaoTableTableManager(
      $_db,
      $_db.pontosDaColecao,
    ).filter((f) => f.colecaoId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _pontosDaColecaoRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ColecoesPessoaisTableFilterComposer
    extends Composer<_$BancoRegistro, $ColecoesPessoaisTable> {
  $$ColecoesPessoaisTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadaEm => $composableBuilder(
    column: $table.criadaEm,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> pontosDaColecaoRefs(
    Expression<bool> Function($$PontosDaColecaoTableFilterComposer f) f,
  ) {
    final $$PontosDaColecaoTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pontosDaColecao,
      getReferencedColumn: (t) => t.colecaoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PontosDaColecaoTableFilterComposer(
            $db: $db,
            $table: $db.pontosDaColecao,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ColecoesPessoaisTableOrderingComposer
    extends Composer<_$BancoRegistro, $ColecoesPessoaisTable> {
  $$ColecoesPessoaisTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadaEm => $composableBuilder(
    column: $table.criadaEm,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ColecoesPessoaisTableAnnotationComposer
    extends Composer<_$BancoRegistro, $ColecoesPessoaisTable> {
  $$ColecoesPessoaisTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<DateTime> get criadaEm =>
      $composableBuilder(column: $table.criadaEm, builder: (column) => column);

  Expression<T> pontosDaColecaoRefs<T extends Object>(
    Expression<T> Function($$PontosDaColecaoTableAnnotationComposer a) f,
  ) {
    final $$PontosDaColecaoTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pontosDaColecao,
      getReferencedColumn: (t) => t.colecaoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PontosDaColecaoTableAnnotationComposer(
            $db: $db,
            $table: $db.pontosDaColecao,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ColecoesPessoaisTableTableManager
    extends
        RootTableManager<
          _$BancoRegistro,
          $ColecoesPessoaisTable,
          LinhaDeColecao,
          $$ColecoesPessoaisTableFilterComposer,
          $$ColecoesPessoaisTableOrderingComposer,
          $$ColecoesPessoaisTableAnnotationComposer,
          $$ColecoesPessoaisTableCreateCompanionBuilder,
          $$ColecoesPessoaisTableUpdateCompanionBuilder,
          (LinhaDeColecao, $$ColecoesPessoaisTableReferences),
          LinhaDeColecao,
          PrefetchHooks Function({bool pontosDaColecaoRefs})
        > {
  $$ColecoesPessoaisTableTableManager(
    _$BancoRegistro db,
    $ColecoesPessoaisTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ColecoesPessoaisTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ColecoesPessoaisTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ColecoesPessoaisTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<DateTime> criadaEm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ColecoesPessoaisCompanion(
                id: id,
                nome: nome,
                criadaEm: criadaEm,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nome,
                required DateTime criadaEm,
                Value<int> rowid = const Value.absent(),
              }) => ColecoesPessoaisCompanion.insert(
                id: id,
                nome: nome,
                criadaEm: criadaEm,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ColecoesPessoaisTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pontosDaColecaoRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (pontosDaColecaoRefs) db.pontosDaColecao,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (pontosDaColecaoRefs)
                    await $_getPrefetchedData<
                      LinhaDeColecao,
                      $ColecoesPessoaisTable,
                      LinhaDePontoNaColecao
                    >(
                      currentTable: table,
                      referencedTable: $$ColecoesPessoaisTableReferences
                          ._pontosDaColecaoRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ColecoesPessoaisTableReferences(
                            db,
                            table,
                            p0,
                          ).pontosDaColecaoRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.colecaoId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ColecoesPessoaisTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoRegistro,
      $ColecoesPessoaisTable,
      LinhaDeColecao,
      $$ColecoesPessoaisTableFilterComposer,
      $$ColecoesPessoaisTableOrderingComposer,
      $$ColecoesPessoaisTableAnnotationComposer,
      $$ColecoesPessoaisTableCreateCompanionBuilder,
      $$ColecoesPessoaisTableUpdateCompanionBuilder,
      (LinhaDeColecao, $$ColecoesPessoaisTableReferences),
      LinhaDeColecao,
      PrefetchHooks Function({bool pontosDaColecaoRefs})
    >;
typedef $$PontosDaColecaoTableCreateCompanionBuilder =
    PontosDaColecaoCompanion Function({
      required String colecaoId,
      required String pontoId,
      required DateTime guardadoEm,
      Value<int> rowid,
    });
typedef $$PontosDaColecaoTableUpdateCompanionBuilder =
    PontosDaColecaoCompanion Function({
      Value<String> colecaoId,
      Value<String> pontoId,
      Value<DateTime> guardadoEm,
      Value<int> rowid,
    });

final class $$PontosDaColecaoTableReferences
    extends
        BaseReferences<
          _$BancoRegistro,
          $PontosDaColecaoTable,
          LinhaDePontoNaColecao
        > {
  $$PontosDaColecaoTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ColecoesPessoaisTable _colecaoIdTable(_$BancoRegistro db) => db
      .colecoesPessoais
      .createAlias('pontos_da_colecao__colecao_id__colecoes_pessoais__id');

  $$ColecoesPessoaisTableProcessedTableManager get colecaoId {
    final $_column = $_itemColumn<String>('colecao_id')!;

    final manager = $$ColecoesPessoaisTableTableManager(
      $_db,
      $_db.colecoesPessoais,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_colecaoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PontosDaColecaoTableFilterComposer
    extends Composer<_$BancoRegistro, $PontosDaColecaoTable> {
  $$PontosDaColecaoTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get pontoId => $composableBuilder(
    column: $table.pontoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get guardadoEm => $composableBuilder(
    column: $table.guardadoEm,
    builder: (column) => ColumnFilters(column),
  );

  $$ColecoesPessoaisTableFilterComposer get colecaoId {
    final $$ColecoesPessoaisTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.colecaoId,
      referencedTable: $db.colecoesPessoais,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ColecoesPessoaisTableFilterComposer(
            $db: $db,
            $table: $db.colecoesPessoais,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PontosDaColecaoTableOrderingComposer
    extends Composer<_$BancoRegistro, $PontosDaColecaoTable> {
  $$PontosDaColecaoTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get pontoId => $composableBuilder(
    column: $table.pontoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get guardadoEm => $composableBuilder(
    column: $table.guardadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  $$ColecoesPessoaisTableOrderingComposer get colecaoId {
    final $$ColecoesPessoaisTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.colecaoId,
      referencedTable: $db.colecoesPessoais,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ColecoesPessoaisTableOrderingComposer(
            $db: $db,
            $table: $db.colecoesPessoais,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PontosDaColecaoTableAnnotationComposer
    extends Composer<_$BancoRegistro, $PontosDaColecaoTable> {
  $$PontosDaColecaoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get pontoId =>
      $composableBuilder(column: $table.pontoId, builder: (column) => column);

  GeneratedColumn<DateTime> get guardadoEm => $composableBuilder(
    column: $table.guardadoEm,
    builder: (column) => column,
  );

  $$ColecoesPessoaisTableAnnotationComposer get colecaoId {
    final $$ColecoesPessoaisTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.colecaoId,
      referencedTable: $db.colecoesPessoais,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ColecoesPessoaisTableAnnotationComposer(
            $db: $db,
            $table: $db.colecoesPessoais,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PontosDaColecaoTableTableManager
    extends
        RootTableManager<
          _$BancoRegistro,
          $PontosDaColecaoTable,
          LinhaDePontoNaColecao,
          $$PontosDaColecaoTableFilterComposer,
          $$PontosDaColecaoTableOrderingComposer,
          $$PontosDaColecaoTableAnnotationComposer,
          $$PontosDaColecaoTableCreateCompanionBuilder,
          $$PontosDaColecaoTableUpdateCompanionBuilder,
          (LinhaDePontoNaColecao, $$PontosDaColecaoTableReferences),
          LinhaDePontoNaColecao,
          PrefetchHooks Function({bool colecaoId})
        > {
  $$PontosDaColecaoTableTableManager(
    _$BancoRegistro db,
    $PontosDaColecaoTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PontosDaColecaoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PontosDaColecaoTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PontosDaColecaoTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> colecaoId = const Value.absent(),
                Value<String> pontoId = const Value.absent(),
                Value<DateTime> guardadoEm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PontosDaColecaoCompanion(
                colecaoId: colecaoId,
                pontoId: pontoId,
                guardadoEm: guardadoEm,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String colecaoId,
                required String pontoId,
                required DateTime guardadoEm,
                Value<int> rowid = const Value.absent(),
              }) => PontosDaColecaoCompanion.insert(
                colecaoId: colecaoId,
                pontoId: pontoId,
                guardadoEm: guardadoEm,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PontosDaColecaoTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({colecaoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (colecaoId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.colecaoId,
                                referencedTable:
                                    $$PontosDaColecaoTableReferences
                                        ._colecaoIdTable(db),
                                referencedColumn:
                                    $$PontosDaColecaoTableReferences
                                        ._colecaoIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PontosDaColecaoTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoRegistro,
      $PontosDaColecaoTable,
      LinhaDePontoNaColecao,
      $$PontosDaColecaoTableFilterComposer,
      $$PontosDaColecaoTableOrderingComposer,
      $$PontosDaColecaoTableAnnotationComposer,
      $$PontosDaColecaoTableCreateCompanionBuilder,
      $$PontosDaColecaoTableUpdateCompanionBuilder,
      (LinhaDePontoNaColecao, $$PontosDaColecaoTableReferences),
      LinhaDePontoNaColecao,
      PrefetchHooks Function({bool colecaoId})
    >;
typedef $$MarcosTableCreateCompanionBuilder =
    MarcosCompanion Function({
      required String chave,
      required DateTime em,
      Value<int> rowid,
    });
typedef $$MarcosTableUpdateCompanionBuilder =
    MarcosCompanion Function({
      Value<String> chave,
      Value<DateTime> em,
      Value<int> rowid,
    });

class $$MarcosTableFilterComposer
    extends Composer<_$BancoRegistro, $MarcosTable> {
  $$MarcosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get chave => $composableBuilder(
    column: $table.chave,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get em => $composableBuilder(
    column: $table.em,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MarcosTableOrderingComposer
    extends Composer<_$BancoRegistro, $MarcosTable> {
  $$MarcosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get chave => $composableBuilder(
    column: $table.chave,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get em => $composableBuilder(
    column: $table.em,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MarcosTableAnnotationComposer
    extends Composer<_$BancoRegistro, $MarcosTable> {
  $$MarcosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get chave =>
      $composableBuilder(column: $table.chave, builder: (column) => column);

  GeneratedColumn<DateTime> get em =>
      $composableBuilder(column: $table.em, builder: (column) => column);
}

class $$MarcosTableTableManager
    extends
        RootTableManager<
          _$BancoRegistro,
          $MarcosTable,
          LinhaDeMarco,
          $$MarcosTableFilterComposer,
          $$MarcosTableOrderingComposer,
          $$MarcosTableAnnotationComposer,
          $$MarcosTableCreateCompanionBuilder,
          $$MarcosTableUpdateCompanionBuilder,
          (
            LinhaDeMarco,
            BaseReferences<_$BancoRegistro, $MarcosTable, LinhaDeMarco>,
          ),
          LinhaDeMarco,
          PrefetchHooks Function()
        > {
  $$MarcosTableTableManager(_$BancoRegistro db, $MarcosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MarcosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MarcosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MarcosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> chave = const Value.absent(),
                Value<DateTime> em = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MarcosCompanion(chave: chave, em: em, rowid: rowid),
          createCompanionCallback:
              ({
                required String chave,
                required DateTime em,
                Value<int> rowid = const Value.absent(),
              }) => MarcosCompanion.insert(chave: chave, em: em, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MarcosTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoRegistro,
      $MarcosTable,
      LinhaDeMarco,
      $$MarcosTableFilterComposer,
      $$MarcosTableOrderingComposer,
      $$MarcosTableAnnotationComposer,
      $$MarcosTableCreateCompanionBuilder,
      $$MarcosTableUpdateCompanionBuilder,
      (
        LinhaDeMarco,
        BaseReferences<_$BancoRegistro, $MarcosTable, LinhaDeMarco>,
      ),
      LinhaDeMarco,
      PrefetchHooks Function()
    >;

class $BancoRegistroManager {
  final _$BancoRegistro _db;
  $BancoRegistroManager(this._db);
  $$ReflexoesTableTableManager get reflexoes =>
      $$ReflexoesTableTableManager(_db, _db.reflexoes);
  $$FavoritosTableTableManager get favoritos =>
      $$FavoritosTableTableManager(_db, _db.favoritos);
  $$ColecoesPessoaisTableTableManager get colecoesPessoais =>
      $$ColecoesPessoaisTableTableManager(_db, _db.colecoesPessoais);
  $$PontosDaColecaoTableTableManager get pontosDaColecao =>
      $$PontosDaColecaoTableTableManager(_db, _db.pontosDaColecao);
  $$MarcosTableTableManager get marcos =>
      $$MarcosTableTableManager(_db, _db.marcos);
}
