import 'dart:math';

import '../colecao/colecao.dart';
import '../colecao/ponto_id.dart';

/// Quantos pontos lidos por último "um ponto para agora" evita repetir.
const janelaDeRecentes = 10;

/// "Um ponto para agora": um ponto sorteado em [aleatorio] entre os da [obra]
/// (ou de todas), fora dos [janelaDeRecentes] pontos distintos mais recentes
/// de [recentes] — do mais novo para o mais antigo. A surpresa é o valor do
/// gesto (`docs/modelo.md` §3), não "já valeu".
///
/// Quando a obra não tem ponto fora da janela, a janela perde os mais antigos
/// até sobrar um. Nulo só quando o filtro não tem ponto disponível.
Ponto? pontoAleatorio(
  Colecao colecao, {
  required Random aleatorio,
  String? obra,
  Iterable<PontoId> recentes = const [],
}) {
  final universo = [
    for (final o in colecao.obras)
      if (obra == null || o.id == obra) ...o.pontos,
  ];
  if (universo.isEmpty) return null;

  final janela = recentes.toSet().take(janelaDeRecentes).toList();
  final candidatos = _foraDaJanela(universo, janela);
  return candidatos[aleatorio.nextInt(candidatos.length)];
}

/// Encolhe [janela] a partir do mais antigo até algum ponto de [universo]
/// ficar de fora dela. Termina: com a janela vazia, sobra o universo inteiro.
List<Ponto> _foraDaJanela(List<Ponto> universo, List<PontoId> janela) {
  for (var tamanho = janela.length; ; tamanho--) {
    final excluidos = janela.take(tamanho).toSet();
    final candidatos = [
      for (final ponto in universo)
        if (!excluidos.contains(ponto.id)) ponto,
    ];
    if (candidatos.isNotEmpty) return candidatos;
  }
}
