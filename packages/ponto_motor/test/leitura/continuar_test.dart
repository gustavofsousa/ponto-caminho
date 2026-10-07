import 'package:ponto_motor/ponto_motor.dart';
import 'package:test/test.dart';

/// Obra "a" com os pontos 1, 2 e 3; obra "b" com o ponto 1.
final _colecao = lerColecao(
  {
    'id': 'cont',
    'titulo': 'Continue',
    'versaoDados': '0.1.0',
    'obras': ['a', 'b'],
  },
  {
    'a': {
      'id': 'a',
      'obra': {'titulo': 'A'},
      'capitulos': [_capitulo(1, 3)],
      'pontos': [_ponto(1), _ponto(2), _ponto(3)],
    },
    'b': {
      'id': 'b',
      'obra': {'titulo': 'B'},
      'capitulos': [_capitulo(1, 1)],
      'pontos': [_ponto(1)],
    },
  },
);

PontoId _id(String obra, int numero) => PontoId('cont', obra, numero);

void main() {
  test('CONT-01: the most recent point read in sequence is where to go', () {
    final ponto = pontoParaContinuar(_colecao, [
      _id('a', 2),
      _id('b', 1),
      _id('a', 1),
    ]);

    expect(ponto?.id, _id('a', 2));
  });

  test('CONT-04: nothing read in sequence means nowhere to continue', () {
    expect(pontoParaContinuar(_colecao, const []), isNull);
  });

  test(
    'CONT-05: a point missing from the books is skipped for the next one',
    () {
      final ponto = pontoParaContinuar(_colecao, [
        _id('a', 999),
        _id('z', 1),
        const PontoId('outra', 'a', 3),
        _id('a', 3),
        _id('a', 1),
      ]);

      expect(ponto?.id, _id('a', 3));
    },
  );

  test('CONT-05: when no point read exists any more, there is nowhere', () {
    expect(pontoParaContinuar(_colecao, [_id('a', 999), _id('z', 1)]), isNull);
  });
}

Map<String, Object?> _capitulo(int inicial, int fim) => {
  'numero': 1,
  'titulo': 'Capítulo',
  'pontoInicial': inicial,
  'pontoFinal': fim,
};

Map<String, Object?> _ponto(int numero) => {
  'numero': numero,
  'capituloNumero': 1,
  'ordem': numero,
  'texto': 'Texto $numero.',
};
