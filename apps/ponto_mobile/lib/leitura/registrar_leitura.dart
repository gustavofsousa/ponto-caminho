import 'package:ponto_motor/ponto_motor.dart';

import '../registro/falha_no_registro.dart';
import '../registro/registro.dart';

/// Grava que o leitor abriu [ponto]. Nunca atrapalha a leitura: sem registro
/// não faz nada, e uma falha vai ao log só pelo tipo (AD-009) — a leitura não é
/// algo que o leitor escreveu, então não há o que avisar nem refazer.
Future<void> registrarLeitura(
  Registro? registro,
  PontoId ponto,
  OrigemDaLeitura origem,
) async {
  if (registro == null) return;
  try {
    await registro.leituras.registrar(ponto, origem);
  } on Object catch (erro, pilha) {
    relatarFalhaNoRegistro(erro, pilha, 'ao registrar uma leitura');
  }
}
