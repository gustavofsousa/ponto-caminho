import 'package:flutter/foundation.dart';

/// O que vai ao log no lugar de um erro do registro: só o tipo dele.
final class FalhaNoRegistro implements Exception {
  const FalhaNoRegistro(this.tipo);

  final Type tipo;

  @override
  String toString() => 'FalhaNoRegistro($tipo)';
}

/// Relata uma falha do registro sem o conteúdo dela.
void relatarFalhaNoRegistro(Object erro, StackTrace pilha, String quando) {
  // SECURITY: a mensagem de uma SqliteException traz os parâmetros da
  // instrução — o texto da reflexão. Nunca passar `erro` adiante (AD-009).
  FlutterError.reportError(
    FlutterErrorDetails(
      exception: FalhaNoRegistro(erro.runtimeType),
      stack: pilha,
      library: 'ponto_mobile',
      context: ErrorDescription(quando),
    ),
  );
}
