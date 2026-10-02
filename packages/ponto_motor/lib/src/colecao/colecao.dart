import 'ponto_id.dart';

/// Corpus fechado e versionado. Não confundir com `ColecaoPessoal` (lista do
/// leitor, domínio `registro`) — docs/dominios.md, regra 3.
final class Colecao {
  Colecao({
    required this.id,
    required this.titulo,
    required this.versaoDados,
    required this.obras,
  });

  final String id;
  final String titulo;
  final String versaoDados;
  final List<Obra> obras;

  Obra? obra(String id) {
    for (final obra in obras) {
      if (obra.id == id) return obra;
    }
    return null;
  }

  Referencia? referenciaDe(PontoId id) {
    if (id.colecao != this.id) return null;
    final obra = this.obra(id.obra);
    final ponto = obra?.ponto(id.numero);
    if (obra == null || ponto == null) return null;
    return Referencia(
      obra: obra.titulo,
      capitulo: obra.capitulo(ponto.capituloNumero)?.titulo,
      numero: ponto.id.numero,
    );
  }
}

/// Como um ponto é mostrado ao leitor — nunca o PontoId cru. Formato único em
/// toda superfície (página, compartilhar, exportar): `docs/modelo.md` §1.
final class Referencia {
  const Referencia({
    required this.obra,
    required this.capitulo,
    required this.numero,
  });

  final String obra;

  /// Nulo enquanto o índice daquela obra não tiver o título conferido.
  final String? capitulo;
  final int numero;

  String get texto => switch (capitulo) {
    final capitulo? => '$obra, capítulo $capitulo, ponto $numero',
    null => '$obra, ponto $numero',
  };
}

final class Obra {
  Obra({
    required this.id,
    required this.titulo,
    required this.capitulos,
    required List<Ponto> pontos,
  }) : pontos = List.unmodifiable(
         <Ponto>[...pontos]..sort((a, b) => a.ordem.compareTo(b.ordem)),
       ),
       _porNumero = {for (final p in pontos) p.id.numero: p};

  final String id;
  final String titulo;
  final List<Capitulo> capitulos;

  /// Em ordem de leitura (`ordem`).
  final List<Ponto> pontos;
  final Map<int, Ponto> _porNumero;

  Ponto? ponto(int numero) => _porNumero[numero];

  Capitulo? capitulo(int numero) {
    for (final capitulo in capitulos) {
      if (capitulo.numero == numero) return capitulo;
    }
    return null;
  }
}

final class Capitulo {
  const Capitulo({
    required this.numero,
    required this.slug,
    required this.titulo,
  });

  final int numero;
  final String? slug;
  final String? titulo;
}

final class Ponto {
  const Ponto({
    required this.id,
    required this.capituloNumero,
    required this.ordem,
    required this.texto,
    required this.isMock,
  });

  final PontoId id;
  final int capituloNumero;
  final int ordem;
  final String texto;

  /// Texto inventado para desenvolvimento (`"nota": "mock"` em livros/).
  final bool isMock;
}
