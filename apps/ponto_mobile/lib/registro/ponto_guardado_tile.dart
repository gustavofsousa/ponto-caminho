import 'package:flutter/material.dart';
import 'package:ponto_motor/ponto_motor.dart';

import '../colecao/ponto_page.dart';

/// Os pontos guardados que existem na coleção carregada, na mesma ordem. Os
/// que não existem ficam no banco e só não aparecem.
List<Ponto> pontosDisponiveis(Colecao colecao, Iterable<PontoId> guardados) =>
    guardados.map((id) => obterPonto(colecao, id)).nonNulls.toList();

/// Um ponto numa lista do leitor: referência completa e o começo do texto.
class PontoGuardadoTile extends StatelessWidget {
  const PontoGuardadoTile({
    super.key,
    required this.colecao,
    required this.ponto,
    required this.origem,
  });

  final Colecao colecao;
  final Ponto ponto;

  /// De qual lista do leitor o ponto foi aberto.
  final OrigemDaLeitura origem;

  @override
  Widget build(BuildContext context) => ListTile(
    // INVARIANT: o ponto veio de `pontosDisponiveis`, então a referência existe.
    title: Text(colecao.referenciaDe(ponto.id)!.texto),
    subtitle: Text(ponto.texto, maxLines: 2, overflow: TextOverflow.ellipsis),
    onTap: () => Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            PontoPage(colecao: colecao, inicial: ponto, origem: origem),
      ),
    ),
  );
}
