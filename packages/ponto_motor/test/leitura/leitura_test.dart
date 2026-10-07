import 'package:ponto_motor/ponto_motor.dart';
import 'package:test/test.dart';

void main() {
  test('LEI-02: the v0.4 origins are a closed set of five', () {
    expect(OrigemDaLeitura.values.map((o) => o.name), [
      'biblioteca',
      'continuacao',
      'aleatorio',
      'favoritos',
      'colecao',
    ]);
  });

  test('CONT-01: only the library and continue are reading in sequence', () {
    expect(
      {for (final o in OrigemDaLeitura.values) o.name: o.emSequencia},
      {
        'biblioteca': true,
        'continuacao': true,
        'aleatorio': false,
        'favoritos': false,
        'colecao': false,
      },
    );
  });
}
