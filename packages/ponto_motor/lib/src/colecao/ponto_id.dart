/// Endereço estável de um ponto: `ponto:<colecao>/<obra>/<numero>`.
///
/// INVARIANT: tudo que é do leitor (leitura, reflexão, favorito) se ancora
/// nesta string — nunca em posição ou id de banco. Ver docs/dominios.md, regra 2.
final class PontoId {
  const PontoId(this.colecao, this.obra, this.numero);

  final String colecao;
  final String obra;
  final int numero;

  static final _formato = RegExp(
    r'^ponto:([a-z0-9-]+)/([a-z0-9-]+)/([1-9][0-9]*)$',
  );

  static PontoId parse(String raw) {
    final match = _formato.firstMatch(raw);
    if (match == null) {
      throw FormatException('PontoId inválido', raw);
    }
    return PontoId(match[1]!, match[2]!, int.parse(match[3]!));
  }

  @override
  String toString() => 'ponto:$colecao/$obra/$numero';

  @override
  bool operator ==(Object other) =>
      other is PontoId &&
      other.colecao == colecao &&
      other.obra == obra &&
      other.numero == numero;

  @override
  int get hashCode => Object.hash(colecao, obra, numero);
}
