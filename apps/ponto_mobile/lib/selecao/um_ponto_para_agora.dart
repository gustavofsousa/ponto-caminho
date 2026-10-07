import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ponto_motor/ponto_motor.dart';

import '../colecao/ponto_page.dart';
import '../registro/falha_no_registro.dart';
import '../registro/registro_escopo.dart';

/// "Um ponto para agora": um toque, um ponto, sem repetir o que o leitor leu
/// há pouco. O filtro de obra vale enquanto o app estiver aberto.
class UmPontoParaAgora extends StatefulWidget {
  const UmPontoParaAgora({
    super.key,
    required this.colecao,
    required this.aleatorio,
  });

  final Colecao colecao;

  /// A fonte do sorteio vem de fora (`docs/dominios.md`, regra 6).
  final Random aleatorio;

  @override
  State<UmPontoParaAgora> createState() => _UmPontoParaAgoraState();
}

class _UmPontoParaAgoraState extends State<UmPontoParaAgora> {
  /// Id da obra escolhida; nulo = todas as obras.
  String? _obra;

  @override
  Widget build(BuildContext context) {
    final obrasComPontos = widget.colecao.obras.where(
      (obra) => obra.pontos.isNotEmpty,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FilledButton(
            onPressed: _abrirUmPonto,
            child: const Text('Um ponto para agora'),
          ),
          const SizedBox(height: 12),
          // Quebra a linha numa tela estreita com texto grande, em vez de transbordar.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _opcao('Todas as obras', null),
              for (final obra in obrasComPontos) _opcao(obra.titulo, obra.id),
            ],
          ),
        ],
      ),
    );
  }

  Widget _opcao(String rotulo, String? obra) => ChoiceChip(
    label: Text(rotulo),
    selected: _obra == obra,
    onSelected: (_) => setState(() => _obra = obra),
  );

  Future<void> _abrirUmPonto() async {
    final recentes = await _lerRecentes();
    if (!mounted) return;
    final ponto = pontoAleatorio(
      widget.colecao,
      aleatorio: widget.aleatorio,
      obra: _obra,
      recentes: recentes,
    );
    if (ponto == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PontoPage(
          colecao: widget.colecao,
          inicial: ponto,
          origem: OrigemDaLeitura.aleatorio,
        ),
      ),
    );
  }

  /// Sem registro, ou se ele não responder, sorteia entre todos: evitar
  /// repetição é cuidado, não condição para ler.
  Future<List<PontoId>> _lerRecentes() async {
    final registro = RegistroEscopo.of(context);
    if (registro == null) return const [];
    try {
      return await registro.leituras.listarRecentes(limite: janelaDeRecentes);
    } on Object catch (erro, pilha) {
      relatarFalhaNoRegistro(erro, pilha, 'ao ler os pontos recentes');
      return const [];
    }
  }
}
