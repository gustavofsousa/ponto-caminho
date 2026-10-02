import 'package:ponto_motor/ponto_motor.dart';
import 'package:test/test.dart';

import '../fixtures.dart';

void main() {
  final colecao = lerColecao(colecaoJson, obrasJson);

  test('returns the point with that id', () {
    final ponto = obterPonto(colecao, const PontoId('teste', 'beta', 1));

    expect(ponto?.texto, 'Texto da beta.');
  });

  test('returns null for an unknown work or number', () {
    expect(obterPonto(colecao, const PontoId('teste', 'gama', 1)), isNull);
    expect(obterPonto(colecao, const PontoId('teste', 'alfa', 99)), isNull);
  });

  test('returns null for an id from another collection', () {
    expect(obterPonto(colecao, const PontoId('outra', 'alfa', 1)), isNull);
  });

  test('the first point is the first of the first work, by order', () {
    expect(primeiroPonto(colecao)?.id, const PontoId('teste', 'alfa', 1));
  });
}
