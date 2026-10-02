import 'package:flutter/material.dart';
import 'package:ponto_motor/ponto_motor.dart';

import 'capitulo_page.dart';
import 'nome_do_capitulo.dart';

/// Os capítulos de uma obra, como o autor os organizou — inclusive os ainda sem pontos.
class ObraPage extends StatelessWidget {
  const ObraPage({super.key, required this.colecao, required this.obra});

  final Colecao colecao;
  final Obra obra;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(obra.titulo)),
      body: ListView(
        children: [
          for (final capitulo in obra.capitulos)
            ListTile(
              leading: Text('${capitulo.numero}'),
              title: Text(nomeDoCapitulo(capitulo)),
              subtitle: switch (capitulo.totalPontos) {
                null => null,
                1 => const Text('1 ponto'),
                final total => Text('$total pontos'),
              },
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => CapituloPage(
                    colecao: colecao,
                    obra: obra,
                    capitulo: capitulo,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
