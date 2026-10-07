import '../leitura/leituras_repositorio.dart';
import 'banco_registro.dart';
import 'colecoes_repositorio.dart';
import 'favoritos_repositorio.dart';
import 'reflexoes_repositorio.dart';

/// Tudo o que o leitor guarda — e o que leu —, sobre um único banco cifrado.
final class Registro {
  Registro(this._banco, {DateTime Function() agora = DateTime.now})
    : reflexoes = ReflexoesRepositorio(_banco, agora: agora),
      favoritos = FavoritosRepositorio(_banco, agora: agora),
      colecoes = ColecoesRepositorio(_banco, agora: agora),
      leituras = LeiturasRepositorio(_banco, agora: agora);

  final BancoRegistro _banco;
  final ReflexoesRepositorio reflexoes;
  final FavoritosRepositorio favoritos;
  final ColecoesRepositorio colecoes;
  final LeiturasRepositorio leituras;

  Future<void> fechar() => _banco.close();
}
