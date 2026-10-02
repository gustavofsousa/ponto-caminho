import 'dart:io';

import '../infra/banco_cifrado.dart';
import '../infra/guarda_da_chave.dart';
import 'banco_registro.dart';
import 'falha_no_registro.dart';
import 'registro.dart';

/// Abre o registro cifrado em [pasta], ou devolve nulo — registro indisponível.
/// Em nenhuma falha o arquivo existente é apagado, trocado ou regravado.
Future<Registro?> abrirRegistro({
  required Directory pasta,
  required CofreDeChaves cofre,
}) async {
  final arquivo = File('${pasta.path}/registro.db');
  BancoRegistro? banco;
  try {
    final chave = await obterChave(cofre, bancoExiste: await arquivo.exists());
    banco = BancoRegistro(abrirBancoCifrado(arquivo, chave));
    // Força a chave, a cifra e o schema agora: falhar na abertura é melhor que
    // falhar no meio de uma tela.
    await banco.customSelect('SELECT 1').get();
    return Registro(banco);
  } on Object catch (erro, pilha) {
    relatarFalhaNoRegistro(erro, pilha, 'ao abrir o registro');
    await banco?.close();
    return null;
  }
}
