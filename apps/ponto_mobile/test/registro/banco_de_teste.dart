import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/registro/banco_registro.dart';

/// Banco do registro em memória, novo a cada teste e fechado no fim dele.
/// Sem cifra: a cifra tem testes próprios em test/infra.
BancoRegistro abrirBancoDeTeste() {
  // Cada teste abre o seu banco de propósito.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final banco = BancoRegistro(NativeDatabase.memory());
  addTearDown(banco.close);
  return banco;
}

/// Relógio que o teste avança à mão. Sempre em UTC, como o registro grava.
final class RelogioDeTeste {
  RelogioDeTeste(this.agora);

  DateTime agora;

  DateTime call() => agora;
}
