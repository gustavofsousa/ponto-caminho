import 'package:flutter/material.dart';
import 'package:ponto_motor/ponto_motor.dart';

import '../preferencias/botao_preferencias.dart';
import '../registro/colecoes_page.dart';
import '../registro/favoritos_page.dart';
import 'obra_page.dart';

/// Porta de entrada: as obras da coleção, na ordem da coleção, e o que o leitor guardou.
class BibliotecaPage extends StatelessWidget {
  const BibliotecaPage({super.key, required this.colecao});

  final Colecao colecao;

  @override
  Widget build(BuildContext context) {
    final titulo = Theme.of(context).textTheme.titleLarge;
    return Scaffold(
      appBar: AppBar(
        title: Text(colecao.titulo),
        actions: const [BotaoPreferencias()],
      ),
      body: ListView(
        children: [
          for (final obra in colecao.obras)
            ListTile(
              title: Text(obra.titulo, style: titulo),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ObraPage(colecao: colecao, obra: obra),
                ),
              ),
            ),
          const Divider(height: 32),
          ListTile(
            title: const Text('Favoritos'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => FavoritosPage(colecao: colecao),
              ),
            ),
          ),
          ListTile(
            title: const Text('Coleções'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ColecoesPage(colecao: colecao),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
