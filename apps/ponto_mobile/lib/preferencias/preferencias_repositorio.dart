import 'package:shared_preferences/shared_preferences.dart';

import 'preferencias.dart';

/// Preferências não são dado sensível: chave-valor local simples (AD-005).
final class PreferenciasRepositorio {
  const PreferenciasRepositorio(this._armazenamento);

  static const _chaveTema = 'preferencias.tema';
  static const _chaveTamanhoTexto = 'preferencias.tamanhoTexto';

  final SharedPreferences _armazenamento;

  /// Nunca lança: valor ausente, desconhecido ou de outro tipo volta ao padrão
  /// daquele campo — uma preferência estragada não pode travar a abertura.
  Preferencias ler() => Preferencias(
    tema: _enumGravado(Tema.values, _chaveTema) ?? Preferencias.padrao.tema,
    tamanhoTexto:
        _enumGravado(TamanhoTexto.values, _chaveTamanhoTexto) ??
        Preferencias.padrao.tamanhoTexto,
  );

  Future<void> gravar(Preferencias preferencias) async {
    await _armazenamento.setString(_chaveTema, preferencias.tema.name);
    await _armazenamento.setString(
      _chaveTamanhoTexto,
      preferencias.tamanhoTexto.name,
    );
  }

  T? _enumGravado<T extends Enum>(List<T> valores, String chave) =>
      switch (_armazenamento.get(chave)) {
        final String nome => valores.asNameMap()[nome],
        _ => null,
      };
}
