import '../colecao/colecao.dart';
import '../colecao/ponto_id.dart';
import 'obter_ponto.dart';

/// O ponto seguinte na obra, em ordem de leitura, atravessando capítulos.
/// Nulo no último ponto disponível: a sequência não passa para outra obra.
Ponto? proximoPonto(Colecao colecao, PontoId id) => _vizinho(colecao, id, 1);

/// O espelho de [proximoPonto].
Ponto? pontoAnterior(Colecao colecao, PontoId id) => _vizinho(colecao, id, -1);

Ponto? _vizinho(Colecao colecao, PontoId id, int passo) {
  final ponto = obterPonto(colecao, id);
  if (ponto == null) return null;

  final pontos = colecao.obra(id.obra)!.pontos;
  final vizinho = pontos.indexOf(ponto) + passo;
  if (vizinho < 0 || vizinho >= pontos.length) return null;
  return pontos[vizinho];
}
