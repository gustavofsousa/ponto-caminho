import 'package:ponto_motor/ponto_motor.dart';
import 'package:test/test.dart';

import '../fixtures.dart';

void main() {
  test('reads works in the order the collection declares', () {
    final colecao = lerColecao(colecaoJson, obrasJson);

    expect(colecao.id, 'teste');
    expect(colecao.obras.map((o) => o.id), ['alfa', 'beta']);
  });

  test('a point knows its id, chapter and whether it is mock', () {
    final ponto = lerColecao(colecaoJson, obrasJson).obras.first.pontos.first;

    expect(ponto.id, const PontoId('teste', 'alfa', 1));
    expect(ponto.capituloNumero, 1);
    expect(ponto.texto, 'Primeiro texto.');
    expect(ponto.isMock, isTrue);
  });

  test('fails when the collection lists a work that was not provided', () {
    expect(
      () => lerColecao(colecaoJson, {'alfa': obrasJson['alfa']!}),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('beta'),
        ),
      ),
    );
  });

  test('fails on a point without text', () {
    final quebrada = {
      ...obrasJson,
      'alfa': {
        ...obrasJson['alfa']!,
        'pontos': [
          {'numero': 1, 'capituloNumero': 1, 'ordem': 1},
        ],
      },
    };

    expect(() => lerColecao(colecaoJson, quebrada), throwsFormatException);
  });
}
