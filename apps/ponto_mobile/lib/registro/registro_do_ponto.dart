import 'package:flutter/material.dart';
import 'package:ponto_motor/ponto_motor.dart';

import 'data_da_reflexao.dart';
import 'editor_de_reflexao_page.dart';
import 'registro.dart';
import 'registro_escopo.dart';

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

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      OverflowBar(
        overflowAlignment: OverflowBarAlignment.start,
        children: [
          TextButton(
            onPressed: () => _abrirEditor(null),
            child: const Text('Escrever uma reflexão'),
          ),
        ],
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
