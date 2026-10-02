import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/preferencias/preferencias.dart';
import 'package:ponto_mobile/preferencias/preferencias_repositorio.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<PreferenciasRepositorio> _repositorioCom(
  Map<String, Object> gravado,
) async {
  SharedPreferences.setMockInitialValues(gravado);
  return PreferenciasRepositorio(await SharedPreferences.getInstance());
}

void main() {
  test('PREF-02: the four text sizes multiply by 0.9, 1.0, 1.15 and 1.3', () {
    expect(TamanhoTexto.values.map((t) => t.fator), [0.9, 1.0, 1.15, 1.3]);
  });

  test('PREF-04: nothing stored reads as Sistema + Médio', () async {
    final repositorio = await _repositorioCom({});

    final lidas = repositorio.ler();

    expect(lidas.tema, Tema.sistema);
    expect(lidas.tamanhoTexto, TamanhoTexto.medio);
  });

  test('PREF-03: what is written is read back by a new instance', () async {
    final repositorio = await _repositorioCom({});

    await repositorio.gravar(
      const Preferencias(tema: Tema.escuro, tamanhoTexto: TamanhoTexto.grande),
    );
    final lidas = PreferenciasRepositorio(
      await SharedPreferences.getInstance(),
    ).ler();

    expect(lidas.tema, Tema.escuro);
    expect(lidas.tamanhoTexto, TamanhoTexto.grande);
  });

  test(
    'PREF-04: an unknown stored value falls back for that field only',
    () async {
      final repositorio = await _repositorioCom({
        'preferencias.tema': 'roxo',
        'preferencias.tamanhoTexto': 'grande',
      });

      final lidas = repositorio.ler();

      expect(lidas.tema, Tema.sistema);
      expect(lidas.tamanhoTexto, TamanhoTexto.grande);
    },
  );

  test(
    'PREF-04: a stored value of the wrong type falls back without throwing',
    () async {
      final repositorio = await _repositorioCom({
        'preferencias.tema': 'escuro',
        'preferencias.tamanhoTexto': 3,
      });

      final lidas = repositorio.ler();

      expect(lidas.tema, Tema.escuro);
      expect(lidas.tamanhoTexto, TamanhoTexto.medio);
    },
  );
}
