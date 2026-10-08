# CI (v0.1) Validation

**Date**: 2026-10-08
**Spec**: `.specs/features/ci/spec.md`
**Diff range**: `e5f4423..d0c901f` (branch `feat/v0.1-ci`, 3 commits: `b48d7f1` spec + AD-012, `82d182d` `tool/check.sh` + `AGENTS.md`, `d0c901f` `.github/workflows/ci.yml`). Superfície do diff: `tool/check.sh`, `.github/workflows/ci.yml`, `AGENTS.md`, `.specs/STATE.md`, `.specs/features/ci/spec.md`. Nenhum arquivo de produto nem de teste.
**Verifier**: independent sub-agent (author ≠ verifier)
**Verdict**: ✅ PASS (rodada 0) — com **evidência remota pendente**. Os 9 ACs têm evidência local (7 totalmente, CI-01 e CI-03 "local evidence PASS — remote run pending"). O gate passa em `TZ=UTC` (livros 6, motor 64, app 230, codegen sem diff). Os 6 mutantes do spec morrem, cada um no passo certo, e o controle do CI-04 prova que é o `export TZ` do próprio script que mata o mutante do fuso. Falta, fora do alcance do Verifier: o run verde no GitHub (CI-01, CI-03, Success Criteria 1).

Toda a mutação rodou num clone de rascunho (`git clone --branch feat/v0.1-ci`, em `/tmp/.../scratchpad/verify`), resetado entre mutantes. A árvore real só recebeu este arquivo. Nada foi commitado.

---

## Task Completion

Escopo Medium: o spec diz "tarefas implícitas no Execute" e não há `tasks.md` (`ls .specs/features/ci` → só `spec.md` antes deste relatório). Os 3 commits cobrem spec/AD-012, portão local e workflow. N/A por tarefa.

---

## Spec-Anchored Acceptance Criteria

Linhas de `tool/check.sh` (`check.sh:N`) e de `.github/workflows/ci.yml` (`ci.yml:N`) são da árvore em `d0c901f`.

| AC | Evidência (comando → resultado, ou `file:line`) | Resultado do spec | Status |
| --- | --- | --- | --- |
| CI-01 push → 4 portões em ordem, um passo cada | Leitura: `ci.yml:5-7` (`push:` sem filtro de branch + `workflow_dispatch:`); `ci.yml:33-43` quatro passos `tool/check.sh livros`, `motor`, `app`, `codegen`, nessa ordem, nomes `livros — …`, `motor — …`, `app — …`, `codegen — …`. Conteúdo de cada portão: `check.sh:18-20` (validar.py + unittest), `:23-27` (`dart analyze --fatal-infos` + `dart test`), `:30-34` (`flutter analyze --fatal-infos` + `flutter test`), `:39-50` (build_runner + comparação). YAML parseia (`yaml.safe_load`: 4 passos de portão, 0 chaves extras). Ordem no script: `TZ=UTC tool/check.sh` → linhas `== check: livros`(1), `motor`(18), `app`(138), `codegen`(511), `passed (livros motor app codegen)`, exit 0 | run verde no GitHub com os 4 passos | ✅ PASS local · ⏳ **run remoto pendente** |
| CI-02 falha de comando → run falha; nome do passo diz o portão; sem skip nem `continue-on-error` | `grep -nE 'continue-on-error\|if:\|secrets\.' ci.yml` → exit 1 (vazio). Nomes de passo: `ci.yml:33,36,39,42`. Código de saída propaga: os 6 mutantes saem 1 (tabela do sensor); `set -euo pipefail` `check.sh:4`; o `trap EXIT` imprime `== check: <gate> FAILED` (`check.sh:72`) e foi visto nos 6 mutantes. Sem argumento, o primeiro vermelho para o resto: mutante `livros` com `tool/check.sh` → exit 1, só `== check: livros` e `== check: livros FAILED`, `motor` não rodou | passo nomeado, nada pulado | ✅ PASS (ver gap 2 sobre o nome "código gerado") |
| CI-03 Flutter 3.41.7 exato | `ci.yml:30` `flutter-version: 3.41.7` (string, `yaml.safe_load` → `<class 'str'>`); `ci.yml:29` `channel: stable`; as entradas `channel`, `flutter-version`, `cache` existem em `subosito/flutter-action@1a44944…/action.yaml` (`gh api`). Local: `flutter --version` → `Flutter 3.41.7` | log do passo de setup mostra `Flutter 3.41.7` | ✅ PASS local · ⏳ **log remoto pendente** |
| CI-04 fuso `America/Sao_Paulo` mesmo com a máquina em UTC | `check.sh:12` `export TZ=America/Sao_Paulo`. Sensor M5 (`toLocal()` → `momento`, shell `TZ=UTC`): `TZ=UTC tool/check.sh app` → **exit 1**, 10 testes falham, incluindo `REF-07 hours and minutes are written as 6h40` com `Expected: '12 de março de 2026, 6h40'  Actual: '12 de março de 2026, 9h40'`. Controle: mesmo mutante, `export TZ` **e** o guard removidos, `TZ=UTC tool/check.sh app` → exit 0, `+230: All tests passed!` | mutante sai ≠ 0 numa shell `TZ=UTC` | ✅ PASS (ver nota do controle abaixo) |
| CI-05 `.g.dart` desatualizado → vermelho + diff; em dia → verde e árvore limpa | Sensor M6 (coluna `humor` em `Reflexoes`, sem build_runner): `tool/check.sh codegen` → **exit 1**, imprime `check: generated code was out of date — commit the regenerated files:`, `M lib/registro/banco_registro.g.dart` e o diff completo (`+  late final GeneratedColumn<String> humor = …`), termina com `== check: codegen FAILED`; `git status --short` na árvore: `M banco_registro.dart`, `M banco_registro.g.dart` (regenerado, pronto para commit). Metade verde: clone limpo, `TZ=UTC tool/check.sh codegen` → exit 0; `git status --porcelain` → 0 linhas (também 0 linhas depois do portão inteiro). Lógica em `check.sh:39-50` | vermelho com diff; verde com árvore limpa | ✅ PASS (ver gap 1 sobre "commitado") |
| CI-06 `tool/check.sh` sem arg / com nome / nome desconhecido | Sem arg: ordem acima, exit 0. `tool/check.sh motor` → só `== check: motor` e `== check: passed (motor)`, exit 0. `tool/check.sh nada` → `check: unknown gate 'nada' — valid gates: livros motor app codegen`, **exit 2** (`check.sh:64`). Dois argumentos `tool/check.sh livros motor` → `usage: tool/check.sh [gate] — gates: livros motor app codegen`, **exit 2** (`check.sh:57`). Sem arg com portão vermelho → exit ≠ 0 (ver CI-02) | os 4 na ordem, exit 0 só se todos passam; só o nomeado; desconhecido ≠ 0 listando nomes | ✅ PASS |
| CI-07 `AGENTS.md` aponta para `tool/check.sh` | `AGENTS.md:38` `tool/check.sh   # the whole gate, as CI runs it: livros, motor, app, codegen` e `:39` `tool/check.sh app   # one gate; it pins TZ=America/Sao_Paulo itself` (› Commands); `:51` `` `tool/check.sh` exits 0 — the same gate CI runs on every push. `` (› Done means). Os comandos avulsos continuam em `:40-46` | Commands aponta para o script como o portão de "Done means"; avulsos mantidos | ✅ PASS |
| CI-08 só `contents: read`, sem segredo, actions de terceiro por SHA | `ci.yml:10-11` `permissions: contents: read`. `grep -n 'secrets\.\|GITHUB_TOKEN' ci.yml` → exit 1. `uses:` só em `:21` (`actions/checkout@v7`, ação `actions/*`, isenta) e `:27` `subosito/flutter-action@1a449444c387b1966244ae4d4f8c696479add0b2 # v2.23.0` (40 hex + versão em comentário). `gh api repos/subosito/flutter-action/git/ref/tags/v2.23.0` → `1a449444c387b1966244ae4d4f8c696479add0b2 commit` (o SHA é mesmo o do v2.23.0). Extra: `persist-credentials: false` (`:23`) | token só leitura; sem segredo; terceiros presos por SHA com versão | ✅ PASS |
| CI-09 push novo cancela o run em andamento | `ci.yml:13-15` `concurrency: group: ci-${{ github.ref }}` e `cancel-in-progress: true` | `concurrency` com `cancel-in-progress` | ✅ PASS |

**Status**: ⚠️ 9/9 ACs com o resultado do spec comprovado localmente; CI-01 e CI-03 dependem de um run no GitHub (**remote evidence pending**, não conta como falha). 2 spec-precision gaps Minor e 2 observações (ver "Spec-precision gaps").

**Remote evidence pending**: CI-01 (run verde com os 4 passos, `gh run watch`), CI-03 (log do passo de setup com `Flutter 3.41.7`) e o Success Criteria 1 (run ≤ 10 min). Acontece depois do push; o Verifier não empurra. Observável: `gh run list --branch feat/v0.1-ci` e `gh run view --log`.

---

## Discrimination Sensor

Cada mutante é um dos 6 do Edge Cases do spec, aplicado no clone de rascunho (`TZ=UTC tool/check.sh <gate>`). Expectativa do spec: exit ≠ 0 no passo indicado.

| # | Gate | Mutante (arquivo:linha no clone) | Exit | Linha / evidência | Killed? |
| --- | --- | --- | --- | --- | --- |
| M1 | `livros` | `livros/caminho.json:458` o ponto `"numero": 2` vira `1` (dois pontos de mesmo número) | 1 | `caminho.json: FALHOU` · `erro:   ponto 1 repetido` · `== check: livros FAILED` | ✅ Killed (validar.py) |
| M2 | `livros` | `livros/test_validar.py:43` `assertIn("ponto 3 repetido", erros)` → `assertNotIn` | 1 | `FAIL: test_base02_numero_repetido_e_erro` · `FAILED (failures=1)` · `== check: livros FAILED` | ✅ Killed (unittest) |
| M3 | `motor` | `packages/ponto_motor/lib/src/colecao/colecao.dart:18` `obras.where` → `this.obras.where` | 1 | `info - lib/src/colecao/colecao.dart:18:28 - Unnecessary 'this.' qualifier … - unnecessary_this` · `== check: motor FAILED` (morreu no analyze, antes do `dart test`) | ✅ Killed (analyze `--fatal-infos`) |
| M4 | `motor` | `colecao.dart:28` `referenciaDe` devolve `numero: ponto.id.numero + 1` (número de outro ponto) | 1 | analyze `No issues found!` e então `test/colecao/referencia_test.dart: names the work, the chapter and the number [E]` · `Expected: <2>  Actual: <3>` · `== check: motor FAILED` | ✅ Killed (dart test) |
| M5 | `app` | `apps/ponto_mobile/lib/registro/data_da_reflexao.dart:21` `momento.toLocal()` → `momento`, shell `TZ=UTC` | 1 | 10 falhas (6 em `data_da_reflexao_test.dart`): `Expected: '12 de março de 2026, 6h40'  Actual: '12 de março de 2026, 9h40'` · `== check: app FAILED` | ✅ Killed (flutter test) — CI-04 |
| M6 | `codegen` | `apps/ponto_mobile/lib/registro/banco_registro.dart:19` coluna nova `TextColumn get humor => text().nullable()();`, sem build_runner | 1 | `check: generated code was out of date — commit the regenerated files:` + diff com `humor` · `== check: codegen FAILED` | ✅ Killed — CI-05 |

**Sensor depth**: lightweight, e aqui exaustivo no que o spec lista (os 6 do Edge Cases; o portão é código de infra, não caminho P0 de dados).
**Result**: 6/6 killed — PASS ✅.

### Controles e sondas (descartáveis, só no clone)

| # | Sonda | Resultado |
| --- | --- | --- |
| C1 | Controle CI-04, forma literal: M5 + apagar só `export TZ=America/Sao_Paulo`, rodar `TZ=UTC tool/check.sh app` | exit 1 com `check: TZ=UTC did not take effect (is tzdata installed?)`. Os testes nem rodaram: o **guard** (`check.sh:13-16`) pega o `TZ=UTC` antes. Não deu "passa" |
| C2 | Controle CI-04, completo: M5 + apagar o `export TZ` **e** o guard, `TZ=UTC tool/check.sh app` | **exit 0**, `00:29 +230: All tests passed!` → o mutante sobrevive sem o pin, então o `export TZ` do script é o que o mata (CI-04 provado) |
| C3 | Guard de TZ (clone limpo): `TZDIR=<pasta vazia> tool/check.sh livros` | **exit 1**, `check: TZ=America/Sao_Paulo did not take effect (is tzdata installed?)`; nenhum portão rodou |
| C4 | `tool/check.sh codegen` duas vezes seguidas com M6 aplicado | 1ª exit 1, 2ª **exit 0** (`== check: passed (codegen)`) com `banco_registro.g.dart` modificado e não commitado — ver gap 1 |

---

## Edge Cases

- [x] `livros/caminho.json` com dois pontos de mesmo número → `livros` vermelho (M1).
- [x] teste de `livros/test_validar.py` com expectativa invertida → `livros` vermelho (M2).
- [x] `this.` desnecessário em `packages/ponto_motor/lib` → `motor` vermelho no analyze (M3).
- [x] `Colecao.referenciaDe` devolvendo o número de outro ponto → `motor` vermelho no test (M4).
- [x] `toLocal()` removido, shell em `TZ=UTC` → `app` vermelho (M5).
- [x] coluna nova em `banco_registro.dart` sem `build_runner` → `codegen` vermelho (M6).
- [ ] "Falha de download do Flutter, do pub ou do `sqlite3mc` no runner → vermelho no passo de setup": **não verificável localmente**. Por construção não há `continue-on-error` nem `if:` (grep vazio) e cada `run:` é um comando que sai ≠ 0 numa falha, mas nenhuma falha de rede foi reproduzida. Fica para a observação remota, sem retry (como o spec define).

---

## Code Quality

| Principle | Status |
| --- | --- |
| Minimum code (script de 78 linhas, workflow de 43, sem abstração a mais) | ✅ |
| Surgical changes (só `tool/`, `.github/workflows/`, `AGENTS.md`, `STATE.md` e o spec) | ✅ |
| No scope creep (nada de `--estrito`, APK, cobertura, Dependabot: tudo fora do escopo do spec) | ✅ |
| Matches patterns (convenção `tool/`, comentários com prefixo `INVARIANT:` / `SECURITY:` / `COMPAT:` como o `AGENTS.md` pede) | ✅ |
| Spec-anchored outcome check (cada AC conferido contra a saída/linha que o spec define) | ✅ |
| Per-layer Coverage Expectation (um portão de infra: cada gate tem um mutante que o derruba, tabela acima) | ✅ |
| Every test maps to a spec requirement — no unclaimed tests (o diff não toca teste algum) | ✅ N/A |
| Documented guidelines followed: `AGENTS.md` (Commands, Done means), TD-006 (Flutter fixo), AD-012 | ✅ |
| Guard de TZ (`check.sh:13-16`) é comportamento que nenhum AC pede | ⚠️ Observação: coberto pela sonda C3, e é uma proteção legítima do INVARIANT, mas não rastreia a um ID |

---

## Gate Check

- **Gate command**: `TZ=UTC tool/check.sh` (clone limpo, sem `.dart_tool` nem `build`)
- **Result**: exit 0, `== check: passed (livros motor app codegen)`, ~150 s no total (livros < 1 s, motor ~5 s, app ~46 s, codegen ~65 s a frio)
- **Testes**: livros 6 (`Ran 6 tests … OK`), motor 64 (`+64: All tests passed!`), app 230 (`+230: All tests passed!`), `dart analyze`/`flutter analyze` `No issues found!`
- **Test count before feature**: livros 6, motor 64, app 230 (o `voltar/validation.md` registra os mesmos números)
- **Test count after feature**: 6 / 64 / 230
- **Delta**: 0 (o diff não toca testes nem código de produto)
- **Skipped tests**: nenhum
- **Failures**: nenhuma
- **Árvore após o portão**: `git status --porcelain` → vazio

---

## Spec-precision gaps

| # | Onde | Leitura em aberto | Gravidade |
| --- | --- | --- | --- |
| 1 | CI-05 | "WHEN `banco_registro.dart` muda e o `.g.dart` **commitado** não foi regenerado" pode ser lido como "contra o HEAD" ou "contra a árvore de trabalho". A implementação compara com a árvore (checksums antes/depois do build_runner, `check.sh:41-43`) e o spec diz que o `.g.dart` fica regenerado "pronto para commit". Efeito comprovado (C4): a 2ª execução local sai 0 com o `.g.dart` regenerado e **não commitado**; o portão local verde ali não prova que o commit está certo. No CI a árvore é o commit, então o remoto é estrito. | Minor |
| 2 | CI-02 | O AC pede o nome do passo dizendo "livros, motor, app, código gerado"; o passo se chama `codegen — drift code up to date` (`ci.yml:42`). O CI-01 nomeia o portão `codegen`, então as duas leituras passam, mas o spec usa dois nomes para o mesmo portão. | Minor |
| 3 | CI-04 (verificação) | O sensor do spec ("`tool/check.sh app` sai ≠ 0 numa shell `TZ=UTC`") passa por dois mecanismos distintos conforme se apaga o pin: com o pin (`check.sh:12`) os testes pegam o mutante (M5); sem o pin, o guard (`check.sh:13-16`) sai 1 antes dos testes (C1). Só tirando os dois o mutante sobrevive (C2). O AC não diz que o guard existe. | Minor (informativa) |
| 4 | Success Criteria 3 | "`docs/roadmap.md` › v0.1 marca a linha de CI como ✅" não foi feito no diff: `docs/roadmap.md:50` ainda `🗓️`, e a Requirement Traceability do spec segue `Pending`. É a reconciliação de "Done means" depois que a feature pousa, não um AC. | Pendência de fechamento |

Não há AC sem resultado observável além dos dois remotos (CI-01, CI-03) e do Edge Case de falha de rede.

---

## Requirement Traceability Update

Não alterado neste relatório (o Verifier só escreve `validation.md`). Estado recomendado após o run verde no GitHub:

| Requirement | Previous Status | Recomendado |
| --- | --- | --- |
| CI-02, CI-04..CI-09 | Pending | ✅ Verified (local) |
| CI-01, CI-03 | Pending | ⏳ Verified local · remoto pendente → ✅ após `gh run watch` |

---

## Summary

**Overall**: ✅ Ready (com evidência remota pendente)

**Spec-anchored check**: 9/9 ACs com o resultado do spec comprovado localmente (CI-01 e CI-03 também precisam do run no GitHub); 2 spec-precision gaps Minor + 1 informativo
**Sensor**: 6/6 mutations killed, cada uma no passo que o spec nomeia (exit 1); controle C2 prova que o `export TZ` é o que mata M5
**Gate**: `TZ=UTC tool/check.sh` exit 0 (livros 6, motor 64, app 230, codegen limpo)

**What works**: o portão local e o workflow; a ordem dos 4 portões; o exit code propaga; o `export TZ` e o guard; o diff do `codegen` no vermelho e a árvore limpa no verde; `permissions: contents: read`, ação de terceiro presa por SHA do v2.23.0 (conferido por `gh api`), `concurrency` com `cancel-in-progress`.

**Issues found**: nenhum bloqueante. Gaps 1 e 2 são de redação do spec (~5 min cada); a pendência 4 é a reconciliação do roadmap (~2 min).

**Next steps**: empurrar `feat/v0.1-ci` e observar `gh run watch` (4 passos verdes, log do setup com `Flutter 3.41.7`, run ≤ 10 min); então marcar a linha de CI do `docs/roadmap.md` como ✅ e os ACs como Verified.

---

## Remote evidence (orquestrador, depois do push autorizado)

Run [37803142776](https://github.com/gustavofsousa/ponto-caminho/actions/runs/37803142776) — push de
`feat/v0.1-ci` em `d0c901f`, **success**, job de 15:43:53Z a 15:47:31Z (**3 min 41 s**, Success Criteria 1: ≤ 10 min ✅).

| AC | Evidência no log (`gh run view 37803142776 --log`) | Status |
| --- | --- | --- |
| CI-01 | Passos `livros — validar.py + Python tests`, `motor — analyze + tests`, `app — analyze + tests`, `codegen — drift code up to date`, nessa ordem, todos `success`; `Ran 6 tests` · `🎉 64 tests passed.` · `🎉 230 tests passed.` · `Built with build_runner/aot in 46s` + `== check: passed (codegen)` | ✅ PASS |
| CI-03 | Setup: `flutter-version: 3.41.7`, `FLUTTER_ROOT: /opt/hostedtoolcache/flutter/stable-3.41.7-x64/flutter`, chave de cache com a revisão `cc0734ac716f…` — a mesma do `flutter --version` local (`revision cc0734ac71`) | ✅ PASS |

**Verdict final**: ✅ PASS — 9/9 ACs com evidência, local e remota.

Re-execução da afirmação mais arriscada (orquestrador, clone limpo): mutante `toLocal()` → `momento`,
`TZ=UTC tool/check.sh app` → `+220 -10: Some tests failed.`, `== check: app FAILED`, exit 1 — confere com M5.
