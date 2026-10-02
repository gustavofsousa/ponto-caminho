import 'package:flutter/material.dart';
import 'package:ponto_motor/ponto_motor.dart';

import 'data_da_reflexao.dart';
import 'editor_de_reflexao_page.dart';
import 'falha_no_registro.dart';
import 'guardar_em_colecao_page.dart';
import 'registro.dart';
import 'registro_escopo.dart';
import 'sugestoes_page.dart';

/// Abaixo do texto do ponto: o que o leitor guardou sobre ele e como guardar mais.
class RegistroDoPonto extends StatelessWidget {
  const RegistroDoPonto({
    super.key,
    required this.ponto,
    required this.referencia,
  });

  final PontoId ponto;
  final String referencia;

  @override
  Widget build(BuildContext context) {
    final registro = RegistroEscopo.of(context);
    if (registro == null) return const AvisoRegistroIndisponivel();
    return _RegistroAberto(
      registro: registro,
      ponto: ponto,
      referencia: referencia,
    );
  }
}

class _RegistroAberto extends StatefulWidget {
  const _RegistroAberto({
    required this.registro,
    required this.ponto,
    required this.referencia,
  });

  final Registro registro;
  final PontoId ponto;
  final String referencia;

  @override
  State<_RegistroAberto> createState() => _RegistroAbertoState();
}

class _RegistroAbertoState extends State<_RegistroAberto> {
  // Criado uma vez por ponto: no `build`, cada reconstrução refaria a consulta (AD-007).
  late final _reflexoes = widget.registro.reflexoes.observar(widget.ponto);
  late final _favoritos = widget.registro.favoritos.observar();
  late final _colecoes = widget.registro.colecoes.observar();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      OverflowBar(
        overflowAlignment: OverflowBarAlignment.start,
        children: [
          StreamBuilder<List<PontoId>>(
            stream: _favoritos,
            builder: (context, instantaneo) => _BotaoFavorito(
              favorito: instantaneo.data?.contains(widget.ponto),
              aoAlternar: _alternarFavorito,
            ),
          ),
          TextButton(
            onPressed: _guardarEmColecao,
            child: const Text('Guardar em uma coleção'),
          ),
          TextButton(
            onPressed: () => _abrirEditor(null),
            child: const Text('Escrever uma reflexão'),
          ),
        ],
      ),
      StreamBuilder<List<ColecaoPessoal>>(
        stream: _colecoes,
        builder: (context, instantaneo) {
          final nomes = [
            for (final colecao in instantaneo.data ?? const <ColecaoPessoal>[])
              if (colecao.contem(widget.ponto)) colecao.nome,
          ];
          if (nomes.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Nas coleções: ${nomes.join(' · ')}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        },
      ),
      StreamBuilder<List<Reflexao>>(
        stream: _reflexoes,
        builder: (context, instantaneo) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final reflexao in instantaneo.data ?? const <Reflexao>[])
              _ReflexaoNaPagina(
                reflexao,
                aoTocar: () => _abrirEditor(reflexao),
              ),
          ],
        ),
      ),
    ],
  );

  Future<void> _alternarFavorito(bool favorito) async {
    final favoritos = widget.registro.favoritos;
    try {
      await (favorito
          ? favoritos.desfavoritar(widget.ponto)
          : favoritos.favoritar(widget.ponto));
    } on Object catch (erro, pilha) {
      relatarFalhaNoRegistro(erro, pilha, 'ao favoritar');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível guardar agora. Tente de novo.'),
        ),
      );
    }
  }

  Future<void> _guardarEmColecao() async {
    if (!await passarPelasSugestoes(context, widget.registro.colecoes)) return;
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GuardarEmColecaoPage(ponto: widget.ponto),
      ),
    );
  }

  /// [reflexao] nula escreve uma nova.
  void _abrirEditor(Reflexao? reflexao) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => EditorDeReflexaoPage(
        ponto: widget.ponto,
        referencia: widget.referencia,
        reflexao: reflexao,
      ),
    ),
  );
}

/// Mostra e alterna o favorito; desabilitado até o banco responder.
class _BotaoFavorito extends StatelessWidget {
  const _BotaoFavorito({required this.favorito, required this.aoAlternar});

  /// Nulo enquanto o estado ainda não veio do banco.
  final bool? favorito;
  final void Function(bool favorito) aoAlternar;

  @override
  Widget build(BuildContext context) => IconButton(
    icon: Icon(favorito == true ? Icons.star : Icons.star_border),
    tooltip: favorito == true ? 'Remover dos favoritos' : 'Favoritar',
    onPressed: switch (favorito) {
      final favorito? => () => aoAlternar(favorito),
      null => null,
    },
  );
}

class _ReflexaoNaPagina extends StatelessWidget {
  const _ReflexaoNaPagina(this.reflexao, {required this.aoTocar});

  final Reflexao reflexao;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final estilos = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Semantics(
        button: true,
        onTapHint: 'editar a reflexão',
        child: InkWell(
          onTap: aoTocar,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reflexao.texto, style: estilos.bodyMedium),
                const SizedBox(height: 8),
                Text(escritoEm(reflexao), style: estilos.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
