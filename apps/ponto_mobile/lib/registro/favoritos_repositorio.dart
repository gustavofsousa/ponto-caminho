import 'package:drift/drift.dart';
import 'package:ponto_motor/ponto_motor.dart';

import 'banco_registro.dart';
import 'ponto_id_gravado.dart';

/// Única porta de leitura e escrita dos favoritos.
final class FavoritosRepositorio {
  FavoritosRepositorio(this._banco, {DateTime Function() agora = DateTime.now})
    : _agora = agora;

  final BancoRegistro _banco;
  final DateTime Function() _agora;

  /// Os pontos favoritos, o favoritado por último primeiro.
  Stream<List<PontoId>> observar() {
    final consulta = _banco.select(_banco.favoritos)
      ..orderBy([
        (f) => OrderingTerm.desc(f.favoritadoEm),
        (f) => OrderingTerm.desc(f.rowId),
      ]);
    return consulta.watch().map(
      (linhas) =>
          linhas.map((f) => lerPontoIdGravado(f.pontoId)).nonNulls.toList(),
    );
  }

  /// Um favorito por ponto: favoritar de novo não muda nada.
  Future<void> favoritar(PontoId ponto) async {
    await _banco
        .into(_banco.favoritos)
        .insert(
          FavoritosCompanion.insert(
            pontoId: ponto.toString(),
            favoritadoEm: _agora().toUtc(),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<void> desfavoritar(PontoId ponto) async {
    await (_banco.delete(
      _banco.favoritos,
    )..where((f) => f.pontoId.equals(ponto.toString()))).go();
  }
}
