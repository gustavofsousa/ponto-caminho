import 'package:flutter/material.dart';
import 'package:ponto_motor/ponto_motor.dart';

import 'ponto_guardado_tile.dart';
import 'registro.dart';
import 'registro_escopo.dart';

/// Os pontos favoritos, o favoritado por último primeiro.
class FavoritosPage extends StatelessWidget {
  const FavoritosPage({super.key, required this.colecao});

  final Colecao colecao;

  @override
  Widget build(BuildContext context) {
    final registro = RegistroEscopo.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: registro == null
          ? const Padding(
              padding: EdgeInsets.all(28),
              child: AvisoRegistroIndisponivel(),
            )
          : _ListaDeFavoritos(registro: registro, colecao: colecao),
    );
  }
}

class _ListaDeFavoritos extends StatefulWidget {
  const _ListaDeFavoritos({required this.registro, required this.colecao});

  final Registro registro;
  final Colecao colecao;

  @override
  State<_ListaDeFavoritos> createState() => _ListaDeFavoritosState();
}

class _ListaDeFavoritosState extends State<_ListaDeFavoritos> {
  late final _favoritos = widget.registro.favoritos.observar();

  @override
  Widget build(BuildContext context) => StreamBuilder<List<PontoId>>(
    stream: _favoritos,
    builder: (context, instantaneo) {
      // O banco é local: a espera é curta demais para um indicador.
      final guardados = instantaneo.data;
      if (guardados == null) return const SizedBox.shrink();
      final pontos = pontosDisponiveis(widget.colecao, guardados);
      if (pontos.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(28),
          child: Text('Os pontos que você favoritar ficam aqui.'),
        );
      }
      return ListView(
        children: [
          for (final ponto in pontos)
            PontoGuardadoTile(
              colecao: widget.colecao,
              ponto: ponto,
              origem: OrigemDaLeitura.favoritos,
            ),
        ],
      );
    },
  );
}
