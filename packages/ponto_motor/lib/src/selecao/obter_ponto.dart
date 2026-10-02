import '../colecao/colecao.dart';
import '../colecao/ponto_id.dart';

Ponto? obterPonto(Colecao colecao, PontoId id) {
  if (id.colecao != colecao.id) return null;
  return colecao.obra(id.obra)?.ponto(id.numero);
}
