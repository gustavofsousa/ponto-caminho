import 'colecao.dart';
import 'ponto_id.dart';

/// Monta uma [Colecao] a partir do JSON de `livros/` já decodificado.
///
/// Fronteira de dado não confiável: valida a forma e lança [FormatException]
/// com o caminho do problema. Não lê arquivo — quem chama faz o I/O.
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
    final obras = [
      for (final obraId in obraIds.cast<String>())
        _lerObra(
          id,
          obrasJson[obraId] ??
              (throw FormatException(
                'obra "$obraId" listada mas não fornecida',
              )),
        ),
    ];
    return Colecao(
      id: id,
      titulo: titulo,
      versaoDados: versaoDados,
      obras: obras,
    );
  }
  throw const FormatException(
    'colecao.json: faltam id, titulo, versaoDados ou obras',
  );
}

Obra _lerObra(String colecaoId, Object? json) {
  if (json case {
    'id': String id,
    'obra': {'titulo': String titulo},
    'capitulos': List<Object?> capitulos,
    'pontos': List<Object?> pontos,
  }) {
    return Obra(
      id: id,
      titulo: titulo,
      capitulos: [for (final c in capitulos) _lerCapitulo(id, c)],
      pontos: [for (final p in pontos) _lerPonto(colecaoId, id, p)],
    );
  }
  throw const FormatException(
    'obra: faltam id, obra.titulo, capitulos ou pontos',
  );
}

Capitulo _lerCapitulo(String obraId, Object? json) {
  if (json case {'numero': int numero}) {
    final campos = json as Map<String, Object?>;
    return Capitulo(
      numero: numero,
      slug: campos['slug'] as String?,
      titulo: campos['titulo'] as String?,
    );
  }
  throw FormatException('$obraId: capítulo sem número', json);
}

Ponto _lerPonto(String colecaoId, String obraId, Object? json) {
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
      isMock: (json as Map<String, Object?>)['nota'] == 'mock',
    );
  }
  throw FormatException(
    '$obraId: ponto sem numero, capituloNumero, ordem ou texto',
    json,
  );
}
