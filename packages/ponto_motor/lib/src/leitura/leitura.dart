/// Como o leitor chegou a um ponto (`docs/modelo.md` §4). Existe para entender
/// o uso, nunca para pontuar o leitor.
///
/// INVARIANT: o nome de cada valor é gravado no banco do registro — renomear
/// um valor exige migração.
enum OrigemDaLeitura {
  biblioteca(emSequencia: true),
  continuacao(emSequencia: true),
  aleatorio(emSequencia: false),
  favoritos(emSequencia: false),
  colecao(emSequencia: false);

  const OrigemDaLeitura({required this.emSequencia});

  /// Se a leitura segue o fio dos livros. Só estas movem o "continue de onde
  /// parou": um desvio pelo aleatório, por um favorito ou por uma coleção não
  /// tira o leitor do lugar em que estava.
  final bool emSequencia;
}
