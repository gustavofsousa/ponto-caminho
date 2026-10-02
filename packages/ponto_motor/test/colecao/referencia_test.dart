import 'package:ponto_motor/ponto_motor.dart';
import 'package:test/test.dart';

import '../fixtures.dart';

void main() {
  final colecao = lerColecao(colecaoJson, obrasJson);

  test('names the work, the chapter and the number', () {
    final referencia = colecao.referenciaDe(const PontoId('teste', 'alfa', 2));

    expect(referencia?.obra, 'Alfa');
    expect(referencia?.capitulo, 'Primeiro');
    expect(referencia?.numero, 2);
  });

  test('is null for a point the collection does not have', () {
    expect(colecao.referenciaDe(const PontoId('teste', 'alfa', 99)), isNull);
  });
}
