# Ler (v0.2) Validation

**Date**: 2026-10-02
**Spec**: `.specs/features/ler/spec.md`
**Diff range**: `3b0b864..92d6755` (b61e6da … 92d6755, branch `feat/v0.2-ler`)
**Verifier**: independent sub-agent (author ≠ verifier)
**Verdict**: ❌ FAIL — o código se comporta como o spec pede (provas abaixo), mas 2 mutantes sobreviveram: a suíte não segura AC-05 ("qualquer exceção") nem AC-15 ("Sistema segue o aparelho") nos dois sentidos. Os consertos mexem só nos testes (~20 min no total).

---

## Task Completion

| Task | Status | Notes |
| ---- | ------ | ----- |
| T1–T17 | ✅ Done | Todas marcadas `[x]` em `tasks.md`; commits b61e6da…85677c0. Rulings da T4 e da T12 registradas. Nenhum `SPEC_DEVIATION`/`TODO`/`FIXME` no diff (`grep` exit 1). |
| T17 | ✅ Done | `grep -rn primeiroPonto packages apps` → exit 1 (vazio). O teste removido junto com a função é justificado (o comportamento deixou de existir). |

---

## Spec-Anchored Acceptance Criteria

Caminhos relativos a `packages/ponto_motor/test/` (motor), `apps/ponto_mobile/test/` (app) e `livros/`.

| AC (req) | Spec-defined outcome | `file:line` + assertion | Result |
| --- | --- | --- | --- |
| AC-01 (BASE-01) tipo errado | `FormatException` (não `TypeError`) nomeando a obra; nunca coleção parcial | `colecao/ler_colecao_test.dart:69-72` — `throwsA(_formatoCom(['alfa', 'titulo']))`; `:84-87` — `throwsA(_formatoCom(['alfa', 'slug']))`; `:57` — `throwsFormatException` (id de obra `7`) | ✅ PASS · ⚠️ Spec-precision gap: com id de obra não-texto não há "nome da obra" a citar; o spec não define o que a mensagem deve conter e o teste `:57` só confere o tipo |
| AC-02 (BASE-02) número repetido | motor: `FormatException` com obra e número · validar.py: erro, exit 1 | `colecao/ler_colecao_test.dart:97-100` — `_formatoCom(['alfa', 'ponto 1 repetido'])`; `livros/test_validar.py:41` — `assertIn("ponto 3 repetido", erros)` | ✅ PASS — exit 1 não é afirmado pela suíte; observado em sonda da CLI (ver Probes) |
| AC-03 (BASE-03) capítulo inexistente | motor: `FormatException` com ponto e capítulo · validar.py: erro, exit 1 | `colecao/ler_colecao_test.dart:111-114` — `_formatoCom(['alfa', 'ponto 2', 'capítulo 9'])`; `livros/test_validar.py:46` — `assertIn("ponto 4: capítulo 9 não existe no índice", erros)` | ✅ PASS — exit 1 observado em sonda |
| AC-04 (BASE-04) só o motor conhece o formato | app e contrato chamam a mesma função do motor passando só "ler arquivo pelo nome"; app não lê `colecao.json` | `colecao/carregar_colecao_test.dart:23` — `expect(pedidos, ['colecao.json', 'alfa.json', 'beta.json'])`; `livros_contract_test.dart:9-13` — `carregarColecao(...)` + `['caminho','sulco','forja']`; app `app_test.dart:71-76` — `carregarColecao(lerLivroEmpacotado)` + `find.text(obra), findsOneWidget`; `lib/main.dart:17` liga o mesmo; `grep -rnE "colecao\.json\|jsonDecode\|dart:convert" apps/ponto_mobile/lib` → exit 1 | ✅ PASS |
| AC-05 (BASE-05) falha vira mensagem humana | **qualquer** exceção → tela única "Não foi possível abrir os livros. Feche o app e abra de novo."; sem texto da exceção | `app_test.dart:45-55` — `find.text('Não foi possível…'), findsOneWidget`; `find.textContaining('repetido'), findsNothing`; `takeException(), isA<FormatException>()` | ❌ GAP (parcial) — a suíte só lança `FormatException`. Mutante M12 (`on Object` → `on FormatException`) **sobreviveu**. O caso realista (asset ausente → `FlutterError` do `rootBundle`, linha "Arquivo de obra ausente" do design) não tem teste. O código atual trata certo (sonda P1/P2 passa no HEAD) |
| AC-06 (LER-01) ordem da coleção | "Caminho", "Sulco", "Forja" nesta ordem; não alfabética | `colecao/biblioteca_page_test.dart:17-21` — alturas de Caminho/Sulco/Forja `orderedEquals([...alturas]..sort())`; real: `app_test.dart:74-76` | ✅ PASS (M14 morto) |
| AC-07 (LER-02) capítulos com contagem | um item por capítulo, em ordem; cap. 1 "Caráter" + "55 pontos"; intervalo incompleto sem contagem; sem título → "Capítulo N"; capítulos sem pontos aparecem | motor `colecao/indice_test.dart:8` — `totalPontos, 55`; `:16-17` — `isNull`; app `colecao/obra_page_test.dart:19-23` (ordem), `:24` — `find.text('55 pontos')`, `:25-29` — `'25 pontos'` (Direção, sem pontos disponíveis); `:39-47` — `Capítulo 4` sem descendente com "ponto" | ✅ PASS (M5 morto) |
| AC-08 (LER-03) pontos do capítulo com prévia | pontos em `ordem`, número + início do texto (máx. 2 linhas); nada de outro capítulo | motor `colecao/indice_test.dart:45` — `pontosDoCapitulo(1)… [1, 2]` (entrada fora de ordem, com ponto de outro cap.); app `colecao/capitulo_page_test.dart:29-33` — `'81'`/`'82'` achados, 81 acima de 82, `maxLines, 2`, `'Segundo ponto do caráter.'` `findsNothing` | ✅ PASS (M19, M20 mortos) |
| AC-09 (LER-04) capítulo vazio | "Os pontos deste capítulo ainda não estão disponíveis." | `colecao/capitulo_page_test.dart:42-45` — `findsOneWidget`; motor `colecao/indice_test.dart:55` — `isEmpty` | ✅ PASS |
| AC-10 (LER-05) toque abre o ponto | página com "Caminho, capítulo Oração, ponto 82" **e** o texto do 82 | `colecao/capitulo_page_test.dart:54` — `find.text('Caminho, capítulo Oração, ponto 82'), findsOneWidget` | ⚠️ GAP menor — só a referência é afirmada; o texto do 82 não. Sonda P5 confirma que o texto aparece (onstage) no HEAD |
| AC-11 (LER-06) formato da referência | "<Obra>, capítulo <Capítulo>, ponto <n>" · sem título "<Obra>, ponto <n>" | `colecao/referencia_test.dart:28` — `'Caminho, capítulo Caráter, ponto 1'`; `:34` — `'Caminho, ponto 387'` | ✅ PASS |
| AC-12 (LER-07) Próximo atravessa capítulos | último disponível do cap. 1 → primeiro disponível do cap. seguinte com pontos; nunca outra obra | motor `selecao/sequencia_test.dart:40` — `proximoPonto(a/2) == a/7` (pula cap. 2 vazio); `:56` — último de "a" `isNull` com "b" depois; app `colecao/ponto_page_test.dart:27-28` — referência e texto do 81 após tocar "Próximo" no 2 | ✅ PASS (M1, M2 mortos) |
| AC-13 (LER-08) Anterior espelha | 81 → último disponível do cap. 1 | `selecao/sequencia_test.dart:45-46`; `colecao/ponto_page_test.dart:40-41` — `'Caminho, capítulo Caráter, ponto 2'` + texto | ✅ PASS |
| AC-14 (LER-09) pontas sem botão | primeiro: sem "Anterior"; último: sem "Próximo" | motor `selecao/sequencia_test.dart:50`, `:56` — `isNull`; app `colecao/ponto_page_test.dart:49-50`, `:58-59` — `findsNothing` + o outro `findsOneWidget` | ✅ PASS (M11 morto) |
| AC-15 (PREF-01) tema | Claro/Escuro/Sistema aplicados ao app inteiro; **Sistema segue o aparelho**; padrão Sistema | `app_test.dart:83-93` — gravado escuro → `Brightness.dark`; escolher Claro → `Brightness.light`; `:97-104` — Sistema + aparelho escuro → `dark`; padrão `preferencias/preferencias_repositorio_test.dart:23`; escolha `preferencias/preferencias_page_test.dart:17-23` | ❌ GAP (parcial) — "segue o aparelho" só é testado com aparelho escuro. Mutante M13 (`Tema.sistema` → `ThemeMode.dark`) **sobreviveu**. Sonda P3 (aparelho claro → claro) passa no HEAD e mata M13 |
| AC-16 (PREF-02) tamanhos multiplicam | escala efetiva = s × 0,9/1,0/1,15/1,3; padrão Médio | unit `preferencias/preferencias_repositorio_test.dart:15` — `[0.9, 1.0, 1.15, 1.3]`; widget `app_test.dart:117-120` — s=1,5 × Grande → `scale(10)` `closeTo(17.25, 1e-9)`; padrão `preferencias_repositorio_test.dart:24` | ✅ PASS (M9 morto) |
| AC-17 (PREF-03) persistem | Escuro + Grande gravados → lidos de volta | `preferencias/preferencias_repositorio_test.dart:30-38` — nova instância lê `Tema.escuro` e `TamanhoTexto.grande`; controller grava `preferencias_controller_test.dart:22-23`, `:31-32`; abertura com valores gravados `app_test.dart:83-84`, `:112-120` | ✅ PASS (M17 morto) |
| AC-18 (PREF-04) inválido → padrão | Sistema + Médio, sem erro | `preferencias/preferencias_repositorio_test.dart:51-52` — `'roxo'` → `Tema.sistema`; `:66-67` — tipo errado → `TamanhoTexto.medio` | ✅ PASS (M16 morto) |
| AC-19 (TIPO-01) Literata empacotada | família "Literata"; fonte no pacote, sem rede | `colecao/ponto_page_test.dart:100-101` — `texto.style?.fontFamily, 'Literata'`; `tema_test.dart:46-48`; build: `FontManifest.json` do APK lista `Literata` → `assets/fonts/Literata-Variable.ttf` (+ itálico) e os TTF estão no APK; nenhuma dependência de fonte por rede no `pubspec.yaml`/`pubspec.lock` | ✅ PASS |
| AC-20 (TIPO-02) contraste AA | texto principal e secundário ≥ 4,5:1 nos dois temas | `tema_test.dart:28-32` — `greaterThanOrEqualTo(4.5)` para texto/secundário/acento; `:38-42` — o tema usa esses tokens. Cálculo independente (WCAG 2.x): claro 13,98 / 6,07 / 5,51 · escuro 14,42 / 7,87 / 8,81 | ✅ PASS |

**Status**: ❌ Gaps present — 17/20 ACs com o resultado do spec afirmado por inteiro; 3 parciais (AC-05, AC-15, AC-10); 1 spec-precision gap (AC-01, caso do id não-texto).

### Reverse check (testes sem AC)

Nenhum teste órfão. Testes sem ID de requisito mapeiam para Done-when ou são da v0.1: `app_test.dart:138` (licença OFL → T16 Done-when), `app_test.dart:123` "TD-001" (rótulo de mock, herdado do teste de abertura da v0.1), `ponto_page_test.dart:69` (rolagem volta ao topo → T12), `:104` e `preferencias_page_test.dart:47` (UX DoD 320 px → T11/T12), `carregar_colecao_test.dart:27,42` e `indice_test.dart:20` (Done-when de T4/T6). AD-004 seguido (Python usa a forma `test_base02_…`).

### Probes (descartáveis, só no worktree de rascunho, já removido)

| # | Sonda | No HEAD | Mata |
| --- | --- | --- | --- |
| P1 | carregador com `rootBundle.loadString` de asset inexistente (`FlutterError`) → tela humana | ✅ passa | M12 |
| P2 | carregador lança `StateError('disco cheio')` → tela humana, sem "disco" na tela | ✅ passa | M12 |
| P3 | Sistema + aparelho claro → `Brightness.light` | ✅ passa | M13 |
| P4 | Biblioteca → Forja (sem pontos) → Formação → estado vazio | ✅ passa | — |
| P5 | Caminho → Oração → 82: referência **e** texto do 82 onstage, 81 ausente | ✅ passa | — |
| P6 | texto longo, Muito grande, sistema 2,0: escala efetiva 2,6, `maxScrollExtent > 0`, sem overflow | ✅ passa | — |
| CLI | `validar.py` (cópia em pasta temporária) com repetido / capítulo inexistente / válido | exit **1** / **1** / **0**, erros "ponto 3 repetido" e "ponto 4: capítulo 9 não existe no índice" | — |

---

## Discrimination Sensor

Worktree descartável em `HEAD` (92d6755); uma mutação por vez via substituição de texto, teste, `git checkout` do arquivo. Worktree removido no fim; árvore real intocada (`git status` limpo).

| # | File:line | Description | Killed? |
| --- | --- | --- | --- |
| M1 | `packages/ponto_motor/lib/src/selecao/sequencia.dart:18` | `vizinho >= pontos.length` → `>` (off-by-one) | ✅ Killed — LER-09 last point |
| M2 | `sequencia.dart:16` | vizinhos só dentro do capítulo (`pontosDoCapitulo`) | ✅ Killed — LER-07 cross, LER-08 |
| M3 | `packages/ponto_motor/lib/src/colecao/ler_colecao.dart:75` | remove a checagem de número repetido | ✅ Killed — BASE-02 |
| M4 | `ler_colecao.dart:78` | remove a checagem de capítulo inexistente | ✅ Killed — BASE-03 |
| M5 | `packages/ponto_motor/lib/src/colecao/colecao.dart:102` | `fim - inicial + 1` → `fim - inicial` | ✅ Killed — LER-02 count |
| M6 | `ler_colecao.dart:131` | `_textoOpcional` engole tipo errado como `null` | ✅ Killed — BASE-01 título, slug |
| M7 | `packages/ponto_motor/lib/src/colecao/carregar_colecao.dart:23` | lê as obras em ordem inversa | ✅ Killed — BASE-04 order |
| M8 | `ler_colecao.dart:38` | id de obra não-texto lança `TypeError` | ✅ Killed — BASE-01 id |
| M9 | `apps/ponto_mobile/lib/app.dart:96` | `scale` = `fontSize * _fator` (ignora o sistema) | ✅ Killed — PREF-02 1.725 |
| M10 | `app.dart:48` | mensagem humana + `$erro` no mesmo `Text` | ✅ Killed (fraco: quebra o texto exato) |
| M10b | `app.dart:48` | mensagem humana intacta **e** `Text('$erro')` abaixo (dois `Text` numa `Column`, layout válido) | ✅ Killed — BASE-05 falha em `app_test.dart:51` (`find.textContaining('repetido'), findsNothing`) |
| M11 | `apps/ponto_mobile/lib/colecao/ponto_page.dart:56-67` | os dois botões sempre visíveis (desabilitados nas pontas) | ✅ Killed — 3× LER-09 |
| M12 | `app.dart:37` | `on Object catch` → `on FormatException catch` | ❌ **Survived** → Fix 1 |
| M13 | `apps/ponto_mobile/lib/preferencias/preferencias.dart:4` | `Tema.sistema` → `ThemeMode.dark` | ❌ **Survived** → Fix 2 |
| M14 | `apps/ponto_mobile/lib/colecao/biblioteca_page.dart:23` | obras em ordem alfabética | ✅ Killed — LER-01 order |
| M15 | `apps/ponto_mobile/lib/colecao/obra_page.dart:26` | remove o singular "1 ponto" | ✅ Killed — LER-02 one-point |
| M16 | `apps/ponto_mobile/lib/preferencias/preferencias_repositorio.dart:33` | `asNameMap()[nome]` → `byName(nome)` (lança) | ✅ Killed — PREF-04 |
| M17 | `apps/ponto_mobile/lib/preferencias/preferencias_controller.dart:19` | controller troca o valor mas não grava | ✅ Killed — PREF-03 ×2 |
| M18 | `ponto_page.dart:33` | sem `ValueKey` (rolagem não volta ao topo) | ✅ Killed — LER-07 top |
| M19 | `colecao.dart:80` | `pontosDoCapitulo` ignora o capítulo | ✅ Killed — LER-03 ×2 |
| M20 | `apps/ponto_mobile/lib/colecao/capitulo_page.dart:34` | prévia sem `maxLines: 2` | ✅ Killed — LER-03 preview |

**Sensor depth**: P0-full (fronteira de dados = integridade) — 21 mutações manuais cobrindo motor, abertura, telas e preferências.
**Result**: 19/21 killed — ❌ FAIL (M12, M13 sobreviveram; as sondas P1–P3 mostram que uma asserção a mais mata cada um).

---

## Interactive UAT Results

Não realizado (Verifier sub-agente). Pendente com o usuário: A1, A3, A4, A5, A7, A10, A11, A12 estão "não — UAT" no spec; sem execução em aparelho (TD-004).

---

## Code Quality

| Principle | Status |
| --- | --- |
| Minimum code | ✅ — helpers compartilhados têm 2 usos cada (`nome_do_capitulo.dart`: obra e capítulo; `botao_preferencias.dart`: biblioteca e ponto) |
| Surgical changes | ✅ — `analysis_options.yaml` do motor perdeu o boilerplate comentado do template (mesmo arquivo da T1) |
| No scope creep | ✅ — `registrarLicencas` é exigência da OFL (Done-when da T16); nada fora dos ACs/Done-when |
| Matches patterns | ✅ — AD-002 (ValueNotifier + InheritedNotifier), AD-003 (porta `lerArquivo`), AD-005 (chave por campo, `enum.name`), AD-006 (Navigator); `ler()` síncrono em vez do `Future` do design e `carregarLivros` em vez de `carregarColecao` (colisão de nome) são simplificações, não desvios de comportamento |
| Comments explain why | ✅ — prefixos `INVARIANT:`/`COMPAT:`/`OPS:`. Nota: `app.dart:99-100` `// ignore: deprecated_member_use` tem motivo e condição de remoção, mas não cita issue (regra global de supressões) |
| Constitution rules | ✅ — nenhum id de obra em `packages/ponto_motor/lib` ou `apps/ponto_mobile/lib` (`grep` exit 1); motor sem I/O; fonte e livros empacotados, sem rede |
| Spec-anchored outcome check | ⚠️ — AC-05, AC-15, AC-10 parciais; AC-01 spec-precision gap |
| Per-layer Coverage Expectation met | ⚠️ — motor 1:1 com os ACs; telas cobrem caminho feliz + vazio + pontas; abertura cobre só um tipo de falha (AC-05) |
| Every test maps to a requirement | ✅ — ver Reverse check |
| Documented guidelines followed | ✅ — `AGENTS.md` (Done means: `validar.py` exit 0; análise zero issues), `.specs/STATE.md` AD-004 |

---

## Edge Cases

- [x] Obra sem nenhum ponto aparece na biblioteca e seus capítulos abrem vazios — `biblioteca_page_test.dart:17-19` (Forja listada); caminho do estado vazio `capitulo_page_test.dart:40-45` (mesmo código); fluxo Forja → Formação confirmado pela sonda P4
- [x] Único ponto da obra: sem Anterior nem Próximo — `ponto_page_test.dart:62-67`
- [x] Capítulo com 1 ponto no intervalo: "1 ponto" — `obra_page_test.dart:51-55` (M15 morto)
- [x] `PontoId` inexistente → nulo nos dois sentidos — `sequencia_test.dart:60-69` (número, obra e coleção desconhecidos)
- [x] Texto longo com tamanho grande rola, sem cortar — `ponto_page_test.dart:72-83` (escala 4: rola, `pixels > 0`) e `:104-118` (2,6 em 320 px, sem exceção); "Muito grande" + sistema 2,0 confirmado pela sonda P6
- [x] Escala do sistema já grande multiplica — `app_test.dart:106-121` (1,5 × 1,15 = 1,725)

**6/6** cobertos pela suíte (P4 e P6 só confirmam os mesmos caminhos de código pelo fluxo completo).

---

## Gate Check

- **Gate command**: `python3 livros/validar.py && python3 -m unittest discover -s livros -p 'test_*.py' && (cd packages/ponto_motor && dart format --output=none --set-exit-if-changed . && dart analyze --fatal-infos && dart test) && (cd apps/ponto_mobile && dart format --output=none --set-exit-if-changed lib test && flutter analyze --fatal-infos && flutter test && flutter build apk --debug)`
- **Result**: exit 0 — validar.py ok nas 3 obras (só avisos de mock/intervalo, esperados no modo dev) · validador 3 passed · motor format 0 changed, analyze "No issues found!", **38 passed** · app format 0 changed, analyze "No issues found!", **44 passed** · `✓ Built build/app/outputs/flutter-apk/app-debug.apk`
- **Test count before feature**: motor 18 · app 1 · validador 0 (reconfirmado rodando `dart test`/`flutter test` num worktree em `3b0b864`: `+18`, `+1`)
- **Test count after feature**: motor 38 · app 44 · validador 3
- **Delta**: motor +20 (+21 novos, −1 removido com `primeiroPonto` na T17) · app +43 · validador +3
- **Weakened assertions**: nenhuma. O contrato ficou mais estrito (lista explícita `['caminho','sulco','forja']`). O teste de abertura da v0.1 (ponto 1 fixo) deixou de valer por A1 (abre na biblioteca); seu rótulo de mock seguiu em `app_test.dart:123`.
- **Skipped tests**: nenhum
- **Failures**: nenhuma

---

## Fix Plans

### Fix 1: AC-05 só é provado para `FormatException`

- **Root cause**: `app_test.dart:36-58` lança só `FormatException`; o spec diz "qualquer exceção", e o caso realista (asset ausente) lança `FlutterError`. M12 sobrevive.
- **Fix task**: em `apps/ponto_mobile/test/app_test.dart`, acrescentar `'BASE-05: any load failure, not only bad data, shows the humane message'` com carregador que lança um não-`FormatException` (ex.: `carregarColecao((a) => rootBundle.loadString('assets/livros/nao-existe-$a'))` ou `StateError`), afirmando a frase exata `findsOneWidget`, o texto do erro `findsNothing` e `takeException()` não nulo.
- **Verify**: reaplicar M12 (`app.dart:37` `on Object` → `on FormatException`) num rascunho → o teste novo falha.
- **Priority**: Major · ~10 min

### Fix 2: AC-15 "Sistema segue o aparelho" só em um sentido

- **Root cause**: `app_test.dart:97-104` só testa aparelho escuro; `Tema.sistema` → `ThemeMode.dark` passa. M13 sobrevive.
- **Fix task**: parametrizar o teste de Sistema sobre `Brightness.values` (aparelho claro → claro, escuro → escuro).
- **Verify**: reaplicar M13 (`preferencias.dart:4`) → falha com aparelho claro.
- **Priority**: Major · ~5 min

### Fix 3: AC-10 não afirma o texto do ponto aberto

- **Root cause**: `capitulo_page_test.dart:48-55` afirma só a referência do 82.
- **Fix task**: acrescentar `expect(find.text('Segundo ponto da oração.'), findsOneWidget)` depois do toque (o finder padrão ignora a rota offstage).
- **Verify**: a sonda P5 já mostrou que a asserção passa no HEAD.
- **Priority**: Minor · ~2 min

### Spec-precision: AC-01 com id de obra não-texto

- **Decision needed (spec)**: "mensagem nomeando a obra" não se aplica quando o id não é texto. Sugestão: o spec aceita "mensagem cita `colecao.json` e o valor recusado" (o código já põe o valor em `FormatException.source`), e `ler_colecao_test.dart:57` passa a afirmar isso. ~5 min.

---

## Requirement Traceability Update

| Requirement | Previous Status | New Status |
| --- | --- | --- |
| BASE-01 | Implementing | ✅ Verified (spec-precision gap no caso do id não-texto) |
| BASE-02 | Implementing | ✅ Verified |
| BASE-03 | Implementing | ✅ Verified |
| BASE-04 | Implementing | ✅ Verified |
| BASE-05 | Implementing | ❌ Needs Fix (Fix 1 — só teste) |
| LER-01 | Implementing | ✅ Verified |
| LER-02 | Implementing | ✅ Verified |
| LER-03 | Implementing | ✅ Verified |
| LER-04 | Implementing | ✅ Verified |
| LER-05 | Implementing | ❌ Needs Fix (Fix 3 — só teste, menor) |
| LER-06 | Implementing | ✅ Verified |
| LER-07 | Implementing | ✅ Verified |
| LER-08 | Implementing | ✅ Verified |
| LER-09 | Implementing | ✅ Verified |
| PREF-01 | Implementing | ❌ Needs Fix (Fix 2 — só teste) |
| PREF-02 | Implementing | ✅ Verified |
| PREF-03 | Implementing | ✅ Verified |
| PREF-04 | Implementing | ✅ Verified |
| TIPO-01 | Implementing | ✅ Verified |
| TIPO-02 | Implementing | ✅ Verified |

(O Verifier não edita `spec.md`; o orquestrador aplica esta tabela.)

---

## Summary

**Overall**: ❌ Not Ready — o comportamento está certo; a suíte ainda não segura dois ACs.

**Spec-anchored check**: 17/20 ACs com o resultado afirmado por inteiro | 3 parciais (AC-05, AC-15, AC-10) | 1 spec-precision gap (AC-01)
**Sensor**: 19/21 mutations killed (M12, M13 survived)
**Gate**: exit 0 — motor 38 · app 44 · validador 3 passed, 0 failed; APK debug gerado com Literata e livros/

**What works**: fronteira do motor (tipo errado, repetido, capítulo inexistente) e validar.py (exit 1); porta `carregarColecao` usada pelo app e pelo contrato; biblioteca → obra → capítulo → ponto; anterior/próximo atravessando capítulos e escondidos nas pontas; tema, escala multiplicativa, persistência e fallback das preferências; Literata empacotada; contraste AA.

**Issues found**: Fix 1 (AC-05, M12), Fix 2 (AC-15, M13), Fix 3 (AC-10, menor), decisão de spec para AC-01.

**Next steps**: aplicar Fix 1–3 (~20 min, só testes) → re-verificar (rodada 1 de 3). Depois do merge, o "Done means" do `AGENTS.md` ainda está pendente: o diff não toca `docs/` (`roadmap.md` v0.2 segue 🗓️; `backlog.md` não tem o gesto de deslizar nem as telas de boas-vindas que o Out of Scope do spec manda para lá; `dominios.md`; `docs/LESSONS.md`). Também falta o UAT no aparelho (TD-004).
