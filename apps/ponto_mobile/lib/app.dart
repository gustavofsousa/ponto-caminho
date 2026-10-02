import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ponto_motor/ponto_motor.dart';

import 'colecao/biblioteca_page.dart';
import 'preferencias/preferencias_controller.dart';
import 'preferencias/preferencias_repositorio.dart';
import 'registro/falha_no_registro.dart';
import 'registro/registro.dart';
import 'registro/registro_escopo.dart';
import 'tema.dart';

/// Lê um arquivo de `livros/` empacotado no app (symlink declarado no pubspec).
Future<String> lerLivroEmpacotado(String arquivo) =>
    rootBundle.loadString('assets/livros/$arquivo');

/// A Literata é distribuída sob a SIL OFL, que exige a licença junto da fonte.
void registrarLicencas() {
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks([
      fonteDeLeitura,
    ], await rootBundle.loadString('assets/fonts/OFL.txt'));
  });
}

/// Carrega tudo antes do primeiro quadro (a splash nativa cobre a espera) e
/// decide a tela de abertura: a biblioteca, ou uma mensagem humana se os livros falharem.
/// O registro que não abre não impede a leitura (ADR-002).
Future<Widget> abrirApp({
  required Future<Colecao> Function() carregarLivros,
  required PreferenciasRepositorio repositorio,
  required Future<Registro?> Function() abrirRegistro,
}) async {
  final preferencias = PreferenciasController(repositorio);
  final registro = await _abrirRegistroSemTravar(abrirRegistro);
  try {
    final colecao = await carregarLivros();
    return _Moldura(
      preferencias: preferencias,
      registro: registro,
      inicio: BibliotecaPage(colecao: colecao),
    );
  } on Object catch (erro, pilha) {
    // Fronteira mais externa: qualquer falha vira tela humana para o leitor e
    // erro completo no log para quem desenvolve — nunca os dois trocados.
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: erro,
        stack: pilha,
        library: 'ponto_mobile',
        context: ErrorDescription('ao abrir os livros'),
      ),
    );
    return _Moldura(
      preferencias: preferencias,
      registro: registro,
      inicio: const _FalhaAoAbrir(),
    );
  }
}

Future<Registro?> _abrirRegistroSemTravar(
  Future<Registro?> Function() abrirRegistro,
) async {
  try {
    return await abrirRegistro();
  } on Object catch (erro, pilha) {
    relatarFalhaNoRegistro(erro, pilha, 'ao preparar o registro');
    return null;
  }
}

/// Tema e tamanho de texto do leitor aplicados ao app inteiro, ao vivo.
class _Moldura extends StatelessWidget {
  const _Moldura({
    required this.preferencias,
    required this.registro,
    required this.inicio,
  });

  final PreferenciasController preferencias;
  final Registro? registro;
  final Widget inicio;

  @override
  Widget build(BuildContext context) => PreferenciasEscopo(
    controller: preferencias,
    child: RegistroEscopo(
      registro: registro,
      child: ListenableBuilder(
        listenable: preferencias,
        builder: (context, _) => MaterialApp(
          title: 'Ponto',
          theme: temaClaro(),
          darkTheme: temaEscuro(),
          themeMode: preferencias.value.tema.modo,
          builder: (context, tela) {
            final midia = MediaQuery.of(context);
            return MediaQuery(
              data: midia.copyWith(
                textScaler: _EscalaDoLeitor(
                  midia.textScaler,
                  preferencias.value.tamanhoTexto.fator,
                ),
              ),
              child: tela!,
            );
          },
          home: inicio,
        ),
      ),
    ),
  );
}

/// Multiplica a escala do sistema — inclusive a não linear do Android 14+ —
/// em vez de substituí-la: a acessibilidade do aparelho continua valendo.
final class _EscalaDoLeitor extends TextScaler {
  const _EscalaDoLeitor(this._sistema, this._fator);

  final TextScaler _sistema;
  final double _fator;

  @override
  double scale(double fontSize) => _sistema.scale(fontSize) * _fator;

  @override
  // COMPAT: TextScaler ainda exige este membro obsoleto; apagar quando o Flutter removê-lo.
  // ignore: deprecated_member_use
  double get textScaleFactor => _sistema.textScaleFactor * _fator;

  @override
  bool operator ==(Object other) =>
      other is _EscalaDoLeitor &&
      other._sistema == _sistema &&
      other._fator == _fator;

  @override
  int get hashCode => Object.hash(_sistema, _fator);
}

class _FalhaAoAbrir extends StatelessWidget {
  const _FalhaAoAbrir();

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Text(
          'Não foi possível abrir os livros. Feche o app e abra de novo.',
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}
