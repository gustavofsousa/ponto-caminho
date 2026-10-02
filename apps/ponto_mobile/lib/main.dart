import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ponto_motor/ponto_motor.dart';

import 'colecao/carregar_colecao.dart';
import 'colecao/ponto_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(PontoApp(colecao: carregarColecao(rootBundle)));
}

class PontoApp extends StatelessWidget {
  const PontoApp({super.key, required this.colecao});

  final Future<Colecao> colecao;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ponto',
      theme: ThemeData(colorSchemeSeed: const Color(0xFF1F2A44)),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF1F2A44),
        brightness: Brightness.dark,
      ),
      home: FutureBuilder(
        future: colecao,
        builder: (context, snapshot) => switch (snapshot) {
          AsyncSnapshot(hasError: true) => _Mensagem(
            'Não foi possível abrir os livros.\n${snapshot.error}',
          ),
          AsyncSnapshot(:final data?) => _inicio(data),
          _ => const Scaffold(body: SizedBox.shrink()),
        },
      ),
    );
  }

  Widget _inicio(Colecao colecao) {
    final ponto = primeiroPonto(colecao);
    final referencia = ponto == null ? null : colecao.referenciaDe(ponto.id);
    if (ponto == null || referencia == null) {
      return const _Mensagem('Nenhum ponto disponível.');
    }
    return PontoPage(ponto: ponto, referencia: referencia);
  }
}

class _Mensagem extends StatelessWidget {
  const _Mensagem(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Padding(padding: const EdgeInsets.all(28), child: Text(texto)),
    ),
  );
}
