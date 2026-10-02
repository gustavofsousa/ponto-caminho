import 'package:ponto_motor/ponto_motor.dart';
import 'package:test/test.dart';

void main() {
  test('REF-02: empty text is not a reflection', () {
    expect(limparTextoDeReflexao(''), isNull);
  });

  test('REF-02: only spaces and line breaks is not a reflection', () {
    expect(limparTextoDeReflexao('  \n\t \n '), isNull);
  });

  test('REF-02: spaces and line breaks at the ends are removed', () {
    expect(limparTextoDeReflexao('  Quero ser útil.\n'), 'Quero ser útil.');
  });

  test('REF-02: line breaks inside the text are kept', () {
    expect(
      limparTextoDeReflexao('\nPrimeira linha.\n\nSegunda linha.  '),
      'Primeira linha.\n\nSegunda linha.',
    );
  });
}
