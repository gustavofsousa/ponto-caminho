import 'dart:io';

import 'package:ponto_motor/ponto_motor.dart';
import 'package:test/test.dart';

/// Guards drift between the real data in `livros/` and what the motor reads.
void main() {
  test('BASE-04: the real livros/ loads and every point resolves', () async {
    final colecao = await carregarColecao(
      (arquivo) => File('../../livros/$arquivo').readAsString(),
    );

    expect(colecao.obras.map((o) => o.id), ['caminho', 'sulco', 'forja']);
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
