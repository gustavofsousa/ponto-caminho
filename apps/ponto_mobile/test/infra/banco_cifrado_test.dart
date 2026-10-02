import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/infra/banco_cifrado.dart';
import 'package:ponto_mobile/registro/banco_registro.dart';
import 'package:ponto_mobile/registro/registro.dart';
import 'package:sqlite3/sqlite3.dart';

import '../colecao_de_teste.dart';

final _chave = 'a1' * 32;
const _segredo = 'silêncio-que-ninguém-lê';

/// Os [bytes] contêm [texto] em UTF-8?
bool _contem(List<int> bytes, String texto) =>
    latin1.decode(bytes).contains(latin1.decode(utf8.encode(texto)));

/// SQLite que não conhece `PRAGMA cipher` — como um SQLite comum, sem cifra.
final class _SqliteSemCifra implements Database {
  _SqliteSemCifra([this._real]);

  final Database? _real;
  final executadas = <String>[];

  @override
  void execute(String sql, [List<Object?> parameters = const []]) {
    executadas.add(sql);
    _real?.execute(sql, parameters);
  }

  @override
  ResultSet select(String sql, [List<Object?> parameters = const []]) {
    executadas.add(sql);
    return ResultSet(const [], const [], const []);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late File arquivo;

  setUp(() async {
    final pasta = await Directory.systemTemp.createTemp('cifra');
    addTearDown(() => pasta.delete(recursive: true));
    arquivo = File('${pasta.path}/registro.db');
  });

  test('CIFRA-01: what is written is unreadable in the file', () async {
    final registro = Registro(
      BancoRegistro(abrirBancoCifrado(arquivo, _chave)),
    );
    await registro.reflexoes.escrever(idDe('caminho', 2), _segredo);
    final banco = BancoRegistro(abrirBancoCifrado(arquivo, _chave));
    final cifra = await banco.customSelect('PRAGMA cipher').getSingle();
    await banco.close();
    await registro.fechar();

    final bytes = await arquivo.readAsBytes();
    expect(bytes, isNotEmpty);
    expect(_contem(bytes, _segredo), isFalse);
    expect(_contem(bytes, 'SQLite format 3'), isFalse);
    expect(
      cifra.data.values.single,
      isA<String>().having((c) => c, 'cifra', isNotEmpty),
    );
  });

  test('CIFRA-01: another key cannot read the file', () async {
    final registro = Registro(
      BancoRegistro(abrirBancoCifrado(arquivo, _chave)),
    );
    await registro.reflexoes.escrever(idDe('caminho', 2), _segredo);
    await registro.fechar();

    final intruso = BancoRegistro(abrirBancoCifrado(arquivo, 'b2' * 32));
    addTearDown(intruso.close);
    await expectLater(
      intruso.select(intruso.reflexoes).get(),
      throwsA(anything),
    );
  });

  test('CIFRA-02: a SQLite without a cipher is refused', () {
    final semCifra = _SqliteSemCifra();

    expect(() => prepararCifra(semCifra, _chave), throwsStateError);
  });

  test(
    'CIFRA-02: without a cipher the registro opens no table at all',
    () async {
      final banco = BancoRegistro(
        NativeDatabase(
          arquivo,
          setup: (real) => prepararCifra(_SqliteSemCifra(real), _chave),
        ),
      );
      await expectLater(banco.select(banco.reflexoes).get(), throwsStateError);
      await banco.close();

      final conferencia = sqlite3.open(arquivo.path)
        ..execute("PRAGMA key = '$_chave';");
      addTearDown(conferencia.close);
      expect(
        conferencia.select(
          "SELECT name FROM sqlite_master WHERE type = 'table'",
        ),
        isEmpty,
      );
    },
  );

  test('CIFRA-02: a key outside the expected shape is refused before use', () {
    final semCifra = _SqliteSemCifra();

    expect(
      () => prepararCifra(semCifra, "x'; DROP TABLE reflexoes; --"),
      throwsArgumentError,
    );
    expect(() => prepararCifra(semCifra, 'A1' * 32), throwsArgumentError);
    expect(semCifra.executadas, isEmpty);
  });
}
