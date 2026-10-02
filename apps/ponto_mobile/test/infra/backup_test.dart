import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _dominios = ['root', 'file', 'database', 'sharedpref', 'external'];

String _ler(String caminho) => File(caminho).readAsStringSync();

/// O conteúdo de `<tag>…</tag>` em [xml], ou vazio se a tag não existir.
String _bloco(String xml, String tag) =>
    RegExp('<$tag>(.*?)</$tag>', dotAll: true).firstMatch(xml)?.group(1) ?? '';

void main() {
  final manifesto = _ler('android/app/src/main/AndroidManifest.xml');
  final aplicacao = RegExp('<application[^>]*>').firstMatch(manifesto)![0]!;

  test('CIFRA-05: the app turns Android backup off', () {
    expect(aplicacao, contains('android:allowBackup="false"'));
  });

  test('CIFRA-05: extraction rules point to the app rules file', () {
    expect(
      aplicacao,
      contains('android:dataExtractionRules="@xml/regras_de_extracao"'),
    );
  });

  final regras = _ler('android/app/src/main/res/xml/regras_de_extracao.xml');
  for (final modalidade in ['cloud-backup', 'device-transfer']) {
    test('CIFRA-05: $modalidade excludes every app data domain', () {
      final bloco = _bloco(regras, modalidade);
      for (final dominio in _dominios) {
        expect(
          bloco,
          contains('<exclude domain="$dominio" path="." />'),
          reason: '$modalidade deveria excluir $dominio',
        );
      }
      expect(bloco, isNot(contains('<include')));
    });
  }
}
