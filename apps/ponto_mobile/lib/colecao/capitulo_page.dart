import 'package:flutter/material.dart';
import 'package:ponto_motor/ponto_motor.dart';

import 'nome_do_capitulo.dart';
import 'ponto_page.dart';

/// Os pontos disponíveis de um capítulo, com o número e o início do texto.
class CapituloPage extends StatelessWidget {
  const CapituloPage({
    super.key,
    required this.colecao,
    required this.obra,
    required this.capitulo,
  });

  final Colecao colecao;
  final Obra obra;
  final Capitulo capitulo;

  @override
  Widget build(BuildContext context) {
    final pontos = obra.pontosDoCapitulo(capitulo.numero);
    return Scaffold(
      appBar: AppBar(title: Text(nomeDoCapitulo(capitulo))),
      body: pontos.isEmpty
          ? const _SemPontos()
          : ListView(
              children: [
                for (final ponto in pontos)
                  ListTile(
                    leading: Text('${ponto.id.numero}'),
                    title: Text(
                      ponto.texto,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => PontoPage(
                          colecao: colecao,
                          inicial: ponto,
                          origem: OrigemDaLeitura.biblioteca,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _SemPontos extends StatelessWidget {
  const _SemPontos();

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(28),
      child: Text(
        'Os pontos deste capítulo ainda não estão disponíveis.',
        textAlign: TextAlign.center,
      ),
    ),
  );
}
