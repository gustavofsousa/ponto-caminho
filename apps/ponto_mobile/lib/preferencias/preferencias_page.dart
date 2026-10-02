import 'dart:async';

import 'package:flutter/material.dart';

import 'preferencias.dart';
import 'preferencias_controller.dart';

/// Tema e tamanho do texto. A escolha vale na hora, no app inteiro.
class PreferenciasPage extends StatelessWidget {
  const PreferenciasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = PreferenciasEscopo.of(context);
    final preferencias = controller.value;
    return Scaffold(
      appBar: AppBar(title: const Text('Leitura')),
      body: ListView(
        children: [
          const _Secao('Tema'),
          RadioGroup<Tema>(
            groupValue: preferencias.tema,
            onChanged: (tema) => unawaited(controller.mudarTema(tema!)),
            child: Column(
              children: [
                for (final tema in Tema.values)
                  RadioListTile<Tema>(value: tema, title: Text(tema.rotulo)),
              ],
            ),
          ),
          const _Secao('Tamanho do texto'),
          RadioGroup<TamanhoTexto>(
            groupValue: preferencias.tamanhoTexto,
            onChanged: (tamanho) =>
                unawaited(controller.mudarTamanho(tamanho!)),
            child: Column(
              children: [
                for (final tamanho in TamanhoTexto.values)
                  RadioListTile<TamanhoTexto>(
                    value: tamanho,
                    title: Text(tamanho.rotulo),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Secao extends StatelessWidget {
  const _Secao(this.titulo);

  final String titulo;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
    child: Semantics(
      header: true,
      child: Text(titulo, style: Theme.of(context).textTheme.titleSmall),
    ),
  );
}
