import 'package:flutter/material.dart';
import 'package:ponto_motor/ponto_motor.dart';

/// Pede um nome de coleção conferido pela regra do motor; devolve o nome aceito
/// (sem as pontas) ou nulo se o leitor cancelar. [renomeando] é o id da coleção
/// que muda de nome.
Future<String?> pedirNomeDeColecao(
  BuildContext context, {
  required List<ColecaoPessoal> existentes,
  required String titulo,
  required String confirmar,
  String? renomeando,
  String inicial = '',
}) => showDialog<String>(
  context: context,
  builder: (_) => _NomeDeColecaoDialog(
    existentes: existentes,
    titulo: titulo,
    confirmar: confirmar,
    renomeando: renomeando,
    inicial: inicial,
  ),
);

class _NomeDeColecaoDialog extends StatefulWidget {
  const _NomeDeColecaoDialog({
    required this.existentes,
    required this.titulo,
    required this.confirmar,
    required this.renomeando,
    required this.inicial,
  });

  final List<ColecaoPessoal> existentes;
  final String titulo;
  final String confirmar;
  final String? renomeando;
  final String inicial;

  @override
  State<_NomeDeColecaoDialog> createState() => _NomeDeColecaoDialogState();
}

class _NomeDeColecaoDialogState extends State<_NomeDeColecaoDialog> {
  late final _nome = TextEditingController(text: widget.inicial);

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resultado = validarNomeDeColecao(
      _nome.text,
      widget.existentes,
      renomeando: widget.renomeando,
    );
    final aceito = switch (resultado) {
      NomeAceito(:final nome) => nome,
      _ => null,
    };
    return AlertDialog(
      title: Text(widget.titulo),
      content: TextField(
        controller: _nome,
        autofocus: true,
        maxLength: limiteDoNomeDeColecao,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: 'Nome',
          errorText: switch (resultado) {
            NomeRepetido() => 'Já existe uma coleção com esse nome.',
            NomeLongo() => 'Use até $limiteDoNomeDeColecao caracteres.',
            NomeVazio() || NomeAceito() => null,
          },
        ),
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) {
          if (aceito != null) Navigator.of(context).pop(aceito);
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: aceito == null
              ? null
              : () => Navigator.of(context).pop(aceito),
          child: Text(widget.confirmar),
        ),
      ],
    );
  }
}
