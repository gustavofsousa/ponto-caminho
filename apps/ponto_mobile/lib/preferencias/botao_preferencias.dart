import 'package:flutter/material.dart';

import 'preferencias_page.dart';

/// Acesso às preferências de leitura de onde se lê: biblioteca e página do ponto.
class BotaoPreferencias extends StatelessWidget {
  const BotaoPreferencias({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
    icon: const Icon(Icons.text_fields),
    tooltip: 'Preferências de leitura',
    onPressed: () => Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const PreferenciasPage())),
  );
}
