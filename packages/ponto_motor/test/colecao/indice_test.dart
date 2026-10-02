import 'package:ponto_motor/ponto_motor.dart';
import 'package:test/test.dart';

void main() {
  test('LER-02: a chapter with a full range counts its points', () {
    final obra = _obra(capitulos: [_capitulo(1, 1, 55)]);

    expect(obra.capitulo(1)!.totalPontos, 55);
  });

  test('LER-02: a chapter whose range is still open has no count', () {
    final obra = _obra(
      capitulos: [_capitulo(17, 387, null), _capitulo(18, null, 416)],
    );

    expect(obra.capitulo(17)!.totalPontos, isNull);
    expect(obra.capitulo(18)!.totalPontos, isNull);
  });

  test('LER-02: a range bound that is not an integer is a FormatException', () {
    expect(
      () => _obra(capitulos: [_capitulo(1, '1', 55)]),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          allOf(contains('obra-teste'), contains('pontoInicial')),
        ),
      ),
    );
  });

  test(
    'LER-03: pontosDoCapitulo returns only that chapter, in reading order',
    () {
      final obra = _obra(
        capitulos: [_capitulo(1, 1, 2), _capitulo(2, 3, 3)],
        pontos: [
          _ponto(2, capitulo: 1),
          _ponto(3, capitulo: 2),
          _ponto(1, capitulo: 1),
        ],
      );

      expect(obra.pontosDoCapitulo(1).map((p) => p.id.numero), [1, 2]);
    },
  );

  test('LER-03: a chapter with no available points has an empty list', () {
    final obra = _obra(
      capitulos: [_capitulo(1, 1, 2), _capitulo(2, 3, 3)],
      pontos: [_ponto(1, capitulo: 1)],
    );

    expect(obra.pontosDoCapitulo(2), isEmpty);
  });
}

Obra _obra({
  required List<Map<String, Object?>> capitulos,
  List<Map<String, Object?>> pontos = const [],
}) {
  final colecao = lerColecao(
    {
      'id': 'teste',
      'titulo': 'Teste',
      'versaoDados': '0.1.0',
      'obras': ['obra-teste'],
    },
    {
      'obra-teste': {
        'id': 'obra-teste',
        'obra': {'titulo': 'Obra'},
        'capitulos': capitulos,
        'pontos': pontos,
      },
    },
  );
  return colecao.obras.single;
}

Map<String, Object?> _capitulo(int numero, Object? inicial, Object? fim) => {
  'numero': numero,
  'titulo': 'Capítulo $numero',
  'pontoInicial': inicial,
  'pontoFinal': fim,
};

Map<String, Object?> _ponto(int numero, {required int capitulo}) => {
  'numero': numero,
  'capituloNumero': capitulo,
  'ordem': numero,
  'texto': 'Texto $numero.',
};
