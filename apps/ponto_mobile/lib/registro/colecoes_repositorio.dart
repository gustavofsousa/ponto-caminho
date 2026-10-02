import 'package:drift/drift.dart';
import 'package:ponto_motor/ponto_motor.dart';
import 'package:uuid/uuid.dart';

import 'banco_registro.dart';
import 'ponto_id_gravado.dart';

/// O nome digitado não passou na regra do motor; [motivo] diz qual.
final class NomeDeColecaoInvalido implements Exception {
  const NomeDeColecaoInvalido(this.motivo);

  final NomeDeColecao motivo;
}

/// Única porta de leitura e escrita das coleções pessoais e da resposta às
/// coleções sugeridas.
final class ColecoesRepositorio {
  ColecoesRepositorio(this._banco, {DateTime Function() agora = DateTime.now})
    : _agora = agora;

  static const _marcoSugestoes = 'sugestoes-respondidas';

  final BancoRegistro _banco;
  final DateTime Function() _agora;

  /// As coleções na ordem em que foram criadas, cada uma com seus pontos do
  /// guardado por último ao primeiro; emite de novo a cada escrita.
  Stream<List<ColecaoPessoal>> observar() =>
      _consultaComPontos().watch().map(_agrupar);

  /// Cria a coleção — e, com [comPonto], já o guarda nela: tudo ou nada.
  Future<String> criar(String nome, {PontoId? comPonto}) =>
      _banco.transaction(() async {
        final id = await _inserir(_aceitar(nome, await _atuais()));
        if (comPonto != null) await guardar(id, comPonto);
        return id;
      });

  Future<void> renomear(String id, String nome) => _banco.transaction(() async {
    final aceito = _aceitar(nome, await _atuais(), renomeando: id);
    await (_banco.update(_banco.colecoesPessoais)
          ..where((c) => c.id.equals(id)))
        .write(ColecoesPessoaisCompanion(nome: Value(aceito)));
  });

  /// Apaga a coleção e só os vínculos dela: pontos, favoritos e reflexões ficam.
  Future<void> excluir(String id) async {
    await (_banco.delete(
      _banco.colecoesPessoais,
    )..where((c) => c.id.equals(id))).go();
  }

  /// Um ponto entra uma vez em cada coleção: guardar de novo não muda nada.
  Future<void> guardar(String colecaoId, PontoId ponto) async {
    await _banco
        .into(_banco.pontosDaColecao)
        .insert(
          PontosDaColecaoCompanion.insert(
            colecaoId: colecaoId,
            pontoId: ponto.toString(),
            guardadoEm: _agora().toUtc(),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> tirar(String colecaoId, PontoId ponto) async {
    await (_banco.delete(_banco.pontosDaColecao)..where(
          (v) =>
              v.colecaoId.equals(colecaoId) &
              v.pontoId.equals(ponto.toString()),
        ))
        .go();
  }

  Future<bool> sugestoesRespondidas() async {
    final marco = await (_banco.select(
      _banco.marcos,
    )..where((m) => m.chave.equals(_marcoSugestoes))).getSingleOrNull();
    return marco != null;
  }

  /// Cria as [escolhidas] na ordem dada e marca as sugestões como respondidas —
  /// recusar é responder com nenhuma. Tudo ou nada.
  Future<void> responderSugestoes(List<String> escolhidas) =>
      _banco.transaction(() async {
        for (final nome in escolhidas) {
          await _inserir(_aceitar(nome, await _atuais()));
        }
        await _banco
            .into(_banco.marcos)
            .insert(
              MarcosCompanion.insert(
                chave: _marcoSugestoes,
                em: _agora().toUtc(),
              ),
              mode: InsertMode.insertOrIgnore,
            );
      });

  Future<String> _inserir(String nome) async {
    final id = const Uuid().v4();
    await _banco
        .into(_banco.colecoesPessoais)
        .insert(
          ColecoesPessoaisCompanion.insert(
            id: id,
            nome: nome,
            criadaEm: _agora().toUtc(),
          ),
        );
    return id;
  }

  Future<List<ColecaoPessoal>> _atuais() async =>
      _agrupar(await _consultaComPontos().get());

  JoinedSelectStatement<HasResultSet, dynamic> _consultaComPontos() {
    final colecoes = _banco.colecoesPessoais;
    final vinculos = _banco.pontosDaColecao;
    return _banco.select(colecoes).join([
      leftOuterJoin(vinculos, vinculos.colecaoId.equalsExp(colecoes.id)),
    ])..orderBy([
      OrderingTerm.asc(colecoes.criadaEm),
      OrderingTerm.asc(colecoes.rowId),
      OrderingTerm.desc(vinculos.guardadoEm),
      OrderingTerm.desc(vinculos.rowId),
    ]);
  }

  /// Uma linha por vínculo (ou uma só, sem vínculo) → uma coleção com seus pontos.
  List<ColecaoPessoal> _agrupar(List<TypedResult> linhas) {
    final nomes = <String, String>{};
    final pontos = <String, List<PontoId>>{};
    for (final linha in linhas) {
      final colecao = linha.readTable(_banco.colecoesPessoais);
      nomes[colecao.id] = colecao.nome;
      final daColecao = pontos.putIfAbsent(colecao.id, () => []);
      final vinculo = linha.readTableOrNull(_banco.pontosDaColecao);
      final ponto = vinculo == null ? null : lerPontoIdGravado(vinculo.pontoId);
      if (ponto != null) daColecao.add(ponto);
    }
    return [
      for (final MapEntry(key: id, value: nome) in nomes.entries)
        ColecaoPessoal(id: id, nome: nome, pontos: pontos[id]!),
    ];
  }

  String _aceitar(
    String bruto,
    List<ColecaoPessoal> existentes, {
    String? renomeando,
  }) =>
      switch (validarNomeDeColecao(bruto, existentes, renomeando: renomeando)) {
        NomeAceito(:final nome) => nome,
        final motivo => throw NomeDeColecaoInvalido(motivo),
      };
}
