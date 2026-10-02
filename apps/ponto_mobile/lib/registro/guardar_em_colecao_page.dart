import 'package:flutter/material.dart';
import 'package:ponto_motor/ponto_motor.dart';

import 'falha_no_registro.dart';
import 'nome_de_colecao_dialog.dart';
import 'registro.dart';
import 'registro_escopo.dart';

/// As coleções do leitor, marcadas onde o ponto já está. Marcar guarda,
/// desmarcar tira; "Nova coleção" cria uma já com o ponto.
class GuardarEmColecaoPage extends StatelessWidget {
  const GuardarEmColecaoPage({super.key, required this.ponto});

  final PontoId ponto;

  @override
  Widget build(BuildContext context) {
    final registro = RegistroEscopo.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Guardar em uma coleção')),
      body: registro == null
          ? const Padding(
              padding: EdgeInsets.all(28),
              child: AvisoRegistroIndisponivel(),
            )
          : _ColecoesParaMarcar(registro: registro, ponto: ponto),
    );
  }
}

class _ColecoesParaMarcar extends StatefulWidget {
  const _ColecoesParaMarcar({required this.registro, required this.ponto});

  final Registro registro;
  final PontoId ponto;

  @override
  State<_ColecoesParaMarcar> createState() => _ColecoesParaMarcarState();
}

class _ColecoesParaMarcarState extends State<_ColecoesParaMarcar> {
  late final _colecoes = widget.registro.colecoes.observar();

  @override
  Widget build(BuildContext context) => StreamBuilder<List<ColecaoPessoal>>(
    stream: _colecoes,
    builder: (context, instantaneo) {
      final colecoes = instantaneo.data;
      if (colecoes == null) return const SizedBox.shrink();
      return ListView(
        children: [
          for (final colecao in colecoes)
            CheckboxListTile(
              title: Text(colecao.nome),
              value: colecao.contem(widget.ponto),
              onChanged: (marcar) => _escrever(
                () => marcar == true
                    ? widget.registro.colecoes.guardar(colecao.id, widget.ponto)
                    : widget.registro.colecoes.tirar(colecao.id, widget.ponto),
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
    await _escrever(
      () => widget.registro.colecoes.criar(nome, comPonto: widget.ponto),
    );
  }

  Future<void> _escrever(Future<void> Function() escrita) async {
    try {
      await escrita();
    } on Object catch (erro, pilha) {
      relatarFalhaNoRegistro(erro, pilha, 'ao guardar em uma coleção');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível guardar agora. Tente de novo.'),
        ),
      );
    }
  }
}
