import 'package:ponto_mobile/infra/guarda_da_chave.dart';

/// Cofre em memória no lugar do Keystore, que não roda no teste de host.
final class CofreDeTeste implements CofreDeChaves {
  CofreDeTeste({this.chave, this.erroAoLer, this.aoGravar});

  String? chave;
  final Object? erroAoLer;

  /// Chamado no instante da gravação, antes de ela concluir.
  final void Function()? aoGravar;

  final gravadas = <String>[];

  @override
  Future<String?> ler() async {
    if (erroAoLer case final erro?) throw erro;
    return chave;
  }

  @override
  Future<void> gravar(String chave) async {
    aoGravar?.call();
    gravadas.add(chave);
    this.chave = chave;
  }
}
