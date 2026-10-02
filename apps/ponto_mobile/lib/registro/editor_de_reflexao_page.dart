import 'package:flutter/material.dart';
import 'package:ponto_motor/ponto_motor.dart';

import 'falha_no_registro.dart';
import 'registro_escopo.dart';

/// Onde o leitor escreve o que um ponto provocou.
class EditorDeReflexaoPage extends StatefulWidget {
  const EditorDeReflexaoPage({
    super.key,
    required this.ponto,
    required this.referencia,
  });

  final PontoId ponto;
  final String referencia;

  @override
  State<EditorDeReflexaoPage> createState() => _EditorDeReflexaoPageState();
}

class _EditorDeReflexaoPageState extends State<EditorDeReflexaoPage> {
  final _texto = TextEditingController();
  bool _guardando = false;
  bool _falhou = false;

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  bool get _temTexto => limparTextoDeReflexao(_texto.text) != null;

  @override
  Widget build(BuildContext context) {
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
          if (_falhou) ...[
            const SizedBox(height: 16),
            Text(
              'Não foi possível guardar agora. Tente de novo.',
              style: estilos.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _guardar() async {
    // Um segundo toque chega antes da reconstrução que desabilita o botão.
    if (_guardando) return;
    final registro = RegistroEscopo.of(context)!;
    setState(() {
      _guardando = true;
      _falhou = false;
    });
    try {
      await registro.reflexoes.escrever(widget.ponto, _texto.text);
      if (mounted) Navigator.of(context).pop();
    } on Object catch (erro, pilha) {
      relatarFalhaNoRegistro(erro, pilha, 'ao guardar uma reflexão');
      if (mounted) {
        setState(() {
          _guardando = false;
          _falhou = true;
        });
      }
    }
  }
}
