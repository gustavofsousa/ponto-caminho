import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ponto_motor/ponto_motor.dart';

import 'colecao/biblioteca_page.dart';
import 'leitura/continue_de_onde_parou.dart';
import 'preferencias/botao_preferencias.dart';
import 'selecao/um_ponto_para_agora.dart';

/// A primeira tela do app: por onde seguir, sem passar antes por uma lista de
/// livros. Só compõe o que cada domínio oferece — continuar (`leitura`), um
/// ponto para agora (`selecao`), a biblioteca (`colecao`); não tem regra própria.
class InicioPage extends StatelessWidget {
  InicioPage({super.key, required this.colecao, Random? aleatorio})
    : aleatorio = aleatorio ?? Random();

  final Colecao colecao;
  final Random aleatorio;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(colecao.titulo),
      actions: const [BotaoPreferencias()],
    ),
    body: ListView(
      children: [
        ContinueDeOndeParou(colecao: colecao),
        UmPontoParaAgora(colecao: colecao, aleatorio: aleatorio),
        ListTile(
          title: const Text('Biblioteca'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => BibliotecaPage(colecao: colecao),
            ),
          ),
        ),
      ],
    ),
  );
}
