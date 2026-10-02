import '../colecao/ponto_id.dart';

/// O que um ponto provocou no leitor, escrito por ele. Dado pessoal religioso:
/// nunca sai do domínio `registro` sem pedido explícito (docs/dominios.md, regra 5).
final class Reflexao {
  const Reflexao({
    required this.id,
    required this.pontoId,
    required this.texto,
    required this.criadaEm,
    required this.editadaEm,
  });

  final String id;
  final PontoId pontoId;
  final String texto;
  final DateTime criadaEm;

  /// Nulo enquanto o texto nunca foi mudado depois de escrito.
  final DateTime? editadaEm;
}

/// O texto como deve ser guardado, ou nulo se não houver o que guardar.
String? limparTextoDeReflexao(String bruto) {
  final texto = bruto.trim();
  return texto.isEmpty ? null : texto;
}
