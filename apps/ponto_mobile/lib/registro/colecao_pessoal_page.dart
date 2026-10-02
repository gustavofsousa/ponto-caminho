import 'package:flutter/material.dart';
import 'package:ponto_motor/ponto_motor.dart';

import 'falha_no_registro.dart';
import 'nome_de_colecao_dialog.dart';
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

enum _Acao { renomear, excluir }

class _ColecaoPessoalPageState extends State<ColecaoPessoalPage> {
  // Só se chega aqui pela lista de coleções, que já exige o registro aberto.
  late final _repositorio = RegistroEscopo.of(context)!.colecoes;
  late final _colecoes = _repositorio.observar();

  @override
  Widget build(BuildContext context) => StreamBuilder<List<ColecaoPessoal>>(
    stream: _colecoes,
    builder: (context, instantaneo) {
      final todas = instantaneo.data ?? const <ColecaoPessoal>[];
      final pessoal = todas
          .where((c) => c.id == widget.colecaoPessoalId)
          .firstOrNull;
      return Scaffold(
        appBar: AppBar(
          title: Text(pessoal?.nome ?? ''),
          actions: [
            if (pessoal != null)
              PopupMenuButton<_Acao>(
                tooltip: 'Mais opções',
                onSelected: (acao) => switch (acao) {
                  _Acao.renomear => _renomear(pessoal, todas),
                  _Acao.excluir => _excluir(pessoal),
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: _Acao.renomear, child: Text('Renomear')),
                  PopupMenuItem(
                    value: _Acao.excluir,
                    child: Text('Excluir coleção'),
                  ),
                ],
              ),
          ],
        ),
        body: pessoal == null
            ? const SizedBox.shrink()
            : _Pontos(colecao: widget.colecao, pessoal: pessoal),
      );
    },
  );

  Future<void> _renomear(
    ColecaoPessoal pessoal,
    List<ColecaoPessoal> todas,
  ) async {
    final nome = await pedirNomeDeColecao(
      context,
      existentes: todas,
      titulo: 'Renomear coleção',
      confirmar: 'Renomear',
      renomeando: pessoal.id,
      inicial: pessoal.nome,
    );
    if (nome == null) return;
    await _escrever(() => _repositorio.renomear(pessoal.id, nome));
  }

  Future<void> _excluir(ColecaoPessoal pessoal) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(
          'Excluir a coleção ${pessoal.nome}? Os pontos e as reflexões continuam.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmou != true) return;
    final excluiu = await _escrever(() => _repositorio.excluir(pessoal.id));
    if (excluiu && mounted) Navigator.of(context).pop();
  }

  /// Devolve se a escrita deu certo; se não, avisa e relata sem conteúdo.
  Future<bool> _escrever(Future<void> Function() escrita) async {
    try {
      await escrita();
      return true;
    } on Object catch (erro, pilha) {
      relatarFalhaNoRegistro(erro, pilha, 'ao mudar uma coleção');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível guardar agora. Tente de novo.'),
          ),
        );
      }
      return false;
    }
  }
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
