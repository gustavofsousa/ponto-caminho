import '../colecao/colecao.dart';
import '../colecao/ponto_id.dart';
import '../selecao/obter_ponto.dart';

/// O ponto para onde "continue de onde parou" leva: o mais recente de
/// [lidosEmSequencia] (do mais novo para o mais antigo) que ainda existe na
/// coleção. Nulo quando nenhum existe.
Ponto? pontoParaContinuar(
  Colecao colecao,
  Iterable<PontoId> lidosEmSequencia,
) => lidosEmSequencia.map((id) => obterPonto(colecao, id)).nonNulls.firstOrNull;
