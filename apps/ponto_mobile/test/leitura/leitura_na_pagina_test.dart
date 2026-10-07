import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/colecao/biblioteca_page.dart';
import 'package:ponto_mobile/colecao/ponto_page.dart';
import 'package:ponto_mobile/registro/banco_registro.dart';
import 'package:ponto_mobile/registro/falha_no_registro.dart';
import 'package:ponto_mobile/registro/registro.dart';
import 'package:ponto_mobile/tema.dart';
import 'package:ponto_motor/ponto_motor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../colecao_de_teste.dart';
import '../montar_tela.dart';
import '../registro/banco_de_teste.dart';

void main() {
  late BancoRegistro banco;
  late RelogioDeTeste relogio;
  late Registro registro;
  final caminho2 = idDe('caminho', 2);
  final caminho81 = idDe('caminho', 81);
  final sulco1 = idDe('sulco', 1);

  setUp(() {
    banco = abrirBancoDeTela();
    relogio = RelogioDeTeste(DateTime.utc(2026, 10, 7, 9, 15));
    registro = Registro(banco, agora: relogio.call);
  });

  /// As leituras gravadas, na ordem de gravação: (ponto, origem).
  Future<List<(String, OrigemDaLeitura)>> leituras(WidgetTester tester) async {
    final linhas = await tester.runAsync(
      () => (banco.select(
        banco.leituras,
      )..orderBy([(l) => OrderingTerm.asc(l.id)])).get(),
    );
    return [for (final l in linhas!) (l.pontoId, l.origem)];
  }

  Future<void> abrirPonto(
    WidgetTester tester,
    PontoId id,
    OrigemDaLeitura origem, {
    Registro? outroRegistro,
  }) async {
    await montarTela(
      tester,
      PontoPage(
        colecao: colecaoDeTeste,
        inicial: obterPonto(colecaoDeTeste, id)!,
        origem: origem,
      ),
      registro: outroRegistro ?? registro,
    );
    await tester.pumpAndSettle();
  }

  Future<void> abrirBiblioteca(WidgetTester tester) async {
    await montarTela(
      tester,
      BibliotecaPage(colecao: colecaoDeTeste),
      registro: registro,
    );
    await tester.pumpAndSettle();
  }

  Future<void> tocar(WidgetTester tester, String texto) async {
    await tester.tap(find.text(texto));
    await tester.pumpAndSettle();
  }

  testWidgetsComRegistro(
    'LEI-01: opening a point from the library records it, with origin and time',
    (tester) async {
      await abrirBiblioteca(tester);
      await tocar(tester, 'Caminho');
      await tocar(tester, 'Caráter');
      await tocar(tester, 'Segundo ponto do caráter.');

      final linha = (await tester.runAsync(
        () => banco.select(banco.leituras).get(),
      ))!.single;
      expect(linha.pontoId, caminho2.toString());
      expect(linha.origem, OrigemDaLeitura.biblioteca);
      expect(linha.lidoEm, DateTime.utc(2026, 10, 7, 9, 15));
    },
  );

  testWidgetsComRegistro('LEI-02: a point opened from Favoritos says so', (
    tester,
  ) async {
    await tester.runAsync(() => registro.favoritos.favoritar(sulco1));
    await abrirBiblioteca(tester);
    await tocar(tester, 'Favoritos');
    await tocar(tester, 'Sulco, capítulo Sinceridade, ponto 1');

    expect(await leituras(tester), [
      (sulco1.toString(), OrigemDaLeitura.favoritos),
    ]);
  });

  testWidgetsComRegistro(
    'LEI-02: a point opened from a personal collection says so',
    (tester) async {
      await tester.runAsync(
        () => semearColecoes(
          registro,
          banco,
          relogio,
          ['Família'],
          pontos: {
            'Família': [caminho81],
          },
        ),
      );
      await abrirBiblioteca(tester);
      await tocar(tester, 'Coleções');
      await tocar(tester, 'Família');
      await tocar(tester, 'Caminho, capítulo Oração, ponto 81');

      expect(await leituras(tester), [
        (caminho81.toString(), OrigemDaLeitura.colecao),
      ]);
    },
  );

  testWidgetsComRegistro(
    'LEI-03: Próximo and Anterior record each point shown, as the library',
    (tester) async {
      await abrirPonto(tester, caminho2, OrigemDaLeitura.aleatorio);

      await tocar(tester, 'Próximo');
      await tocar(tester, 'Anterior');

      expect(await leituras(tester), [
        (caminho2.toString(), OrigemDaLeitura.aleatorio),
        (caminho81.toString(), OrigemDaLeitura.biblioteca),
        (caminho2.toString(), OrigemDaLeitura.biblioteca),
      ]);
    },
  );

  testWidgetsComRegistro(
    'LEI-03: quick Próximo taps record every point shown, in order',
    (tester) async {
      await abrirPonto(tester, idDe('caminho', 1), OrigemDaLeitura.biblioteca);

      // Um quadro entre os toques — sem esperar a gravação nem a tela assentar.
      await tester.tap(find.text('Próximo'));
      await tester.pump();
      await tester.tap(find.text('Próximo'));
      await tester.pump();
      await tester.tap(find.text('Próximo'));
      await tester.pumpAndSettle();

      expect(find.text('Segundo ponto da oração.'), findsOneWidget);
      expect(await leituras(tester), [
        (idDe('caminho', 1).toString(), OrigemDaLeitura.biblioteca),
        (caminho2.toString(), OrigemDaLeitura.biblioteca),
        (caminho81.toString(), OrigemDaLeitura.biblioteca),
        (idDe('caminho', 82).toString(), OrigemDaLeitura.biblioteca),
      ]);
    },
  );

  testWidgetsComRegistro(
    'LEI-04: theme, text size and a saved reflection record nothing more',
    (tester) async {
      // O tema troca acima da página, como o MaterialApp faz quando o leitor
      // muda o tema nas preferências: a página continua a mesma, só depende dele.
      final tema = ValueNotifier(temaClaro());
      addTearDown(tema.dispose);
      await montarTela(
        tester,
        ValueListenableBuilder<ThemeData>(
          valueListenable: tema,
          builder: (_, dados, pagina) => Theme(data: dados, child: pagina!),
          child: PontoPage(
            colecao: colecaoDeTeste,
            inicial: obterPonto(colecaoDeTeste, caminho2)!,
            origem: OrigemDaLeitura.biblioteca,
          ),
        ),
        registro: registro,
      );
      await tester.pumpAndSettle();
      expect(await leituras(tester), hasLength(1));

      tema.value = temaEscuro();
      await tester.pumpAndSettle();
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpAndSettle();
      await tocar(tester, 'Escrever uma reflexão');
      await tester.enterText(find.byType(TextField), 'Fica comigo.');
      await tester.pump();
      await tester.tap(find.widgetWithText(TextButton, 'Guardar'));
      await tester.pumpAndSettle();

      expect(
        Theme.of(tester.element(find.text('Fica comigo.'))).brightness,
        Brightness.dark,
      );
      expect(await leituras(tester), [
        (caminho2.toString(), OrigemDaLeitura.biblioteca),
      ]);
    },
  );

  testWidgetsComRegistro(
    'LEI-05: without a registro, the point reads as always',
    (tester) async {
      await montarTela(
        tester,
        PontoPage(
          colecao: colecaoDeTeste,
          inicial: obterPonto(colecaoDeTeste, caminho2)!,
          origem: OrigemDaLeitura.biblioteca,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Segundo ponto do caráter.'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  for (final (falha, provocar) in <(String, Future<Registro> Function())>[
    (
      'a database error',
      () async {
        await banco.customStatement(
          'CREATE TRIGGER falhar BEFORE INSERT ON leituras '
          "BEGIN SELECT RAISE(ABORT, '$caminho2 Segundo ponto do caráter.'); END",
        );
        return registro;
      },
    ),
    (
      'an error that is not the database',
      () async => Registro(
        banco,
        agora: () => throw StateError('$caminho2 Segundo ponto do caráter.'),
      ),
    ),
  ]) {
    testWidgetsComRegistro(
      'LEI-05: when recording fails ($falha), the reader sees nothing of it',
      (tester) async {
        final quebrado = (await tester.runAsync(provocar))!;

        await abrirPonto(
          tester,
          caminho2,
          OrigemDaLeitura.biblioteca,
          outroRegistro: quebrado,
        );

        expect(find.text('Segundo ponto do caráter.'), findsOneWidget);
        expect(find.byType(SnackBar), findsNothing);
        final relatado = tester.takeException();
        expect(relatado, isA<FalhaNoRegistro>());
        expect(relatado.toString(), isNot(contains(caminho2.toString())));
        expect(relatado.toString(), isNot(contains('Segundo ponto')));
        expect(await leituras(tester), isEmpty);
      },
    );
  }

  testWidgetsComRegistro('LEI-08: the point read never goes to preferences', (
    tester,
  ) async {
    await abrirPonto(tester, caminho2, OrigemDaLeitura.biblioteca);
    expect(await leituras(tester), hasLength(1));

    final valores = (await tester.runAsync(() async {
      final preferencias = await SharedPreferences.getInstance();
      return [
        for (final chave in preferencias.getKeys())
          '${preferencias.get(chave)}',
      ];
    }))!;
    for (final valor in valores) {
      expect(valor, isNot(contains(caminho2.toString())));
    }
  });
}
