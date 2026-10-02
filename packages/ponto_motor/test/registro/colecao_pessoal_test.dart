import 'package:ponto_motor/ponto_motor.dart';
import 'package:test/test.dart';

final _familia = ColecaoPessoal(
  id: 'c1',
  nome: 'Família',
  pontos: const [PontoId('teste', 'caminho', 2)],
);

void main() {
  group('validarNomeDeColecao', () {
    test('COL-03: the ends are trimmed from an accepted name', () {
      expect(
        validarNomeDeColecao('  Trabalho ', [_familia]),
        isA<NomeAceito>().having((n) => n.nome, 'nome', 'Trabalho'),
      );
    });

    test('COL-03: an empty name is refused', () {
      expect(validarNomeDeColecao('', [_familia]), isA<NomeVazio>());
    });

    test('COL-03: a name made only of spaces is refused', () {
      expect(validarNomeDeColecao('   ', [_familia]), isA<NomeVazio>());
    });

    test('COL-03: a repeated name is refused ignoring case and ends', () {
      expect(
        validarNomeDeColecao('  família ', [_familia]),
        isA<NomeRepetido>(),
      );
      expect(validarNomeDeColecao('FAMÍLIA', [_familia]), isA<NomeRepetido>());
    });

    test('COL-03: up to 60 characters is accepted, 61 is refused', () {
      expect(
        validarNomeDeColecao('a' * 60, [_familia]),
        isA<NomeAceito>().having((n) => n.nome, 'nome', 'a' * 60),
      );
      expect(validarNomeDeColecao('a' * 61, [_familia]), isA<NomeLongo>());
    });

    test('COL-03: the limit counts characters, not UTF-16 units', () {
      expect(validarNomeDeColecao('🙏' * 60, [_familia]), isA<NomeAceito>());
    });

    test('COL-06: renaming a collection may keep its own name', () {
      expect(
        validarNomeDeColecao('família', [_familia], renomeando: 'c1'),
        isA<NomeAceito>().having((n) => n.nome, 'nome', 'família'),
      );
    });

    test('COL-06: renaming to the name of another collection is refused', () {
      expect(
        validarNomeDeColecao('família', [_familia], renomeando: 'c2'),
        isA<NomeRepetido>(),
      );
    });
  });

  test('PAG-01: a collection tells whether it holds a point', () {
    expect(_familia.contem(const PontoId('teste', 'caminho', 2)), isTrue);
    expect(_familia.contem(const PontoId('teste', 'caminho', 81)), isFalse);
  });
}
