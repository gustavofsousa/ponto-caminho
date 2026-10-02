import 'package:flutter/material.dart';

import 'registro.dart';

/// Entrega o [Registro] a qualquer tela abaixo (AD-007).
class RegistroEscopo extends InheritedWidget {
  const RegistroEscopo({
    super.key,
    required this.registro,
    required super.child,
  });

  /// Nulo quando o registro não abriu: a leitura segue e as áreas do registro
  /// mostram [AvisoRegistroIndisponivel] (ADR-002).
  final Registro? registro;

  static Registro? of(BuildContext context) {
    final escopo = context.dependOnInheritedWidgetOfExactType<RegistroEscopo>();
    assert(escopo != null, 'Nenhum RegistroEscopo acima deste widget.');
    return escopo!.registro;
  }

  @override
  bool updateShouldNotify(RegistroEscopo oldWidget) =>
      oldWidget.registro != registro;
}

/// O que aparece no lugar do registro quando ele não abriu.
class AvisoRegistroIndisponivel extends StatelessWidget {
  const AvisoRegistroIndisponivel({super.key});

  @override
  Widget build(BuildContext context) => Text(
    'Não foi possível abrir o que você guardou. Feche o app e abra de novo.',
    style: Theme.of(context).textTheme.bodyMedium,
  );
}
