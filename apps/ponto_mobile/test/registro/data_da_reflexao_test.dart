import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/registro/data_da_reflexao.dart';
import 'package:ponto_motor/ponto_motor.dart';

/// Um momento gravado (UTC) que, no fuso do aparelho, cai nesta data e hora.
DateTime _gravado(int ano, int mes, int dia, int hora, int minuto) =>
    DateTime(ano, mes, dia, hora, minuto).toUtc();

Reflexao _reflexao({required DateTime criadaEm, DateTime? editadaEm}) =>
    Reflexao(
      id: 'r1',
      pontoId: const PontoId('teste', 'caminho', 2),
      texto: 'Quero ser útil.',
      criadaEm: criadaEm,
      editadaEm: editadaEm,
    );

void main() {
  test('REF-07: hours and minutes are written as 6h40', () {
    expect(
      dataEHora(_gravado(2026, 3, 12, 6, 40)),
      '12 de março de 2026, 6h40',
    );
    expect(
      dataEHora(_gravado(2026, 3, 12, 21, 5)),
      '12 de março de 2026, 21h05',
    );
  });

  test('REF-07: a whole hour has no minutes', () {
    expect(dataEHora(_gravado(2026, 3, 12, 6, 0)), '12 de março de 2026, 6h');
    expect(dataEHora(_gravado(2026, 3, 12, 0, 0)), '12 de março de 2026, 0h');
  });

  test('REF-07: every month is written out in lower case', () {
    const meses = [
      'janeiro',
      'fevereiro',
      'março',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ];
    for (final (indice, mes) in meses.indexed) {
      expect(
        dataEHora(_gravado(2026, indice + 1, 1, 9, 30)),
        '1 de $mes de 2026, 9h30',
      );
    }
  });

  test('REF-07: a stored UTC moment is shown in the device time zone', () {
    final local = DateTime(2026, 3, 12, 6, 40);

    expect(dataEHora(local.toUtc()), dataEHora(local));
    expect(dataEHora(local.toUtc()), '12 de março de 2026, 6h40');
  });

  test('REF-07: a reflection never edited says when it was written', () {
    final reflexao = _reflexao(criadaEm: _gravado(2026, 3, 12, 6, 40));

    expect(escritoEm(reflexao), 'Escrito em 12 de março de 2026, 6h40.');
  });

  test('REF-04: an edited reflection also says when it was edited', () {
    final reflexao = _reflexao(
      criadaEm: _gravado(2026, 3, 12, 6, 40),
      editadaEm: _gravado(2026, 3, 14, 21, 5),
    );

    expect(
      escritoEm(reflexao),
      'Escrito em 12 de março de 2026, 6h40 · '
      'editado em 14 de março de 2026, 21h05.',
    );
  });
}
