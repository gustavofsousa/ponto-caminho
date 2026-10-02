import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/tema.dart';

/// Razão de contraste WCAG 2.x entre duas cores opacas.
double _contraste(Color a, Color b) {
  final (clara, escura) = a.computeLuminance() > b.computeLuminance()
      ? (a, b)
      : (b, a);
  return (clara.computeLuminance() + 0.05) / (escura.computeLuminance() + 0.05);
}

void main() {
  final temas = {
    'claro': (temaClaro(), CoresDeLeitura.claro),
    'escuro': (temaEscuro(), CoresDeLeitura.escuro),
  };

  for (final MapEntry(key: nome, value: (tema, cores)) in temas.entries) {
    test(
      'TIPO-02: $nome — every text color reaches 4.5:1 on the background',
      () {
        for (final (papel, cor) in [
          ('texto', cores.texto),
          ('secundario', cores.secundario),
          ('acento', cores.acento),
        ]) {
          expect(
            _contraste(cor, cores.fundo),
            greaterThanOrEqualTo(4.5),
            reason: '$nome/$papel',
          );
        }
      },
    );

    test('TIPO-02: $nome — the theme paints with these tokens', () {
      expect(tema.scaffoldBackgroundColor, cores.fundo);
      expect(tema.colorScheme.surface, cores.fundo);
      expect(tema.colorScheme.onSurface, cores.texto);
      expect(tema.colorScheme.onSurfaceVariant, cores.secundario);
      expect(tema.colorScheme.primary, cores.acento);
    });

    test('TIPO-01: $nome — reading text and titles use Literata', () {
      expect(tema.textTheme.bodyLarge?.fontFamily, 'Literata');
      expect(tema.textTheme.titleLarge?.fontFamily, 'Literata');
      expect(tema.textTheme.headlineSmall?.fontFamily, 'Literata');
    });
  }
}
