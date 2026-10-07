import 'package:drift/drift.dart';
import 'package:ponto_motor/ponto_motor.dart';

import '../registro/banco_registro.dart';
import '../registro/ponto_id_gravado.dart';

/// Única porta de leitura e escrita das leituras. Grava eventos; o lugar do
/// leitor e os recentes são calculados, nunca gravados (`docs/dominios.md`, regra 4).
final class LeiturasRepositorio {
  LeiturasRepositorio(this._banco, {DateTime Function() agora = DateTime.now})
    : _agora = agora;

  final BancoRegistro _banco;
  final DateTime Function() _agora;

  /// Cada abertura é uma leitura nova, inclusive do mesmo ponto.
  Future<void> registrar(PontoId ponto, OrigemDaLeitura origem) async {
    await _banco
        .into(_banco.leituras)
        .insert(
          LeiturasCompanion.insert(
            pontoId: ponto.toString(),
            lidoEm: _agora().toUtc(),
            origem: origem,
          ),
        );
  }

  /// Até [limite] pontos distintos lidos em sequência, do mais novo para o
  /// mais antigo. Emite de novo a cada leitura gravada.
  Stream<List<PontoId>> observarLidosEmSequencia({required int limite}) =>
      _maisRecentes(limite, soEmSequencia: true).watch().map(_lerPontos);

  /// Até [limite] pontos distintos lidos por qualquer caminho, do mais novo
  /// para o mais antigo.
  Future<List<PontoId>> listarRecentes({required int limite}) async =>
      _lerPontos(await _maisRecentes(limite, soEmSequencia: false).get());

  JoinedSelectStatement<$LeiturasTable, LinhaDeLeitura> _maisRecentes(
    int limite, {
    required bool soEmSequencia,
  }) {
    final leituras = _banco.leituras;
    final ultima = leituras.id.max();
    final consulta = _banco.selectOnly(leituras)
      ..addColumns([leituras.pontoId, ultima])
      ..groupBy([leituras.pontoId])
      ..orderBy([OrderingTerm.desc(ultima)])
      ..limit(limite);
    if (soEmSequencia) {
      consulta.where(
        leituras.origem.isInValues(
          OrigemDaLeitura.values.where((origem) => origem.emSequencia),
        ),
      );
    }
    return consulta;
  }

  List<PontoId> _lerPontos(List<TypedResult> linhas) => linhas
      .map((linha) => lerPontoIdGravado(linha.read(_banco.leituras.pontoId)!))
      .nonNulls
      .toList();
}
