import 'package:flutter/material.dart';

/// Tokens de cor provisórios (v0.2): azul-noite, marfim, terracota e âmbar.
/// INVARIANT: todo texto passa 4,5:1 sobre o fundo — `test/tema_test.dart` confere.
final class CoresDeLeitura {
  const CoresDeLeitura({
    required this.fundo,
    required this.texto,
    required this.secundario,
    required this.acento,
  });

  final Color fundo;
  final Color texto;
  final Color secundario;
  final Color acento;

  static const claro = CoresDeLeitura(
    fundo: Color(0xFFF6F1E7), // marfim
    texto: Color(0xFF1B2333), // azul-noite
    secundario: Color(0xFF555B66),
    acento: Color(0xFF9A4A2A), // terracota
  );

  static const escuro = CoresDeLeitura(
    fundo: Color(0xFF121826), // azul-noite
    texto: Color(0xFFEEE7DA), // marfim
    secundario: Color(0xFFB3AC9F),
    acento: Color(0xFFE2AE5B), // âmbar
  );
}

/// Fonte de leitura empacotada (OFL) — idêntica no Android e no iOS, sem rede.
const fonteDeLeitura = 'Literata';

ThemeData temaClaro() => _tema(CoresDeLeitura.claro, Brightness.light);

ThemeData temaEscuro() => _tema(CoresDeLeitura.escuro, Brightness.dark);

ThemeData _tema(CoresDeLeitura cores, Brightness brilho) {
  final esquema =
      ColorScheme.fromSeed(
        seedColor: cores.acento,
        brightness: brilho,
      ).copyWith(
        primary: cores.acento,
        surface: cores.fundo,
        onSurface: cores.texto,
        onSurfaceVariant: cores.secundario,
      );
  final base = ThemeData(colorScheme: esquema);
  final texto = base.textTheme;
  return base.copyWith(
    scaffoldBackgroundColor: cores.fundo,
    textTheme: texto.copyWith(
      bodyLarge: texto.bodyLarge?.copyWith(
        fontFamily: fonteDeLeitura,
        fontSize: 20,
        height: 1.6,
      ),
      titleLarge: texto.titleLarge?.copyWith(fontFamily: fonteDeLeitura),
      headlineSmall: texto.headlineSmall?.copyWith(fontFamily: fonteDeLeitura),
    ),
  );
}
