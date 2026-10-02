import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/registro/banco_registro.dart';
import 'package:ponto_mobile/registro/registro.dart';
import 'package:ponto_motor/ponto_motor.dart';

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
///
/// Dentro destes testes, conferir o banco só com consultas diretas (`get()`),
/// nunca com `observar()` em `runAsync`: o drift reaproveita a mesma consulta, e
/// a tela passaria a receber as atualizações na zona real — ou seja, nunca.
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

/// As coleções guardadas, em ordem de criação, com os `PontoId` de cada uma —
/// lidas direto das tabelas, sem stream (ver [testWidgetsComRegistro]).
Future<Map<String, List<String>>> lerColecoesGuardadas(
  BancoRegistro banco,
) async {
  final colecoes = await (banco.select(
    banco.colecoesPessoais,
  )..orderBy([(c) => OrderingTerm.asc(c.criadaEm)])).get();
  final vinculos = await banco.select(banco.pontosDaColecao).get();
  return {
    for (final colecao in colecoes)
      colecao.nome: [
        for (final vinculo in vinculos)
          if (vinculo.colecaoId == colecao.id) vinculo.pontoId,
      ],
  };
}

/// Sugestões já respondidas e as coleções [nomes] criadas nesta ordem; depois
/// guarda os [pontos] de cada uma, na ordem dada. O relógio anda um minuto a
/// cada escrita, para a ordem não depender de empate. Chamar dentro de `runAsync`.
Future<void> semearColecoes(
  Registro registro,
  BancoRegistro banco,
  RelogioDeTeste relogio,
  List<String> nomes, {
  Map<String, List<PontoId>> pontos = const {},
}) async {
  void avancar() =>
      relogio.agora = relogio.agora.add(const Duration(minutes: 1));

  await registro.colecoes.responderSugestoes([]);
  for (final nome in nomes) {
    avancar();
    await registro.colecoes.criar(nome);
  }
  final colecoes = await banco.select(banco.colecoesPessoais).get();
  for (final MapEntry(key: nome, value: ids) in pontos.entries) {
    final colecao = colecoes.singleWhere((c) => c.nome == nome);
    for (final id in ids) {
      avancar();
      await registro.colecoes.guardar(colecao.id, id);
    }
  }
}
