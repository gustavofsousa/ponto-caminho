import 'package:drift/drift.dart';
import 'package:ponto_motor/ponto_motor.dart';
import 'package:uuid/uuid.dart';

import 'banco_registro.dart';

/// Única porta de leitura e escrita das reflexões.
final class ReflexoesRepositorio {
  ReflexoesRepositorio(this._banco, {DateTime Function() agora = DateTime.now})
    : _agora = agora;

  final BancoRegistro _banco;
  final DateTime Function() _agora;

  /// As reflexões do ponto na ordem em que foram escritas, a mais antiga
  /// primeiro; emite de novo a cada escrita.
  Stream<List<Reflexao>> observar(PontoId ponto) {
    final consulta = _banco.select(_banco.reflexoes)
      ..where((r) => r.pontoId.equals(ponto.toString()))
      ..orderBy([
        (r) => OrderingTerm.asc(r.criadaEm),
        (r) => OrderingTerm.asc(r.rowId),
      ]);
    return consulta.watch().map(
      (linhas) => [
        for (final linha in linhas)
          Reflexao(
            id: linha.id,
            pontoId: ponto,
            texto: linha.texto,
            criadaEm: linha.criadaEm,
            editadaEm: linha.editadaEm,
          ),
      ],
    );
  }

  Future<void> escrever(PontoId ponto, String texto) async {
    await _banco
        .into(_banco.reflexoes)
        .insert(
          ReflexoesCompanion.insert(
            id: const Uuid().v4(),
            pontoId: ponto.toString(),
            texto: _textoGuardavel(texto),
            criadaEm: _agora().toUtc(),
          ),
        );
  }

  /// Guardar o mesmo texto não conta como edição.
  Future<void> editar(String id, String texto) async {
    final novo = _textoGuardavel(texto);
    final consulta = _banco.update(_banco.reflexoes)
      ..where((r) => r.id.equals(id) & r.texto.equals(novo).not());
    await consulta.write(
      ReflexoesCompanion(
        texto: Value(novo),
        editadaEm: Value(_agora().toUtc()),
      ),
    );
  }

  Future<void> excluir(String id) =>
      (_banco.delete(_banco.reflexoes)..where((r) => r.id.equals(id))).go();

  // SECURITY: a mensagem não carrega o texto — exceções acabam no log (AD-009).
  String _textoGuardavel(String bruto) =>
      limparTextoDeReflexao(bruto) ?? (throw ArgumentError('reflexão vazia'));
}
