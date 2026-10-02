import 'package:ponto_motor/ponto_motor.dart';

/// Lê um `PontoId` que veio do banco. Uma linha estragada some da tela em vez
/// de travá-la — e continua no banco, porque nada do leitor é apagado sozinho.
PontoId? lerPontoIdGravado(String gravado) {
  try {
    return PontoId.parse(gravado);
  } on FormatException {
    return null;
  }
}
