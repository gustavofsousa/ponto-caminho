import 'package:flutter/material.dart';
import 'package:ponto_motor/ponto_motor.dart';

import '../preferencias/botao_preferencias.dart';

/// Página do ponto. Anterior/próximo trocam o ponto no lugar, sem empilhar
/// rotas: "voltar" sempre leva ao capítulo de onde a leitura começou.
class PontoPage extends StatefulWidget {
  const PontoPage({super.key, required this.colecao, required this.inicial});

  final Colecao colecao;
  final Ponto inicial;

  @override
  State<PontoPage> createState() => _PontoPageState();
}

class _PontoPageState extends State<PontoPage> {
  late Ponto _ponto = widget.inicial;

  @override
  Widget build(BuildContext context) {
    final colecao = widget.colecao;
    // INVARIANT: todo ponto desta página veio de `colecao`, então a referência existe.
    final referencia = colecao.referenciaDe(_ponto.id)!;
    final anterior = pontoAnterior(colecao, _ponto.id);
    final proximo = proximoPonto(colecao, _ponto.id);
    final estilos = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(actions: const [BotaoPreferencias()]),
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

  void _ir(Ponto ponto) => setState(() => _ponto = ponto);
}
