import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Onde a chave do registro mora. No aparelho, o Keystore/Keychain (ADR-002).
abstract interface class CofreDeChaves {
  Future<String?> ler();
  Future<void> gravar(String chave);
}

final class CofreDoSistema implements CofreDeChaves {
  const CofreDoSistema([this._armazenamento = const FlutterSecureStorage()]);

  static const _nome = 'registro.chave';

  final FlutterSecureStorage _armazenamento;

  @override
  Future<String?> ler() => _armazenamento.read(key: _nome);

  @override
  Future<void> gravar(String chave) =>
      _armazenamento.write(key: _nome, value: chave);
}

/// O registro existe, mas o cofre não tem a chave dele.
final class ChaveIndisponivel implements Exception {
  const ChaveIndisponivel();
}

/// A chave do registro: a guardada, ou uma nova — gravada antes de ser usada —
/// quando ainda não existe banco.
Future<String> obterChave(
  CofreDeChaves cofre, {
  required bool bancoExiste,
}) async {
  final guardada = await cofre.ler();
  if (guardada != null) return guardada;
  // INVARIANT: chave nova só para banco novo. O cofre do Android apaga uma
  // chave que não consegue abrir; gerar outra aqui tornaria o banco existente
  // ilegível para sempre.
  if (bancoExiste) throw const ChaveIndisponivel();

  final nova = _gerarChave();
  await cofre.gravar(nova);
  return nova;
}

/// 32 bytes de `Random.secure()` em hexadecimal.
String _gerarChave() {
  final aleatorio = Random.secure();
  return [
    for (var i = 0; i < 32; i++)
      aleatorio.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ].join();
}
