import '../colecao/colecao.dart';
import '../colecao/ponto_id.dart';

Ponto? obterPonto(Colecao colecao, PontoId id) {
  if (id.colecao != colecao.id) return null;
  return colecao.obra(id.obra)?.ponto(id.numero);
}

/// Onde a leitura começa quando ainda não há "continue de onde parou".
Ponto? primeiroPonto(Colecao colecao) {
  for (final obra in colecao.obras) {
    if (obra.pontos.isNotEmpty) return obra.pontos.first;
  }
  return null;
}
