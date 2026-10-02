import 'dart:convert';
import 'dart:io';

import 'package:ponto_motor/ponto_motor.dart';
import 'package:test/test.dart';

/// Guards drift between the real data in `livros/` and what the motor reads.
void main() {
  test('the real collection in livros/ loads and every point resolves', () {
    final livros = Directory('../../livros');
    Map<String, Object?> ler(String nome) =>
        jsonDecode(File('${livros.path}/$nome.json').readAsStringSync())
            as Map<String, Object?>;

    final colecaoJson = ler('colecao');
    final ids = (colecaoJson['obras'] as List).cast<String>();
    final colecao = lerColecao(colecaoJson, {
      for (final id in ids) id: ler(id),
    });

    expect(colecao.obras.map((o) => o.id), ids);
    for (final obra in colecao.obras) {
      for (final ponto in obra.pontos) {
        expect(obterPonto(colecao, ponto.id), same(ponto));
        expect(
          colecao.referenciaDe(ponto.id),
          isNotNull,
          reason: '${ponto.id}',
        );
      }
    }
  });
}
