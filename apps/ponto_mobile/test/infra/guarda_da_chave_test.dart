import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/infra/guarda_da_chave.dart';

import 'cofre_de_teste.dart';

void main() {
  test('CIFRA-03: a new registro gets a new key, stored before use', () async {
    final cofre = CofreDeTeste();

    final chave = await obterChave(cofre, bancoExiste: false);

    expect(chave, matches(RegExp(r'^[0-9a-f]{64}$')));
    expect(cofre.gravadas, [chave]);
  });

  test('CIFRA-03: a stored key is reused and nothing is written', () async {
    final guardada = 'c3' * 32;
    final cofre = CofreDeTeste(chave: guardada);

    expect(await obterChave(cofre, bancoExiste: true), guardada);
    expect(await obterChave(cofre, bancoExiste: false), guardada);
    expect(cofre.gravadas, isEmpty);
  });

  test('CIFRA-03: two new registros never share a key', () async {
    final primeira = await obterChave(CofreDeTeste(), bancoExiste: false);
    final segunda = await obterChave(CofreDeTeste(), bancoExiste: false);

    expect(primeira, isNot(segunda));
  });

  test('CIFRA-04: no key for an existing registro writes no new key', () async {
    final cofre = CofreDeTeste();

    await expectLater(
      obterChave(cofre, bancoExiste: true),
      throwsA(isA<ChaveIndisponivel>()),
    );
    expect(cofre.gravadas, isEmpty);
  });

  for (final erro in <Object>[
    PlatformException(code: 'unwrap-key'),
    const FileSystemExceptionLike(),
  ]) {
    test('CIFRA-04: a keystore that fails to read (${erro.runtimeType}) '
        'writes no new key', () async {
      final cofre = CofreDeTeste(erroAoLer: erro);

      await expectLater(
        obterChave(cofre, bancoExiste: false),
        throwsA(same(erro)),
      );
      expect(cofre.gravadas, isEmpty);
    });
  }
}

/// Uma falha qualquer, que não é do Flutter nem do domínio.
final class FileSystemExceptionLike implements Exception {
  const FileSystemExceptionLike();
}
