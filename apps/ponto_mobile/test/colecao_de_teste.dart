import 'package:ponto_motor/ponto_motor.dart';

/// Coleção de teste com a forma de cada cenário do spec (A13), independente do mock em livros/:
/// - Caminho: cap. 1 Caráter 1–55 (pontos 1, 2) · cap. 2 Direção 56–80 (nenhum) ·
///   cap. 3 Oração 81–117 (81, 82) · cap. 4 sem título, intervalo aberto (nenhum).
/// - Sulco: um único ponto. Forja: nenhum ponto.
/// A ordem Caminho, Sulco, Forja não é alfabética — prova que a ordem vem da coleção.
final colecaoDeTeste = lerColecao(
  {
    'id': 'teste',
    'titulo': 'Teste',
    'versaoDados': '0.1.0',
    'obras': ['caminho', 'sulco', 'forja'],
  },
  {
    'caminho': {
      'id': 'caminho',
      'obra': {'titulo': 'Caminho'},
      'capitulos': [
        _capitulo(1, 'Caráter', 1, 55),
        _capitulo(2, 'Direção', 56, 80),
        _capitulo(3, 'Oração', 81, 117),
        _capitulo(4, null, 118, null),
      ],
      'pontos': [
        _ponto(1, 1, 'Primeiro ponto do caráter.', mock: true),
        _ponto(2, 1, 'Segundo ponto do caráter.'),
        _ponto(81, 3, 'Primeiro ponto da oração.'),
        _ponto(82, 3, 'Segundo ponto da oração.'),
      ],
    },
    'sulco': {
      'id': 'sulco',
      'obra': {'titulo': 'Sulco'},
      'capitulos': [_capitulo(1, 'Sinceridade', 1, 10)],
      'pontos': [_ponto(1, 1, 'O único ponto do sulco.')],
    },
    'forja': {
      'id': 'forja',
      'obra': {'titulo': 'Forja'},
      'capitulos': [_capitulo(1, 'Formação', 1, 5)],
      'pontos': <Object?>[],
    },
  },
);

PontoId idDe(String obra, int numero) => PontoId('teste', obra, numero);

Map<String, Object?> _capitulo(
  int numero,
  String? titulo,
  int inicial,
  int? fim,
) => {
  'numero': numero,
  'titulo': titulo,
  'pontoInicial': inicial,
  'pontoFinal': fim,
};

Map<String, Object?> _ponto(
  int numero,
  int capitulo,
  String texto, {
  bool mock = false,
}) => {
  'numero': numero,
  'capituloNumero': capitulo,
  'ordem': numero,
  'texto': texto,
  if (mock) 'nota': 'mock',
};
