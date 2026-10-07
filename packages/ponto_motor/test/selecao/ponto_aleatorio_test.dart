import 'dart:math';

import 'package:ponto_motor/ponto_motor.dart';
import 'package:test/test.dart';

/// Obras em ordem que não é a alfabética, para provar que a ordem vem da coleção:
/// - "b": 5 pontos (1–5), chegam fora de ordem — prova a ordem de leitura.
/// - "a": 12 pontos (1–12).
/// - "c": um único ponto. "d": estrutura, nenhum ponto disponível.
final _colecao = lerColecao(
  {
    'id': 'agora',
    'titulo': 'Agora',
    'versaoDados': '0.1.0',
    'obras': ['b', 'a', 'c', 'd'],
  },
  {
    'b': _obra('b', [3, 1, 5, 2, 4]),
    'a': _obra('a', [for (var n = 1; n <= 12; n++) n]),
    'c': _obra('c', [1]),
    'd': _obra('d', [], fim: 9),
  },
);

PontoId _id(String obra, int numero) => PontoId('agora', obra, numero);

/// Fonte que devolve sempre o mesmo índice e anota cada limite pedido.
final class _FonteFixa implements Random {
  _FonteFixa(this.indice);

  final int indice;
  final limites = <int>[];

  @override
  int nextInt(int max) {
    limites.add(max);
    return indice;
  }

  @override
  bool nextBool() => throw UnimplementedError();

  @override
  double nextDouble() => throw UnimplementedError();
}

/// O ponto devolvido para cada valor possível da fonte, na ordem dos índices.
List<PontoId?> _todosOsSorteios({
  String? obra,
  Iterable<PontoId> recentes = const [],
}) {
  final sonda = _FonteFixa(0);
  pontoAleatorio(_colecao, aleatorio: sonda, obra: obra, recentes: recentes);
  final candidatos = sonda.limites.single;
  return [
    for (var k = 0; k < candidatos; k++)
      pontoAleatorio(
        _colecao,
        aleatorio: _FonteFixa(k),
        obra: obra,
        recentes: recentes,
      )?.id,
  ];
}

void main() {
  test(
    'AGORA-01: index k is the k-th point in collection and reading order',
    () {
      final fonte = _FonteFixa(0);
      pontoAleatorio(_colecao, aleatorio: fonte);

      expect(fonte.limites, [18]);
      expect(_todosOsSorteios(), [
        for (var n = 1; n <= 5; n++) _id('b', n),
        for (var n = 1; n <= 12; n++) _id('a', n),
        _id('c', 1),
      ]);
    },
  );

  test('AGORA-02: the ten most recent points read are left out', () {
    final recentes = [for (var n = 1; n <= 11; n++) _id('a', n)];

    final sorteados = _todosOsSorteios(recentes: recentes);

    expect(sorteados, hasLength(18 - 10));
    for (var n = 1; n <= 10; n++) {
      expect(sorteados, isNot(contains(_id('a', n))), reason: 'a/$n');
    }
    expect(sorteados, contains(_id('a', 11)));
  });

  test('AGORA-03: rereading the same point counts once', () {
    final recentes = [
      _id('a', 1),
      _id('a', 1),
      _id('a', 1),
      for (var n = 2; n <= 10; n++) _id('a', n),
      _id('a', 11),
    ];

    final sorteados = _todosOsSorteios(recentes: recentes);

    for (var n = 1; n <= 10; n++) {
      expect(sorteados, isNot(contains(_id('a', n))), reason: 'a/$n');
    }
    expect(sorteados, contains(_id('a', 11)));
  });

  test(
    'AGORA-04: with every point of the work recent, the oldest read comes back',
    () {
      final recentes = [
        _id('b', 3),
        _id('a', 1),
        _id('b', 1),
        _id('b', 5),
        _id('a', 2),
        _id('b', 2),
        _id('b', 4),
      ];

      expect(_todosOsSorteios(obra: 'b', recentes: recentes), [_id('b', 4)]);
    },
  );

  test('AGORA-05: the work filter keeps every draw inside that work', () {
    expect(_todosOsSorteios(obra: 'a'), [
      for (var n = 1; n <= 12; n++) _id('a', n),
    ]);
  });

  test('AGORA-05: a work with no point available gives no point', () {
    expect(
      pontoAleatorio(_colecao, aleatorio: _FonteFixa(0), obra: 'd'),
      isNull,
    );
  });

  test('a single-point work gives that point even if it was the last read', () {
    expect(_todosOsSorteios(obra: 'c', recentes: [_id('c', 1)]), [_id('c', 1)]);
  });
}

Map<String, Object?> _obra(String id, List<int> numeros, {int? fim}) => {
  'id': id,
  'obra': {'titulo': id.toUpperCase()},
  'capitulos': [
    {
      'numero': 1,
      'titulo': 'Capítulo',
      'pontoInicial': 1,
      'pontoFinal': fim ?? numeros.length,
    },
  ],
  'pontos': [
    for (final n in numeros)
      {'numero': n, 'capituloNumero': 1, 'ordem': n, 'texto': 'Texto $id $n.'},
  ],
};
