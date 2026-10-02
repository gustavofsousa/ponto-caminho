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

  group('BASE-01: a field of the wrong type is a FormatException', () {
    test('an obra id in colecao.json that is not text', () {
      final colecao = {
        ...colecaoJson,
        'obras': ['alfa', 7],
      };

      expect(
        () => lerColecao(colecao, obrasJson),
        throwsA(_formatoCom(['colecao.json', 'id de obra'])),
      );
    });

    test('a chapter title that is not text names the work', () {
      final quebrada = _comCapitulo('alfa', {
        'numero': 1,
        'slug': 'primeiro',
        'titulo': 3,
        'pontoInicial': 1,
        'pontoFinal': 2,
      });

      expect(
        () => lerColecao(colecaoJson, quebrada),
        throwsA(_formatoCom(['alfa', 'titulo'])),
      );
    });

    test('a chapter slug that is not text names the work', () {
      final quebrada = _comCapitulo('alfa', {
        'numero': 1,
        'slug': false,
        'titulo': 'Primeiro',
        'pontoInicial': 1,
        'pontoFinal': 2,
      });

      expect(
        () => lerColecao(colecaoJson, quebrada),
        throwsA(_formatoCom(['alfa', 'slug'])),
      );
    });
  });

  test('BASE-02: a repeated point number names the work and the number', () {
    final quebrada = _comPontos('alfa', [
      {'numero': 1, 'capituloNumero': 1, 'ordem': 1, 'texto': 'Um.'},
      {'numero': 1, 'capituloNumero': 1, 'ordem': 2, 'texto': 'Outro um.'},
    ]);

    expect(
      () => lerColecao(colecaoJson, quebrada),
      throwsA(_formatoCom(['alfa', 'ponto 1 repetido'])),
    );
  });

  test(
    'BASE-03: a point in a missing chapter names the point and the chapter',
    () {
      final quebrada = _comPontos('alfa', [
        {'numero': 1, 'capituloNumero': 1, 'ordem': 1, 'texto': 'Um.'},
        {'numero': 2, 'capituloNumero': 9, 'ordem': 2, 'texto': 'Dois.'},
      ]);

      expect(
        () => lerColecao(colecaoJson, quebrada),
        throwsA(_formatoCom(['alfa', 'ponto 2', 'capítulo 9'])),
      );
    },
  );
}

Map<String, Object?> _comCapitulo(
  String obraId,
  Map<String, Object?> capitulo,
) => {
  ...obrasJson,
  obraId: {
    ...obrasJson[obraId]!,
    'capitulos': [capitulo],
  },
};

Map<String, Object?> _comPontos(
  String obraId,
  List<Map<String, Object?>> pontos,
) => {
  ...obrasJson,
  obraId: {...obrasJson[obraId]!, 'pontos': pontos},
};

Matcher _formatoCom(List<String> trechos) => isA<FormatException>().having(
  (e) => e.message,
  'message',
  allOf([for (final trecho in trechos) contains(trecho)]),
);
