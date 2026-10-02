import 'package:flutter/material.dart';
import 'package:ponto_motor/ponto_motor.dart';

import 'falha_no_registro.dart';
import 'registro_escopo.dart';

/// Onde o leitor escreve o que um ponto provocou — ou muda e exclui o que escreveu.
class EditorDeReflexaoPage extends StatefulWidget {
  const EditorDeReflexaoPage({
    super.key,
    required this.ponto,
    required this.referencia,
    this.reflexao,
  });

  final PontoId ponto;
  final String referencia;

  /// A reflexão sendo editada; nula ao escrever uma nova.
  final Reflexao? reflexao;

  @override
  State<EditorDeReflexaoPage> createState() => _EditorDeReflexaoPageState();
}

class _EditorDeReflexaoPageState extends State<EditorDeReflexaoPage> {
  late final _texto = TextEditingController(text: widget.reflexao?.texto);
  bool _guardando = false;

  /// O que dizer quando a última escrita falhou; nulo se não falhou.
  String? _falha;

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  bool get _temTexto => limparTextoDeReflexao(_texto.text) != null;

  /// O que foi digitado difere do que está guardado (nada, numa reflexão nova)?
  bool get _mudou =>
      (limparTextoDeReflexao(_texto.text) ?? '') !=
      (widget.reflexao?.texto ?? '');

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_mudou,
    onPopInvokedWithResult: (saiu, _) {
      if (!saiu) _confirmarDescarte();
    },
    child: _editor(context),
  );

  Widget _editor(BuildContext context) {
    final estilos = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reflexão'),
        actions: [
          TextButton(
            onPressed: _temTexto && !_guardando ? _guardar : null,
            child: const Text('Guardar'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(28, 16, 28, 32),
        children: [
          Text(widget.referencia, style: estilos.labelLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _texto,
            autofocus: true,
            minLines: 6,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            style: estilos.bodyLarge,
            decoration: const InputDecoration(
              hintText: 'Deixe aqui um rastro da sua meditação.',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (_falha case final falha?) ...[
            const SizedBox(height: 16),
            Text(falha, style: estilos.bodyMedium),
          ],
          if (widget.reflexao case final reflexao?) ...[
            const SizedBox(height: 32),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: _guardando ? null : () => _excluir(reflexao),
                child: const Text('Excluir'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmarDescarte() async {
    final descartar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text('Descartar o que você escreveu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continuar escrevendo'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    // `pop` direto não passa pelo PopScope: sai sem perguntar de novo.
    if (descartar == true && mounted) Navigator.of(context).pop();
  }

  Future<void> _guardar() {
    final reflexoes = RegistroEscopo.of(context)!.reflexoes;
    return _escreverESair(
      () => switch (widget.reflexao) {
        null => reflexoes.escrever(widget.ponto, _texto.text),
        final reflexao => reflexoes.editar(reflexao.id, _texto.text),
      },
      quando: 'ao guardar uma reflexão',
      falha: 'Não foi possível guardar agora. Tente de novo.',
    );
  }

  Future<void> _excluir(Reflexao reflexao) async {
    final reflexoes = RegistroEscopo.of(context)!.reflexoes;
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: const Text('Excluir esta reflexão? Não dá para desfazer.'),
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
    await _escreverESair(
      () => reflexoes.excluir(reflexao.id),
      quando: 'ao excluir uma reflexão',
      falha: 'Não foi possível excluir agora. Tente de novo.',
    );
  }

  /// Escreve no registro e volta à página; se falhar, fica, com o texto intacto.
  Future<void> _escreverESair(
    Future<void> Function() escrita, {
    required String quando,
    required String falha,
  }) async {
    // Um segundo toque chega antes da reconstrução que desabilita o botão.
    if (_guardando) return;
    setState(() {
      _guardando = true;
      _falha = null;
    });
    try {
      await escrita();
      if (mounted) Navigator.of(context).pop();
    } on Object catch (erro, pilha) {
      relatarFalhaNoRegistro(erro, pilha, quando);
      if (mounted) {
        setState(() {
          _guardando = false;
          _falha = falha;
        });
      }
    }
  }
}
