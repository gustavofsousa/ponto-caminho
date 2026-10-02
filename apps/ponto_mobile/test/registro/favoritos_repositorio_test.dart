import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/registro/banco_registro.dart';
import 'package:ponto_mobile/registro/favoritos_repositorio.dart';

import '../colecao_de_teste.dart';
import 'banco_de_teste.dart';

void main() {
  late BancoRegistro banco;
  late RelogioDeTeste relogio;
  late FavoritosRepositorio favoritos;
  final caminho2 = idDe('caminho', 2);
  final caminho81 = idDe('caminho', 81);

  setUp(() {
    banco = abrirBancoDeTeste();
    relogio = RelogioDeTeste(DateTime.utc(2026, 3, 12, 9));
    favoritos = FavoritosRepositorio(banco, agora: relogio.call);
  });

  test('FAV-01: favouriting twice keeps a single favourite', () async {
    await favoritos.favoritar(caminho2);
    await favoritos.favoritar(caminho2);

    expect(await favoritos.observar().first, [caminho2]);
  });

  test('FAV-01: unfavouriting removes only that point', () async {
    await favoritos.favoritar(caminho2);
    await favoritos.favoritar(caminho81);

    await favoritos.desfavoritar(caminho2);

    expect(await favoritos.observar().first, [caminho81]);
  });

  test('FAV-02: the latest favourite comes first', () async {
    await favoritos.favoritar(caminho2);
    relogio.agora = DateTime.utc(2026, 3, 13, 9);
    await favoritos.favoritar(caminho81);

    expect(await favoritos.observar().first, [caminho81, caminho2]);
  });

  test(
    'FAV-02: favourites from the same moment keep the latest first',
    () async {
      await favoritos.favoritar(caminho2);
      await favoritos.favoritar(caminho81);

      expect(await favoritos.observar().first, [caminho81, caminho2]);
    },
  );

  test(
    'FAV-02: a stored id that is not a PontoId is skipped, not shown',
    () async {
      await banco
          .into(banco.favoritos)
          .insert(
            FavoritosCompanion.insert(
              pontoId: 'não é um ponto',
              favoritadoEm: relogio.agora,
            ),
          );
      await favoritos.favoritar(caminho2);

      expect(await favoritos.observar().first, [caminho2]);
    },
  );
}
