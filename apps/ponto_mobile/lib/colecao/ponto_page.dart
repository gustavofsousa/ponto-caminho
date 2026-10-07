import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ponto_motor/ponto_motor.dart';

import '../leitura/registrar_leitura.dart';
import '../preferencias/botao_preferencias.dart';
import '../registro/registro_do_ponto.dart';
import '../registro/registro_escopo.dart';
import 'compartilhar_referencia.dart';

/// Página do ponto. Anterior/próximo trocam o ponto no lugar, sem empilhar
/// rotas: "voltar" sempre leva à tela de onde a leitura começou.
///
/// Cada ponto mostrado é uma leitura: o primeiro com a [origem] de quem abriu a
/// página; os seguintes, por Anterior/Próximo, como leitura dos livros em ordem.
class PontoPage extends StatefulWidget {
  const PontoPage({
    super.key,
    required this.colecao,
    required this.inicial,
    required this.origem,
    this.compartilhar = compartilharPeloSistema,
  });

  final Colecao colecao;
  final Ponto inicial;
  final OrigemDaLeitura origem;
  final Compartilhar compartilhar;

  @override
  State<PontoPage> createState() => _PontoPageState();
}

class _PontoPageState extends State<PontoPage> {
  late Ponto _ponto = widget.inicial;
  var _aberturaGravada = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Uma leitura por abertura: tema, tamanho do texto e teclado chamam isto
    // de novo a cada mudança.
    if (_aberturaGravada) return;
    _aberturaGravada = true;
    _gravarLeitura(widget.inicial, widget.origem);
  }

  @override
  Widget build(BuildContext context) {
    final colecao = widget.colecao;
    // INVARIANT: todo ponto desta página veio de `colecao`, então a referência existe.
    final referencia = colecao.referenciaDe(_ponto.id)!;
    final anterior = pontoAnterior(colecao, _ponto.id);
    final proximo = proximoPonto(colecao, _ponto.id);
    final estilos = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Compartilhar referência',
            onPressed: () => _compartilhar(referencia.texto),
          ),
          const BotaoPreferencias(),
        ],
      ),
      body: ListView(
        key: ValueKey(_ponto.id),
        padding: const EdgeInsets.fromLTRB(28, 16, 28, 32),
        children: [
          Semantics(
            header: true,
            child: Text(referencia.texto, style: estilos.labelLarge),
          ),
          const SizedBox(height: 32),
          Text(_ponto.texto, style: estilos.bodyLarge),
          if (_ponto.isMock) ...[
            const SizedBox(height: 32),
            Text('Texto provisório (mock)', style: estilos.bodySmall),
          ],
          const SizedBox(height: 40),
          RegistroDoPonto(ponto: _ponto.id, referencia: referencia.texto),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          // Lado a lado quando cabem; empilhados com texto grande, sem transbordar.
          child: OverflowBar(
            alignment: MainAxisAlignment.spaceBetween,
            overflowAlignment: OverflowBarAlignment.end,
            children: [
              if (anterior != null)
                TextButton(
                  onPressed: () => _ir(anterior),
                  child: const Text('Anterior'),
                )
              else
                const SizedBox.shrink(),
              if (proximo != null)
                TextButton(
                  onPressed: () => _ir(proximo),
                  child: const Text('Próximo'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _ir(Ponto ponto) {
    setState(() => _ponto = ponto);
    _gravarLeitura(ponto, OrigemDaLeitura.biblioteca);
  }

  Future<void> _compartilhar(String referencia) async {
    try {
      await widget.compartilhar(referencia);
    } on Object catch (erro, pilha) {
      relatarFalhaAoCompartilhar(erro, pilha);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível compartilhar.')),
      );
    }
  }

  void _gravarLeitura(Ponto ponto, OrigemDaLeitura origem) =>
      unawaited(registrarLeitura(RegistroEscopo.of(context), ponto.id, origem));
}
