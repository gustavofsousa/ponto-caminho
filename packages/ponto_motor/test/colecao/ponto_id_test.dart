import 'package:ponto_motor/ponto_motor.dart';
import 'package:test/test.dart';

void main() {
  test('parses the canonical form and prints it back', () {
    const raw = 'ponto:caminho-sulco-forja/caminho/1';
    final id = PontoId.parse(raw);

    expect(id.colecao, 'caminho-sulco-forja');
    expect(id.obra, 'caminho');
    expect(id.numero, 1);
    expect(id.toString(), raw);
  });

  test('two ids with the same parts are equal', () {
    expect(PontoId.parse('ponto:c/o/7'), const PontoId('c', 'o', 7));
  });

  for (final raw in [
    'caminho/1',
    'ponto:c/o',
    'ponto:c/o/0',
    'ponto:c/o/um',
    'ponto:C/o/1',
  ]) {
    test('rejects "$raw"', () {
      expect(() => PontoId.parse(raw), throwsFormatException);
    });
  }
}
