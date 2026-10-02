import 'colecao.dart';
import 'ponto_id.dart';

/// Monta uma [Colecao] a partir do JSON de `livros/` já decodificado.
///
/// Fronteira de dado não confiável: tudo ou nada. Qualquer forma inválida lança
/// [FormatException] nomeando obra e campo — nunca `TypeError`, nunca coleção parcial.
Colecao lerColecao(
  Map<String, Object?> colecaoJson,
  Map<String, Object?> obrasJson,
) {
  if (colecaoJson case {
    'id': String id,
    'titulo': String titulo,
    'versaoDados': String versaoDados,
    'obras': List<Object?> obraIds,
  }) {
    return Colecao(
      id: id,
      titulo: titulo,
      versaoDados: versaoDados,
      obras: [
        for (final obraId in obraIds) _lerObraListada(id, obraId, obrasJson),
      ],
    );
  }
  throw const FormatException(
    'colecao.json: faltam id, titulo, versaoDados ou obras',
  );
}

Obra _lerObraListada(
  String colecaoId,
  Object? obraId,
  Map<String, Object?> obrasJson,
) {
  if (obraId is! String) {
    throw FormatException('colecao.json: id de obra não é texto', obraId);
  }
  final json = obrasJson[obraId];
  if (json == null) {
    throw FormatException('obra "$obraId" listada mas não fornecida');
  }
  return _lerObra(colecaoId, json);
}

Obra _lerObra(String colecaoId, Object? json) {
  if (json case {
    'id': String id,
    'obra': {'titulo': String titulo},
    'capitulos': List<Object?> capitulosJson,
    'pontos': List<Object?> pontosJson,
  }) {
    final capitulos = [for (final c in capitulosJson) _lerCapitulo(id, c)];
    final pontos = [for (final p in pontosJson) _lerPonto(colecaoId, id, p)];
    _conferirPontos(id, capitulos, pontos);
    return Obra(id: id, titulo: titulo, capitulos: capitulos, pontos: pontos);
  }
  throw const FormatException(
    'obra: faltam id, obra.titulo, capitulos ou pontos',
  );
}

/// INVARIANT: o número identifica o ponto no PontoId e todo ponto pertence a um
/// capítulo do índice — senão uma anotação apontaria para dois textos, ou para nenhum.
void _conferirPontos(
  String obraId,
  List<Capitulo> capitulos,
  List<Ponto> pontos,
) {
  final capitulosExistentes = {for (final c in capitulos) c.numero};
  final numerosVistos = <int>{};
  for (final ponto in pontos) {
    final numero = ponto.id.numero;
    if (!numerosVistos.add(numero)) {
      throw FormatException('$obraId: ponto $numero repetido');
    }
    if (!capitulosExistentes.contains(ponto.capituloNumero)) {
      throw FormatException(
        '$obraId: ponto $numero está no capítulo ${ponto.capituloNumero}, '
        'que não existe no índice',
      );
    }
  }
}

Capitulo _lerCapitulo(String obraId, Object? json) {
  if (json is! Map<String, Object?>) {
    throw FormatException('$obraId: capítulo não é um objeto', json);
  }
  if (json case {'numero': int numero}) {
    final onde = '$obraId, capítulo $numero';
    return Capitulo(
      numero: numero,
      slug: _textoOpcional(json, 'slug', onde),
      titulo: _textoOpcional(json, 'titulo', onde),
    );
  }
  throw FormatException('$obraId: capítulo sem número', json);
}

Ponto _lerPonto(String colecaoId, String obraId, Object? json) {
  if (json is! Map<String, Object?>) {
    throw FormatException('$obraId: ponto não é um objeto', json);
  }
  if (json case {
    'numero': int numero,
    'capituloNumero': int capituloNumero,
    'ordem': int ordem,
    'texto': String texto,
  }) {
    return Ponto(
      id: PontoId(colecaoId, obraId, numero),
      capituloNumero: capituloNumero,
      ordem: ordem,
      texto: texto,
      isMock: json['nota'] == 'mock',
    );
  }
  throw FormatException(
    '$obraId: ponto sem numero, capituloNumero, ordem ou texto',
    json,
  );
}

String? _textoOpcional(Map<String, Object?> json, String campo, String onde) =>
    switch (json[campo]) {
      null => null,
      final String texto => texto,
      final outro => throw FormatException(
        '$onde: "$campo" deveria ser texto',
        outro,
      ),
    };
