# CI (v0.1) — Specification

**Escopo:** Medium (um workflow + um script de portão; sem código de produto) · **Roadmap:** v0.1
"Fundações", linha "CI: `validar.py`, lint, testes do motor" (🗓️) · **Branch proposta:** `feat/v0.1-ci`
(sobre `feat/v0.4-voltar`, para testar o código mais novo)
**Fontes:** [`docs/roadmap.md`](../../../docs/roadmap.md) v0.1 · [`docs/backlog.md`](../../../docs/backlog.md) › `infra` ·
[`AGENTS.md`](../../../AGENTS.md) › Commands, Done means · TD-001, TD-006 · AD-004

## Problem Statement

O portão de qualidade do projeto (validar os livros, lint, testes do motor e do app) só roda quando
alguém lembra de rodar, na máquina do Gustavo, que está no fuso de São Paulo. Duas falhas já passam
caladas: o teste de data só pega a falta de `toLocal()` fora de UTC (comprovado em 2026-10-08: com o
mutante, 6/6 passam em `TZ=UTC` e 6/6 falham em `TZ=America/Sao_Paulo`), e um `banco_registro.g.dart`
desatualizado só aparece se alguém rodar o `build_runner`. A v1.0 vai trocar o texto mock pelo real e
mexer em todas as telas (acessibilidade, tipografia) — mudanças largas que precisam de um portão que
roda sozinho a cada push.

## Goals

- [ ] Todo push ao GitHub roda o portão inteiro e termina vermelho se qualquer verificação falhar.
- [ ] O mesmo portão roda localmente com **um** comando, no mesmo fuso, com o mesmo resultado.
- [ ] As duas falhas caladas de hoje (fuso, código gerado desatualizado) deixam o portão vermelho.

## Out of Scope

| Item | Motivo |
| --- | --- |
| `validar.py --estrito` no CI | Mock é legítimo até a v1.0 (TD-001); `--estrito` é o portão de release, entra com "build instalável" (v1.0) |
| Gerar APK/AAB, assinar, distribuir | Linha "build instalável distribuído ao leitor de teste" (v1.0) |
| Runner macOS / pipeline iOS / TestFlight | TD-005 › pipeline iOS (backlog `infra`) |
| Regra de proteção de branch no GitHub | Muda configuração do repositório remoto; decidir quando houver PRs de fato |
| Cobertura com meta mínima, badge no README | Não pedido; o portão é passa/falha |
| Dependabot/Renovate | TD-006 prende `drift_dev`/`sqlite3` à versão do Flutter; atualização é manual e explícita |
| Teste em aparelho/emulador no CI | TD-004 continua sendo UAT humano |

---

## Assumptions & Open Questions

| # | Decisão | Default escolhido | Motivo | Confirmado? |
| --- | --- | --- | --- | --- |
| A1 | **Onde roda o CI** (backlog › `infra`: decisão macro) | **GitHub Actions**, runner `ubuntu-latest` | Repo é público → minutos ilimitados nos runners padrão; mesmo lugar do código; Codemagic só se paga com assinatura iOS, que não está no roadmap próximo | sim (usuário, RFD, 2026-10-08) — AD-012 |
| A2 | Quando roda | `push` em qualquer branch + `workflow_dispatch` (rodar à mão) | Fluxo solo com branches empilhadas; PR do próprio repo já é coberto pelo push | sim (aceito ao aprovar o spec) |
| A3 | Onde mora a lógica do portão | Script `tool/check.sh` (convenção `tool/` do Dart); o workflow só chama o script, um passo por portão | Ponto de entrada fino: o YAML orquestra, o script decide. Permite provar o portão localmente sem push | sim (aceito ao aprovar o spec) |
| A4 | Onde o fuso é fixado | **Dentro do script** (`TZ=America/Sao_Paulo`), não só no YAML | Assim o portão local num aparelho em UTC também pega o erro; o fuso é o do público real (sem horário de verão desde 2019, deslocamento fixo −3). Se o fuso não pegar (sem tzdata, a libc cai em UTC calada), o script falha antes de qualquer portão | sim (aceito ao aprovar o spec) |
| A5 | Versão do Flutter no CI | **3.41.7** fixa (a do ambiente de dev) | TD-006: subir o Flutter é um commit explícito, nunca uma troca silenciosa do runner | sim (aceito ao aprovar o spec) |
| A6 | Python no CI | `python3` do próprio runner, sem `setup-python` | `validar.py` e seus testes só usam a stdlib | sim (aceito ao aprovar o spec) |
| A7 | Como provar o CI vermelho | Sensor de discriminação **local** sobre `tool/check.sh` (mutantes, nunca commitados); no GitHub, **um** run verde observado | Empurrar branches com defeito a um repo público só para ver vermelho é ruído; o YAML só repassa o código de saída do script | sim (aceito ao aprovar o spec) |

**Open questions:** nenhuma. A1 decidida no RFD; A2–A7 são defaults do agente, aceitos sem objeção ao aprovar o spec.

---

## User Stories

### P1: O portão roda sozinho a cada push ⭐ MVP

**User Story**: Como único desenvolvedor, quero que todo push rode o portão inteiro no GitHub, para
que uma regressão não dependa de eu lembrar de rodar os testes.

**Acceptance Criteria** (Quick Capture):

1. **CI-01** — WHEN um commit é enviado a qualquer branch de `origin` THEN o GitHub SHALL rodar um
   workflow que executa quatro portões, nesta ordem e cada um num passo com nome próprio:
   `livros` (`validar.py` modo dev + testes Python de `livros/`), `motor` (`dart analyze --fatal-infos`
   + `dart test`), `app` (`flutter analyze --fatal-infos` + `flutter test`) e `codegen` (CI-05).
   · *Verification:* run verde observado no GitHub (`gh run watch`) com os quatro passos listados ·
   *Priority:* Required
2. **CI-02** — WHEN qualquer comando do portão sai com código ≠ 0 THEN o run SHALL terminar com
   falha, e o nome do passo que falhou SHALL dizer qual portão (`livros`, `motor`, `app`, `codegen`).
   Nenhum passo é pulado nem marcado `continue-on-error`. · *Verification:* sensor local (Edge Cases)
   + leitura do YAML · *Priority:* Required
3. **CI-03** — WHEN o workflow roda THEN SHALL usar Flutter **3.41.7** exatamente (A5). ·
   *Verification:* log do passo de setup mostra `Flutter 3.41.7` · *Priority:* Required

### P1: O portão pega as falhas que hoje passam caladas ⭐ MVP

**User Story**: Como desenvolvedor no fuso de São Paulo, quero que o portão rode fora de UTC e confira o
código gerado, para que as duas falhas conhecidas não cheguem à `main`.

**Acceptance Criteria**:

1. **CI-04** — WHEN os testes do app rodam no portão (local ou CI) THEN o fuso SHALL ser
   `America/Sao_Paulo`, mesmo que a máquina esteja em UTC. · *Verification:* sensor — com
   `momento.toLocal()` trocado por `momento` em `data_da_reflexao.dart`, `tool/check.sh app` sai ≠ 0
   numa shell com `TZ=UTC` · *Priority:* Required
2. **CI-05** *[revised r1]* — WHEN o `.g.dart` da árvore de trabalho difere do que o `build_runner`
   gera a partir de `banco_registro.dart` THEN o portão `codegen` SHALL falhar e imprimir o diff,
   deixando o `.g.dart` regenerado na árvore, pronto para commit. WHEN o `.g.dart` está em dia THEN o
   passo SHALL passar e a árvore SHALL continuar limpa (`git status --porcelain` vazio). No CI a
   árvore é o commit, então o verde do CI prova o arquivo **commitado**; localmente, uma segunda
   rodada passa porque o arquivo já foi regenerado — o verde local só vale para o que for commitado.
   *(r1: o texto dizia "o `.g.dart` commitado", mas o script compara com a árvore — Verifier, gap 2.)*
   · *Verification:* sensor — acrescentar uma coluna a uma tabela sem regenerar → vermelho; árvore
   limpa → verde · *Priority:* Required

### P2: Um comando para o mesmo portão na máquina local

**User Story**: Como desenvolvedor, quero rodar localmente exatamente o portão do CI com um comando,
para saber antes do push se ele vai passar.

**Acceptance Criteria**:

1. **CI-06** — WHEN `tool/check.sh` roda sem argumento na raiz THEN SHALL executar os quatro portões
   de CI-01 na mesma ordem e sair 0 só se todos passarem; WHEN roda com um nome de portão (`livros`,
   `motor`, `app`, `codegen`) THEN SHALL executar só esse; WHEN o nome é desconhecido THEN SHALL sair
   ≠ 0 listando os nomes válidos. · *Verification:* comandos do Verifier registrados em `validation.md`
   (um teste do portão rodando dentro do próprio portão seria recursivo; a escolha de argumentos tem
   poucas linhas) · *Priority:* Should
2. **CI-07** — WHEN o portão local termina THEN o `AGENTS.md` › Commands SHALL apontar para
   `tool/check.sh` como o portão de "Done means" (os comandos avulsos continuam documentados).
   · *Verification:* leitura do doc · *Priority:* Should

### P2: O CI não abre porta nova

**User Story**: Como dono de um repo público, quero que o workflow não tenha mais permissão do que
precisa, para que uma action de terceiro comprometida não escreva no repositório.

**Acceptance Criteria**:

1. **CI-08** — WHEN o workflow roda THEN o token SHALL ter só `contents: read`, nenhum segredo SHALL
   ser lido, e toda action de terceiro (fora de `actions/*`) SHALL estar presa por SHA de commit,
   com a versão em comentário. · *Verification:* leitura do YAML · *Priority:* Should
2. **CI-09** — WHEN um novo push chega à mesma branch com um run em andamento THEN o run antigo SHALL
   ser cancelado. · *Verification:* leitura do YAML (`concurrency` com `cancel-in-progress`) ·
   *Priority:* Could

---

## Edge Cases

Cada linha é um mutante do sensor de discriminação (A7) — aplicado numa cópia de trabalho, nunca
commitado — e o portão SHALL sair ≠ 0 no passo indicado:

| Mutante | Portão que SHALL ficar vermelho |
| --- | --- |
| `livros/caminho.json` com dois pontos de mesmo número | `livros` (`validar.py`) |
| um teste de `livros/test_validar.py` com expectativa invertida | `livros` (unittest) |
| um `this.` desnecessário em `packages/ponto_motor/lib` (lint `unnecessary_this`, nível info) | `motor` (analyze `--fatal-infos`) |
| `Colecao.referenciaDe` devolvendo o número de outro ponto | `motor` (test) |
| `toLocal()` removido, shell em `TZ=UTC` | `app` (test) — CI-04 |
| coluna nova em `banco_registro.dart` sem `build_runner` | `codegen` — CI-05 |

- WHEN o download do Flutter, do pub ou do binário do `sqlite3mc` falha no runner THEN o run SHALL
  ficar vermelho no passo de setup — nunca verde com portão pulado.

## Implicit-requirement sweep (Medium → só as presentes)

| Dimensão | Resolução |
| --- | --- |
| External-dependency failure | Edge Case acima: falha de rede/download → vermelho, sem retry automático |
| Concurrency / ordering | CI-09 |
| Auth boundaries | CI-08 (token só leitura, sem segredos, actions por SHA) |
| Observability | CI-02 (um passo por portão, nome diz qual falhou) |
| Demais dimensões | N/A para este escopo — não há dado de usuário, estado nem entrada externa |

## Requirement Traceability

| ID | Story | Fase | Status |
| --- | --- | --- | --- |
| CI-01 | P1 portão a cada push | Execute | Pending |
| CI-02 | P1 portão a cada push | Execute | Pending |
| CI-03 | P1 portão a cada push | Execute | Pending |
| CI-04 | P1 falhas caladas | Execute | Pending |
| CI-05 | P1 falhas caladas | Execute | Pending |
| CI-06 | P2 comando local | Execute | Pending |
| CI-07 | P2 comando local | Execute | Pending |
| CI-08 | P2 sem porta nova | Execute | Pending |
| CI-09 | P2 sem porta nova | Execute | Pending |

**Coverage:** 9 total, 0 mapeados a tarefas (Medium: tarefas implícitas no Execute).

## Success Criteria

- [ ] Um push de `feat/v0.1-ci` mostra um run verde no GitHub, em ≤ 10 min, com os quatro passos de portão.
- [ ] Os seis mutantes da tabela de Edge Cases deixam `tool/check.sh` vermelho, cada um no passo certo.
- [ ] `docs/roadmap.md` › v0.1 marca a linha de CI como ✅.
