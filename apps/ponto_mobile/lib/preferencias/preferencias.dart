import 'package:flutter/material.dart';

enum Tema {
  sistema(ThemeMode.system, 'Sistema'),
  claro(ThemeMode.light, 'Claro'),
  escuro(ThemeMode.dark, 'Escuro');

  const Tema(this.modo, this.rotulo);

  final ThemeMode modo;
  final String rotulo;
}

/// O fator multiplica a escala de texto do sistema — nunca a substitui.
enum TamanhoTexto {
  pequeno(0.9, 'Pequeno'),
  medio(1.0, 'Médio'),
  grande(1.15, 'Grande'),
  muitoGrande(1.3, 'Muito grande');

  const TamanhoTexto(this.fator, this.rotulo);

  final double fator;
  final String rotulo;
}

/// Como o leitor quer ler. Valor imutável; o padrão respeita o aparelho.
final class Preferencias {
  const Preferencias({required this.tema, required this.tamanhoTexto});

  static const padrao = Preferencias(
    tema: Tema.sistema,
    tamanhoTexto: TamanhoTexto.medio,
  );

  final Tema tema;
  final TamanhoTexto tamanhoTexto;

  Preferencias copyWith({Tema? tema, TamanhoTexto? tamanhoTexto}) =>
      Preferencias(
        tema: tema ?? this.tema,
        tamanhoTexto: tamanhoTexto ?? this.tamanhoTexto,
      );
}
