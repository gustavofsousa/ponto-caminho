import 'dart:convert';

import 'package:ponto_motor/ponto_motor.dart';
import 'package:test/test.dart';

import '../fixtures.dart';

void main() {
  final arquivos = {
    'colecao.json': jsonEncode(colecaoJson),
    for (final MapEntry(:key, :value) in obrasJson.entries)
      '$key.json': jsonEncode(value),
  };

  test('BASE-04: reads colecao.json, then each listed work in order', () async {
    final pedidos = <String>[];

    final colecao = await carregarColecao((arquivo) async {
      pedidos.add(arquivo);
      return arquivos[arquivo]!;
    });

    expect(pedidos, ['colecao.json', 'alfa.json', 'beta.json']);
    expect(colecao.obras.map((o) => o.id), ['alfa', 'beta']);
  });

  test(
    'BASE-04: a failing read propagates instead of a partial collection',
    () {
      final falha = StateError('beta.json indisponível');

      expect(
        carregarColecao((arquivo) async {
          if (arquivo == 'beta.json') throw falha;
          return arquivos[arquivo]!;
        }),
        throwsA(same(falha)),
      );
    },
  );

  test('BASE-04: a file that is not a JSON object is a FormatException', () {
    expect(
      carregarColecao((arquivo) async => '[]'),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('colecao.json'),
        ),
      ),
    );
  });
}
