import 'package:ponto_motor/ponto_motor.dart';
import 'package:test/test.dart';

/// Obra "a": cap. 1 = 1–3 (disponíveis 1, 2) · cap. 2 = 4–6 (nenhum) · cap. 3 = 7–9 (7, 8).
/// Obra "b" vem logo depois, para provar que a sequência não atravessa obras.
/// Os pontos de "a" chegam fora de ordem, para provar que a sequência segue `ordem`.
final _colecao = lerColecao(
  {
    'id': 'seq',
    'titulo': 'Sequência',
    'versaoDados': '0.1.0',
    'obras': ['a', 'b'],
  },
  {
    'a': {
      'id': 'a',
      'obra': {'titulo': 'A'},
      'capitulos': [_capitulo(1, 1, 3), _capitulo(2, 4, 6), _capitulo(3, 7, 9)],
      'pontos': [_ponto(8, 3), _ponto(1, 1), _ponto(7, 3), _ponto(2, 1)],
    },
    'b': {
      'id': 'b',
      'obra': {'titulo': 'B'},
      'capitulos': [_capitulo(1, 1, 1)],
      'pontos': [_ponto(1, 1)],
    },
  },
);

PontoId _id(String obra, int numero) => PontoId('seq', obra, numero);

void main() {
  test('LER-07: next inside a chapter is the following point', () {
    expect(proximoPonto(_colecao, _id('a', 1))?.id, _id('a', 2));
  });

  test(
    'LER-07: next from the end of a chapter crosses to the next point available',
    () {
      expect(proximoPonto(_colecao, _id('a', 2))?.id, _id('a', 7));
    },
  );

  test('LER-08: previous mirrors next, across the chapter gap too', () {
    expect(pontoAnterior(_colecao, _id('a', 7))?.id, _id('a', 2));
    expect(pontoAnterior(_colecao, _id('a', 2))?.id, _id('a', 1));
  });

  test('LER-09: the first point of a work has no previous', () {
    expect(pontoAnterior(_colecao, _id('a', 1)), isNull);
  });

  test(
    'LER-09: the last point of a work has no next, even with a work after it',
    () {
      expect(proximoPonto(_colecao, _id('a', 8)), isNull);
    },
  );

  test('LER-09: an unknown id has neither next nor previous', () {
    for (final id in [
      _id('a', 99),
      _id('z', 1),
      const PontoId('outra', 'a', 1),
    ]) {
      expect(proximoPonto(_colecao, id), isNull, reason: '$id');
      expect(pontoAnterior(_colecao, id), isNull, reason: '$id');
    }
  });
}

Map<String, Object?> _capitulo(int numero, int inicial, int fim) => {
  'numero': numero,
  'titulo': 'Capítulo $numero',
  'pontoInicial': inicial,
  'pontoFinal': fim,
};

Map<String, Object?> _ponto(int numero, int capitulo) => {
  'numero': numero,
  'capituloNumero': capitulo,
  'ordem': numero,
  'texto': 'Texto $numero.',
};
