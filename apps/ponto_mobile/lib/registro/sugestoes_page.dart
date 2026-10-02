import 'package:flutter/material.dart';

import 'colecoes_repositorio.dart';
import 'falha_no_registro.dart';

/// As coleções que o `docs/modelo.md` §4 sugere, nesta ordem.
const colecoesSugeridas = [
  'Pontos para reler',
  'Meditação da semana',
  'Vida profissional',
  'Família',
  'Direção espiritual',
  'Preparação para confissão',
  'Virtudes a trabalhar',
];

/// No primeiro contato com coleções, oferece as sugeridas — uma vez só.
/// Devolve se o leitor segue para onde ia.
Future<bool> passarPelasSugestoes(
  BuildContext context,
  ColecoesRepositorio colecoes,
) async {
  if (await colecoes.sugestoesRespondidas()) return true;
  if (!context.mounted) return false;
  final seguir = await Navigator.of(context).push<bool>(
    MaterialPageRoute(builder: (_) => SugestoesPage(colecoes: colecoes)),
  );
  return seguir ?? false;
}

/// Oferece as coleções sugeridas, nenhuma marcada. Criar, "Agora não" e voltar
/// contam como resposta: a oferta não se repete.
class SugestoesPage extends StatefulWidget {
  const SugestoesPage({super.key, required this.colecoes});

  final ColecoesRepositorio colecoes;

  @override
  State<SugestoesPage> createState() => _SugestoesPageState();
}

class _SugestoesPageState extends State<SugestoesPage> {
  final _escolhidas = <String>{};
  bool _respondendo = false;

  @override
  Widget build(BuildContext context) {
    final estilos = Theme.of(context).textTheme;
    return PopScope(
      onPopInvokedWithResult: (saiu, seguir) {
        // Voltar sem responder é recusar: o app espera, não insiste.
        if (saiu && seguir == null) _responder(const []);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Coleções')),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 16),
              child: Semantics(
                header: true,
                child: Text(
                  'Quer começar com algumas coleções?',
                  style: estilos.titleLarge,
                ),
              ),
            ),
            for (final nome in colecoesSugeridas)
              CheckboxListTile(
                title: Text(nome),
                value: _escolhidas.contains(nome),
                onChanged: (marcar) => setState(
                  () => marcar == true
                      ? _escolhidas.add(nome)
                      : _escolhidas.remove(nome),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: OverflowBar(
                alignment: MainAxisAlignment.end,
                overflowAlignment: OverflowBarAlignment.end,
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: _respondendo
                        ? null
                        : () => _responderESeguir([]),
                    child: const Text('Agora não'),
                  ),
                  FilledButton(
                    onPressed: _escolhidas.isEmpty || _respondendo
                        ? null
                        : () => _responderESeguir([
                            for (final nome in colecoesSugeridas)
                              if (_escolhidas.contains(nome)) nome,
                          ]),
                    child: const Text('Criar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _responderESeguir(List<String> escolhidas) async {
    setState(() => _respondendo = true);
    final respondeu = await _responder(escolhidas);
    if (!mounted) return;
    if (respondeu) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() => _respondendo = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Não foi possível guardar agora. Tente de novo.'),
      ),
    );
  }

  Future<bool> _responder(List<String> escolhidas) async {
    try {
      await widget.colecoes.responderSugestoes(escolhidas);
      return true;
    } on Object catch (erro, pilha) {
      relatarFalhaNoRegistro(erro, pilha, 'ao responder às sugestões');
      return false;
    }
  }
}
