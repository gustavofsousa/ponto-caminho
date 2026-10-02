import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/registro/reflexoes_repositorio.dart';
import 'package:ponto_motor/ponto_motor.dart';

import '../colecao_de_teste.dart';
import 'banco_de_teste.dart';

final _dozeDeMarco = DateTime.utc(2026, 3, 12, 9, 40);
final _quatorzeDeMarco = DateTime.utc(2026, 3, 15, 0, 5);
final _vinteDeAbril = DateTime.utc(2026, 4, 20, 10);

void main() {
  late RelogioDeTeste relogio;
  late ReflexoesRepositorio reflexoes;
  final caminho2 = idDe('caminho', 2);
  final caminho81 = idDe('caminho', 81);

  setUp(() {
    relogio = RelogioDeTeste(_dozeDeMarco);
    reflexoes = ReflexoesRepositorio(abrirBancoDeTeste(), agora: relogio.call);
  });

  Future<List<Reflexao>> doCaminho2() => reflexoes.observar(caminho2).first;

  test(
    'REF-01: writing keeps the cleaned text, the moment and no edit',
    () async {
      await reflexoes.escrever(caminho2, '  Quero ser útil hoje.\n');

      final [reflexao] = await doCaminho2();
      expect(reflexao.pontoId, caminho2);
      expect(reflexao.texto, 'Quero ser útil hoje.');
      expect(reflexao.criadaEm.toUtc(), _dozeDeMarco);
      expect(reflexao.editadaEm, isNull);
      expect(reflexao.id, isNotEmpty);
    },
  );

  test('REF-02: an empty text is refused and nothing is stored', () async {
    await expectLater(
      reflexoes.escrever(caminho2, '  \n '),
      throwsArgumentError,
    );

    expect(await doCaminho2(), isEmpty);
  });

  test(
    'REF-04: editing changes the text and records the edit moment',
    () async {
      await reflexoes.escrever(caminho2, 'Quero ser útil hoje.');
      final [escrita] = await doCaminho2();

      relogio.agora = _quatorzeDeMarco;
      await reflexoes.editar(escrita.id, 'Quero ser útil.');

      final [editada] = await doCaminho2();
      expect(editada.id, escrita.id);
      expect(editada.texto, 'Quero ser útil.');
      expect(editada.criadaEm.toUtc(), _dozeDeMarco);
      expect(editada.editadaEm?.toUtc(), _quatorzeDeMarco);
    },
  );

  test('REF-04: saving the same text does not record an edit', () async {
    await reflexoes.escrever(caminho2, 'Quero ser útil hoje.');
    final [escrita] = await doCaminho2();

    relogio.agora = _quatorzeDeMarco;
    await reflexoes.editar(escrita.id, ' Quero ser útil hoje. ');

    final [igual] = await doCaminho2();
    expect(igual.texto, 'Quero ser útil hoje.');
    expect(igual.editadaEm, isNull);
  });

  test('REF-04: editing one reflection leaves the others untouched', () async {
    await reflexoes.escrever(caminho2, 'Do dois.');
    await reflexoes.escrever(caminho81, 'Do oitenta e um.');
    final [doDois] = await doCaminho2();

    relogio.agora = _quatorzeDeMarco;
    await reflexoes.editar(doDois.id, 'Do dois, editada.');

    final [outra] = await reflexoes.observar(caminho81).first;
    expect(outra.texto, 'Do oitenta e um.');
    expect(outra.editadaEm, isNull);
  });

  test('REF-04: editing to an empty text is refused', () async {
    await reflexoes.escrever(caminho2, 'Quero ser útil hoje.');
    final [escrita] = await doCaminho2();

    await expectLater(reflexoes.editar(escrita.id, ' '), throwsArgumentError);

    final [intacta] = await doCaminho2();
    expect(intacta.texto, 'Quero ser útil hoje.');
    expect(intacta.editadaEm, isNull);
  });

  test('REF-05: deleting removes only that reflection', () async {
    await reflexoes.escrever(caminho2, 'Primeira.');
    await reflexoes.escrever(caminho2, 'Segunda.');
    final [primeira, _] = await doCaminho2();

    await reflexoes.excluir(primeira.id);

    final restantes = await doCaminho2();
    expect(restantes.map((r) => r.texto), ['Segunda.']);
  });

  test('REF-06: a point lists only its reflections, oldest first', () async {
    relogio.agora = _vinteDeAbril;
    await reflexoes.escrever(caminho2, 'Escrita em abril.');
    relogio.agora = _dozeDeMarco;
    await reflexoes.escrever(caminho2, 'Escrita em março.');
    await reflexoes.escrever(caminho81, 'De outro ponto.');

    final textos = (await doCaminho2()).map((r) => r.texto);
    expect(textos, ['Escrita em março.', 'Escrita em abril.']);
  });

  test(
    'REF-06: reflections written at the same moment keep their order',
    () async {
      for (final texto in ['Um.', 'Dois.', 'Três.']) {
        await reflexoes.escrever(caminho2, texto);
      }

      expect((await doCaminho2()).map((r) => r.texto), [
        'Um.',
        'Dois.',
        'Três.',
      ]);
    },
  );

  test('REF-06: the list follows each write', () async {
    final emitidas = <List<String>>[];
    final assinatura = reflexoes
        .observar(caminho2)
        .listen((lista) => emitidas.add([for (final r in lista) r.texto]));
    addTearDown(assinatura.cancel);
    await pumpEventQueue();

    await reflexoes.escrever(caminho2, 'Quero ser útil hoje.');
    await pumpEventQueue();

    expect(emitidas, [
      isEmpty,
      ['Quero ser útil hoje.'],
    ]);
  });
}
