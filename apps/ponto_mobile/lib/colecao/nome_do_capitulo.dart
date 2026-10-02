import 'package:ponto_motor/ponto_motor.dart';

/// Capítulo ainda sem título conferido aparece pelo número.
String nomeDoCapitulo(Capitulo capitulo) =>
    capitulo.titulo ?? 'Capítulo ${capitulo.numero}';
