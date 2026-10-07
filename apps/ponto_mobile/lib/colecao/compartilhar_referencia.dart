import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

/// Entrega [texto] a quem compartilha. Na página do ponto, o texto é sempre a
/// referência — nunca o texto do ponto (direitos, `docs/modelo.md` §7).
typedef Compartilhar = Future<void> Function(String texto);

/// A folha de compartilhamento do sistema.
Future<void> compartilharPeloSistema(String texto) async {
  await SharePlus.instance.share(ShareParams(text: texto));
}

/// O que vai ao log no lugar de uma falha ao compartilhar: só o tipo dela.
final class FalhaAoCompartilhar implements Exception {
  const FalhaAoCompartilhar(this.tipo);

  final Type tipo;

  @override
  String toString() => 'FalhaAoCompartilhar($tipo)';
}

/// Relata uma falha ao compartilhar sem o conteúdo dela.
void relatarFalhaAoCompartilhar(Object erro, StackTrace pilha) {
  // SECURITY: a mensagem da falha pode trazer o texto compartilhado — o que o
  // leitor estava lendo. Nunca passar `erro` adiante (mesma regra do AD-009).
  FlutterError.reportError(
    FlutterErrorDetails(
      exception: FalhaAoCompartilhar(erro.runtimeType),
      stack: pilha,
      library: 'ponto_mobile',
      context: ErrorDescription('ao compartilhar uma referência'),
    ),
  );
}
