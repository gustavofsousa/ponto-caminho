import 'package:flutter/material.dart';
import 'package:ponto_motor/ponto_motor.dart';

/// Página do ponto — v0.1: texto e referência. Ações e navegação chegam na v0.2.
class PontoPage extends StatelessWidget {
  const PontoPage({super.key, required this.ponto, required this.referencia});

  final Ponto ponto;
  final Referencia referencia;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(28, 48, 28, 32),
          children: [
            Semantics(
              header: true,
              child: Text(
                _formatarReferencia(referencia),
                style: texto.labelLarge,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              ponto.texto,
              style: texto.headlineSmall?.copyWith(height: 1.5),
            ),
            if (ponto.isMock) ...[
              const SizedBox(height: 32),
              Text('Texto provisório (mock)', style: texto.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

String _formatarReferencia(Referencia r) => switch (r.capitulo) {
  final capitulo? => '${r.obra}, capítulo $capitulo, ponto ${r.numero}',
  null => '${r.obra}, ponto ${r.numero}',
};
