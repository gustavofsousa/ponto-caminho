import 'package:flutter/widgets.dart';

import 'preferencias.dart';
import 'preferencias_repositorio.dart';

/// A escolha vale na hora; gravar é consequência (AD-002, AD-005).
final class PreferenciasController extends ValueNotifier<Preferencias> {
  PreferenciasController(this._repositorio) : super(_repositorio.ler());

  final PreferenciasRepositorio _repositorio;

  Future<void> mudarTema(Tema tema) => _mudar(value.copyWith(tema: tema));

  Future<void> mudarTamanho(TamanhoTexto tamanho) =>
      _mudar(value.copyWith(tamanhoTexto: tamanho));

  Future<void> _mudar(Preferencias novas) {
    value = novas;
    return _repositorio.gravar(novas);
  }
}

/// Entrega o [PreferenciasController] a qualquer tela abaixo e a reconstrói quando ele muda.
class PreferenciasEscopo extends InheritedNotifier<PreferenciasController> {
  const PreferenciasEscopo({
    super.key,
    required PreferenciasController controller,
    required super.child,
  }) : super(notifier: controller);

  static PreferenciasController of(BuildContext context) {
    final escopo = context
        .dependOnInheritedWidgetOfExactType<PreferenciasEscopo>();
    assert(escopo != null, 'Nenhum PreferenciasEscopo acima deste widget.');
    return escopo!.notifier!;
  }
}
