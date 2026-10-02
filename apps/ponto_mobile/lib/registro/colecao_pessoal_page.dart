import 'package:flutter/material.dart';
import 'package:ponto_motor/ponto_motor.dart';

import 'ponto_guardado_tile.dart';
import 'registro_escopo.dart';

/// Os pontos de uma coleção do leitor, o guardado por último primeiro.
class ColecaoPessoalPage extends StatefulWidget {
  const ColecaoPessoalPage({
    super.key,
    required this.colecao,
    required this.colecaoPessoalId,
  });

  final Colecao colecao;
  final String colecaoPessoalId;

  @override
  State<ColecaoPessoalPage> createState() => _ColecaoPessoalPageState();
}

class _ColecaoPessoalPageState extends State<ColecaoPessoalPage> {
  // Só se chega aqui pela lista de coleções, que já exige o registro aberto.
  late final _colecoes = RegistroEscopo.of(context)!.colecoes.observar();

  @override
  Widget build(BuildContext context) => StreamBuilder<List<ColecaoPessoal>>(
    stream: _colecoes,
    builder: (context, instantaneo) {
      final pessoal = instantaneo.data
          ?.where((c) => c.id == widget.colecaoPessoalId)
          .firstOrNull;
      return Scaffold(
        appBar: AppBar(title: Text(pessoal?.nome ?? '')),
        body: pessoal == null
            ? const SizedBox.shrink()
            : _Pontos(colecao: widget.colecao, pessoal: pessoal),
      );
    },
  );
}

class _Pontos extends StatelessWidget {
  const _Pontos({required this.colecao, required this.pessoal});

  final Colecao colecao;
  final ColecaoPessoal pessoal;

  @override
  Widget build(BuildContext context) {
    final pontos = pontosDisponiveis(colecao, pessoal.pontos);
    if (pontos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(28),
        child: Text('Nada aqui ainda. O que você salvar aparece nesta lista.'),
      );
    }
    return ListView(
      children: [
        for (final ponto in pontos)
          PontoGuardadoTile(colecao: colecao, ponto: ponto),
      ],
    );
  }
}
