import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/colecao/ponto_page.dart';
import 'package:ponto_mobile/inicio_page.dart';
import 'package:ponto_mobile/registro/banco_registro.dart';
import 'package:ponto_mobile/registro/falha_no_registro.dart';
import 'package:ponto_mobile/registro/registro.dart';
import 'package:ponto_mobile/selecao/um_ponto_para_agora.dart';
import 'package:ponto_motor/ponto_motor.dart';

import '../colecao_de_teste.dart';
import '../montar_tela.dart';
import '../registro/banco_de_teste.dart';

const _agora = 'Um ponto para agora';

/// Fonte que devolve sempre o mesmo índice e anota cada limite pedido.
final class _FonteFixa implements Random {
  _FonteFixa(this.indice);

  final int indice;
  final limites = <int>[];

  @override
  int nextInt(int max) {
    limites.add(max);
    return indice;
  }

  @override
  bool nextBool() => throw UnimplementedError();

  @override
  double nextDouble() => throw UnimplementedError();
}

void main() {
  late BancoRegistro banco;
  late Registro registro;

  setUp(() {
    banco = abrirBancoDeTela();
    registro = Registro(banco);
  });

  Future<void> abrirInicio(
    WidgetTester tester,
    Random fonte, {
    Registro? com,
  }) async {
    await montarTela(
      tester,
      InicioPage(colecao: colecaoDeTeste, aleatorio: fonte),
      registro: com,
    );
    await tester.pumpAndSettle();
  }

  Future<void> tocarAgora(WidgetTester tester) async {
    await tester.tap(find.text(_agora));
    await tester.pumpAndSettle();
  }

  Finder opcao(String rotulo) => find.widgetWithText(ChoiceChip, rotulo);

  bool escolhida(WidgetTester tester, String rotulo) =>
      tester.widget<ChoiceChip>(opcao(rotulo)).selected;

  // Candidatos da coleção de teste, em ordem: Caminho 1, 2, 81, 82 · Sulco 1.
  for (final (k, texto) in [
    (0, 'Primeiro ponto do caráter.'),
    (4, 'O único ponto do sulco.'),
  ]) {
    testWidgetsComRegistro('AGORA-01: one tap opens candidate $k of 5', (
      tester,
    ) async {
      final fonte = _FonteFixa(k);
      await abrirInicio(tester, fonte, com: registro);

      await tocarAgora(tester);

      expect(find.byType(PontoPage), findsOneWidget);
      expect(find.text(texto), findsOneWidget);
      expect(fonte.limites, [5]);
    });
  }

  testWidgetsComRegistro('LEI-02: a point opened by a point for now says so', (
    tester,
  ) async {
    await abrirInicio(tester, _FonteFixa(1), com: registro);

    await tocarAgora(tester);

    final leitura = await tester.runAsync(
      () => (banco.select(
        banco.leituras,
      )..orderBy([(l) => OrderingTerm.desc(l.id)])).get(),
    );
    expect(leitura!.first.pontoId, idDe('caminho', 2).toString());
    expect(leitura.first.origem, OrigemDaLeitura.aleatorio);
  });

  testWidgetsComRegistro('AGORA-02: what was just read is left out', (
    tester,
  ) async {
    await tester.runAsync(
      () => registro.leituras.registrar(
        idDe('caminho', 1),
        OrigemDaLeitura.biblioteca,
      ),
    );
    final fonte = _FonteFixa(0);
    await abrirInicio(tester, fonte, com: registro);

    await tocarAgora(tester);

    expect(fonte.limites, [4]);
    expect(find.text('Segundo ponto do caráter.'), findsOneWidget);
  });

  testWidgetsComRegistro(
    'AGORA-02: the home leaves out exactly the ten most recent points read',
    (tester) async {
      final doze = lerColecao(
        {
          'id': 'teste',
          'titulo': 'Teste',
          'versaoDados': '0.1.0',
          'obras': ['caminho'],
        },
        {
          'caminho': {
            'id': 'caminho',
            'obra': {'titulo': 'Caminho'},
            'capitulos': [
              {
                'numero': 1,
                'titulo': 'Caráter',
                'pontoInicial': 1,
                'pontoFinal': 12,
              },
            ],
            'pontos': [
              for (var n = 1; n <= 12; n++)
                {
                  'numero': n,
                  'capituloNumero': 1,
                  'ordem': n,
                  'texto': 'Ponto $n.',
                },
            ],
          },
        },
      );
      // Lidos de 1 a 11: a janela são os pontos 2–11; sobram 1 e 12.
      await tester.runAsync(() async {
        for (var n = 1; n <= 11; n++) {
          await registro.leituras.registrar(
            idDe('caminho', n),
            OrigemDaLeitura.biblioteca,
          );
        }
      });
      final fonte = _FonteFixa(0);
      await montarTela(
        tester,
        InicioPage(colecao: doze, aleatorio: fonte),
        registro: registro,
      );
      await tester.pumpAndSettle();

      await tocarAgora(tester);

      expect(fonte.limites, [2]);
      expect(find.text('Ponto 1.'), findsOneWidget);
    },
  );

  testWidgetsComRegistro(
    'AGORA-05: the filter offers every work with a point, in collection order',
    (tester) async {
      await abrirInicio(tester, _FonteFixa(0), com: registro);

      final todas = tester.getTopLeft(opcao('Todas as obras')).dx;
      final caminho = tester.getTopLeft(opcao('Caminho')).dx;
      final sulco = tester.getTopLeft(opcao('Sulco')).dx;
      expect(todas, lessThan(caminho));
      expect(caminho, lessThan(sulco));
      expect(opcao('Forja'), findsNothing);
      expect(find.byType(ChoiceChip), findsNWidgets(3));
      expect(escolhida(tester, 'Todas as obras'), isTrue);
      expect(escolhida(tester, 'Caminho'), isFalse);
      expect(escolhida(tester, 'Sulco'), isFalse);
    },
  );

  testWidgetsComRegistro(
    'AGORA-05: a chosen work bounds the draw and stays chosen on return',
    (tester) async {
      final fonte = _FonteFixa(3);
      await abrirInicio(tester, fonte, com: registro);

      await tester.tap(opcao('Caminho'));
      await tester.pumpAndSettle();
      await tocarAgora(tester);

      expect(fonte.limites, [4]);
      expect(find.text('Segundo ponto da oração.'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(escolhida(tester, 'Caminho'), isTrue);
      expect(escolhida(tester, 'Todas as obras'), isFalse);
    },
  );

  test('AGORA-05: no work id is written in the app code (rule 1)', () {
    final idDeObra = RegExp(r'''['"](caminho|sulco|forja)['"]''');
    final arquivos = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((arquivo) => arquivo.path.endsWith('.dart'));

    expect(arquivos, isNotEmpty);
    for (final arquivo in arquivos) {
      expect(
        idDeObra.hasMatch(arquivo.readAsStringSync()),
        isFalse,
        reason: arquivo.path,
      );
    }
  });

  testWidgets('AGORA-06: without a registro, every point is a candidate', (
    tester,
  ) async {
    final fonte = _FonteFixa(0);
    await abrirInicio(tester, fonte);

    await tocarAgora(tester);

    expect(fonte.limites, [5]);
    expect(find.text('Primeiro ponto do caráter.'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgetsComRegistro(
    'AGORA-06: when recent points cannot be read, draw from all and log the type',
    (tester) async {
      await tester.runAsync(() async {
        await registro.leituras.registrar(
          idDe('caminho', 1),
          OrigemDaLeitura.biblioteca,
        );
        await banco.customStatement('DROP TABLE leituras');
      });
      final fonte = _FonteFixa(0);
      final relatos = <FlutterErrorDetails>[];
      final anterior = FlutterError.onError;
      FlutterError.onError = relatos.add;

      await montarTela(
        tester,
        Scaffold(
          body: UmPontoParaAgora(colecao: colecaoDeTeste, aleatorio: fonte),
        ),
        registro: registro,
      );
      await tocarAgora(tester);
      FlutterError.onError = anterior;

      expect(fonte.limites, [5]);
      expect(find.text('Primeiro ponto do caráter.'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      expect(relatos, isNotEmpty);
      for (final relato in relatos) {
        expect(relato.exception, isA<FalhaNoRegistro>());
        expect(relato.exception.toString(), isNot(contains('leituras')));
      }
      expect(
        relatos.map((relato) => relato.context.toString()),
        contains('ao ler os pontos recentes'),
      );
    },
  );
}
