/// Coleção mínima, inventada, para testes de unidade.
/// O contrato com os arquivos reais de `livros/` está em `livros_contract_test.dart`.
const Map<String, Object?> colecaoJson = {
  'id': 'teste',
  'titulo': 'Coleção de teste',
  'versaoDados': '0.1.0',
  'obras': ['alfa', 'beta'],
};

const Map<String, Map<String, Object?>> obrasJson = {
  'alfa': {
    'id': 'alfa',
    'obra': {'titulo': 'Alfa'},
    'capitulos': [
      {
        'numero': 1,
        'slug': 'primeiro',
        'titulo': 'Primeiro',
        'pontoInicial': 1,
        'pontoFinal': 2,
      },
    ],
    'pontos': [
      {'numero': 2, 'capituloNumero': 1, 'ordem': 2, 'texto': 'Segundo texto.'},
      {
        'numero': 1,
        'capituloNumero': 1,
        'ordem': 1,
        'texto': 'Primeiro texto.',
        'nota': 'mock',
      },
    ],
  },
  'beta': {
    'id': 'beta',
    'obra': {'titulo': 'Beta'},
    'capitulos': [
      {
        'numero': 1,
        'slug': 'unico',
        'titulo': 'Único',
        'pontoInicial': 1,
        'pontoFinal': 1,
      },
    ],
    'pontos': [
      {'numero': 1, 'capituloNumero': 1, 'ordem': 1, 'texto': 'Texto da beta.'},
    ],
  },
};
