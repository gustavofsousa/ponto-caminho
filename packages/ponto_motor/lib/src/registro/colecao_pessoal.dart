import '../colecao/ponto_id.dart';

/// Lista nomeada pelo leitor. Não confundir com `Colecao` (o corpus de
/// conteúdo): nunca compartilham tipo, tabela nem função — docs/dominios.md, regra 3.
final class ColecaoPessoal {
  ColecaoPessoal({
    required this.id,
    required this.nome,
    required List<PontoId> pontos,
  }) : pontos = List.unmodifiable(pontos);

  final String id;
  final String nome;

  /// Na ordem em que foram guardados, o mais recente primeiro.
  final List<PontoId> pontos;

  bool contem(PontoId ponto) => pontos.contains(ponto);
}

/// Um nome de coleção cabe numa linha de lista.
const limiteDoNomeDeColecao = 60;

/// Resultado de conferir um nome digitado pelo leitor.
sealed class NomeDeColecao {
  const NomeDeColecao();
}

final class NomeAceito extends NomeDeColecao {
  const NomeAceito(this.nome);

  /// Já sem os espaços das pontas: é assim que se guarda.
  final String nome;
}

final class NomeVazio extends NomeDeColecao {
  const NomeVazio();
}

final class NomeRepetido extends NomeDeColecao {
  const NomeRepetido();
}

final class NomeLongo extends NomeDeColecao {
  const NomeLongo();
}

/// Confere um nome contra as coleções que já existem. [renomeando] é o id da
/// coleção que está mudando de nome — ela pode manter o próprio nome.
NomeDeColecao validarNomeDeColecao(
  String bruto,
  Iterable<ColecaoPessoal> existentes, {
  String? renomeando,
}) {
  final nome = bruto.trim();
  if (nome.isEmpty) return const NomeVazio();
  if (nome.runes.length > limiteDoNomeDeColecao) return const NomeLongo();

  final comparavel = nome.toLowerCase();
  final repetido = existentes.any(
    (c) => c.id != renomeando && c.nome.toLowerCase() == comparavel,
  );
  return repetido ? const NomeRepetido() : NomeAceito(nome);
}
