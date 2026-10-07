import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ponto_mobile/colecao/compartilhar_referencia.dart';
import 'package:ponto_mobile/colecao/ponto_page.dart';
import 'package:ponto_mobile/registro/banco_registro.dart';
import 'package:ponto_mobile/registro/registro.dart';
import 'package:ponto_motor/ponto_motor.dart';

import '../colecao_de_teste.dart';
import '../montar_tela.dart';
import '../registro/banco_de_teste.dart';

const _referencia = 'Caminho, capítulo Caráter, ponto 2';
const _botao = 'Compartilhar referência';

void main() {
  late BancoRegistro banco;
  late RelogioDeTeste relogio;
  late Registro registro;
  late List<String> compartilhados;
  final caminho2 = idDe('caminho', 2);

  setUp(() {
    banco = abrirBancoDeTela();
    relogio = RelogioDeTeste(DateTime.utc(2026, 10, 7, 9));
    registro = Registro(banco, agora: relogio.call);
    compartilhados = [];
  });

  Future<void> abrir(
    WidgetTester tester,
    Ponto ponto, {
    Colecao? colecao,
    Compartilhar? compartilhar,
  }) async {
    await montarTela(
      tester,
      PontoPage(
        colecao: colecao ?? colecaoDeTeste,
        inicial: ponto,
        origem: OrigemDaLeitura.biblioteca,
        compartilhar:
            compartilhar ?? (texto) async => compartilhados.add(texto),
      ),
      registro: registro,
    );
    await tester.pumpAndSettle();
  }

  testWidgetsComRegistro(
    'COMP-01: sharing hands over the reference shown on the page, nothing else',
    (tester) async {
      await tester.runAsync(() async {
        await registro.reflexoes.escrever(caminho2, 'Uma reflexão só minha.');
        await semearColecoes(
          registro,
          banco,
          relogio,
          ['Família'],
          pontos: {
            'Família': [caminho2],
          },
        );
      });
      await abrir(tester, obterPonto(colecaoDeTeste, caminho2)!);

      await tester.tap(find.byTooltip(_botao));
      await tester.pumpAndSettle();

      expect(find.text(_referencia), findsOneWidget);
      expect(compartilhados, [_referencia]);
      final texto = compartilhados.single;
      expect(texto, isNot(contains('Segundo ponto do caráter.')));
      expect(texto, isNot(contains('Uma reflexão só minha.')));
      expect(texto, isNot(contains('Família')));
      expect(texto, isNot(contains('ponto:')));
    },
  );

  testWidgetsComRegistro(
    'COMP-01: after Próximo, it shares the point now shown',
    (tester) async {
      await abrir(tester, obterPonto(colecaoDeTeste, caminho2)!);
      await tester.tap(find.text('Próximo'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip(_botao));
      await tester.pumpAndSettle();

      expect(find.text('Caminho, capítulo Oração, ponto 81'), findsOneWidget);
      expect(compartilhados, ['Caminho, capítulo Oração, ponto 81']);
    },
  );

  testWidgetsComRegistro(
    'COMP-01: a chapter with no title yet shares the reference without it',
    (tester) async {
      final semTitulo = lerColecao(
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
                'numero': 17,
                'titulo': null,
                'pontoInicial': 387,
                'pontoFinal': null,
              },
            ],
            'pontos': [
              {
                'numero': 390,
                'capituloNumero': 17,
                'ordem': 390,
                'texto': 'Um ponto de capítulo sem título.',
              },
            ],
          },
        },
      );
      await abrir(
        tester,
        semTitulo.obras.single.pontos.single,
        colecao: semTitulo,
      );

      await tester.tap(find.byTooltip(_botao));
      await tester.pumpAndSettle();

      expect(find.text('Caminho, ponto 390'), findsOneWidget);
      expect(compartilhados, ['Caminho, ponto 390']);
    },
  );

  testWidgetsComRegistro(
    'COMP-02: when the share sheet fails, the reader is told and the log has only the type',
    (tester) async {
      await abrir(
        tester,
        obterPonto(colecaoDeTeste, caminho2)!,
        compartilhar: (texto) async =>
            throw PlatformException(code: 'falhou', message: texto),
      );

      await tester.tap(find.byTooltip(_botao));
      await tester.pumpAndSettle();

      expect(find.text('Não foi possível compartilhar.'), findsOneWidget);
      expect(find.text('Segundo ponto do caráter.'), findsOneWidget);
      final relatado = tester.takeException();
      expect(relatado, isA<FalhaAoCompartilhar>());
      expect(relatado.toString(), isNot(contains(_referencia)));
      expect(relatado.toString(), isNot(contains('falhou')));
    },
  );

  testWidgetsComRegistro(
    'COMP-03: the share button is labelled and big enough to tap',
    (tester) async {
      final semantica = tester.ensureSemantics();
      await abrir(tester, obterPonto(colecaoDeTeste, caminho2)!);

      expect(
        tester.getSemantics(find.byTooltip(_botao)),
        isSemantics(tooltip: _botao, isButton: true, hasTapAction: true),
      );
      final tamanho = tester.getSize(
        find.ancestor(
          of: find.byTooltip(_botao),
          matching: find.byType(IconButton),
        ),
      );
      expect(tamanho.width, greaterThanOrEqualTo(48));
      expect(tamanho.height, greaterThanOrEqualTo(48));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      semantica.dispose();
    },
  );
}
