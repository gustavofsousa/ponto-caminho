import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/registro/banco_registro.dart';

/// Banco do registro em memória, novo a cada teste e fechado no fim dele.
/// Sem cifra: a cifra tem testes próprios em test/infra.
BancoRegistro abrirBancoDeTeste() {
  final banco = abrirBancoDeTela();
  addTearDown(banco.close);
  return banco;
}

/// Banco em memória para testes de tela: **não** é fechado no fim. O `close` do
/// drift espera um timer criado no relógio falso do `testWidgets`, que não anda
/// mais depois do teste — fechar ali trava a execução.
BancoRegistro abrirBancoDeTela() {
  // Cada teste abre o seu banco de propósito.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return BancoRegistro(NativeDatabase.memory());
}

/// `testWidgets` para telas que assinam streams do registro. No fim, descarta a
/// árvore e avança o relógio falso: ao perder o último ouvinte, o drift agenda
/// um `Timer.run`, e o teste falharia com um timer pendente.
void testWidgetsComRegistro(
  String descricao,
  Future<void> Function(WidgetTester tester) corpo,
) {
  testWidgets(descricao, (tester) async {
    await corpo(tester);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });
}

/// Relógio que o teste avança à mão. Sempre em UTC, como o registro grava.
final class RelogioDeTeste {
  RelogioDeTeste(this.agora);

  DateTime agora;

  DateTime call() => agora;
}
