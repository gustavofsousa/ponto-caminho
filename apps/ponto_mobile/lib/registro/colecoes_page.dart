import 'package:flutter/material.dart';
import 'package:ponto_motor/ponto_motor.dart';

import 'colecao_pessoal_page.dart';
import 'falha_no_registro.dart';
import 'nome_de_colecao_dialog.dart';
import 'ponto_guardado_tile.dart';
import 'registro.dart';
import 'registro_escopo.dart';
import 'sugestoes_page.dart';

/// Abre as coleções — passando antes pelas sugeridas, no primeiro contato.
Future<void> irParaColecoes(BuildContext context, Colecao colecao) async {
  final registro = RegistroEscopo.of(context);
  if (registro != null &&
      !await passarPelasSugestoes(context, registro.colecoes)) {
    return;
  }
  if (!context.mounted) return;
  await Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => ColecoesPage(colecao: colecao)),
  );
}

/// As coleções do leitor, na ordem em que foram criadas.
class ColecoesPage extends StatelessWidget {
  const ColecoesPage({super.key, required this.colecao});

  final Colecao colecao;

  @override
  Widget build(BuildContext context) {
    final registro = RegistroEscopo.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Coleções')),
      body: registro == null
          ? const Padding(
              padding: EdgeInsets.all(28),
              child: AvisoRegistroIndisponivel(),
            )
          : _ListaDeColecoes(registro: registro, colecao: colecao),
    );
  }
}

/// "1 ponto", "3 pontos", "Nenhum ponto".
String contarPontos(int quantidade) => switch (quantidade) {
  0 => 'Nenhum ponto',
  1 => '1 ponto',
  _ => '$quantidade pontos',
};

class _ListaDeColecoes extends StatefulWidget {
  const _ListaDeColecoes({required this.registro, required this.colecao});

  final Registro registro;
  final Colecao colecao;

  @override
  State<_ListaDeColecoes> createState() => _ListaDeColecoesState();
}

class _ListaDeColecoesState extends State<_ListaDeColecoes> {
  late final _colecoes = widget.registro.colecoes.observar();

  @override
  Widget build(BuildContext context) => StreamBuilder<List<ColecaoPessoal>>(
    stream: _colecoes,
    builder: (context, instantaneo) {
      final colecoes = instantaneo.data;
      if (colecoes == null) return const SizedBox.shrink();
      return ListView(
        children: [
          if (colecoes.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(28, 28, 28, 8),
              child: Text(
                'Crie uma coleção para reunir pontos sobre o que você quiser trabalhar.',
              ),
            ),
          for (final pessoal in colecoes)
            ListTile(
              title: Text(pessoal.nome),
              // Conta o que a coleção mostra: o que existe nos livros carregados.
              subtitle: Text(
                contarPontos(
                  pontosDisponiveis(widget.colecao, pessoal.pontos).length,
                ),
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ColecaoPessoalPage(
                    colecao: widget.colecao,
                    colecaoPessoalId: pessoal.id,
                  ),
                ),
              ),
            ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Nova coleção'),
            onTap: () => _criar(colecoes),
          ),
        ],
      );
    },
  );

  Future<void> _criar(List<ColecaoPessoal> existentes) async {
    final nome = await pedirNomeDeColecao(
      context,
      existentes: existentes,
      titulo: 'Nova coleção',
      confirmar: 'Criar',
    );
    if (nome == null) return;
    try {
      await widget.registro.colecoes.criar(nome);
    } on Object catch (erro, pilha) {
      relatarFalhaNoRegistro(erro, pilha, 'ao criar uma coleção');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível guardar agora. Tente de novo.'),
        ),
      );
    }
  }
}
