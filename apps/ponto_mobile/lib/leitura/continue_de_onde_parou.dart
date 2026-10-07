import 'package:flutter/material.dart';
import 'package:ponto_motor/ponto_motor.dart';

import '../colecao/ponto_page.dart';
import '../registro/falha_no_registro.dart';
import '../registro/registro.dart';
import '../registro/registro_escopo.dart';

/// "Continue de onde parou": o último ponto lido em sequência, a um toque.
/// Quando não há para onde continuar, some — nada no lugar, nenhum aviso.
class ContinueDeOndeParou extends StatelessWidget {
  const ContinueDeOndeParou({super.key, required this.colecao});

  final Colecao colecao;

  @override
  Widget build(BuildContext context) {
    final registro = RegistroEscopo.of(context);
    if (registro == null) return const SizedBox.shrink();
    return _Continue(registro: registro, colecao: colecao);
  }
}

class _Continue extends StatefulWidget {
  const _Continue({required this.registro, required this.colecao});

  final Registro registro;
  final Colecao colecao;

  @override
  State<_Continue> createState() => _ContinueState();
}

class _ContinueState extends State<_Continue> {
  // Criado uma vez: no `build`, cada reconstrução refaria a consulta (AD-007).
  late final _lidosEmSequencia = widget.registro.leituras
      .observarLidosEmSequencia(limite: janelaDeRecentes)
      .handleError(
        (Object erro, StackTrace pilha) => relatarFalhaNoRegistro(
          erro,
          pilha,
          'ao procurar onde o leitor parou',
        ),
      );

  @override
  Widget build(BuildContext context) => StreamBuilder<List<PontoId>>(
    stream: _lidosEmSequencia,
    builder: (context, instantaneo) {
      final ponto = pontoParaContinuar(
        widget.colecao,
        instantaneo.data ?? const [],
      );
      if (ponto == null) return const SizedBox.shrink();
      return ListTile(
        title: const Text('Continue de onde parou'),
        // INVARIANT: `pontoParaContinuar` só devolve ponto da coleção.
        subtitle: Text(widget.colecao.referenciaDe(ponto.id)!.texto),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => PontoPage(
              colecao: widget.colecao,
              inicial: ponto,
              origem: OrigemDaLeitura.continuacao,
            ),
          ),
        ),
      );
    },
  );
}
