# Voltar (v0.4) — Tasks

## Execution Protocol (MANDATORY -- do not skip)

Implement these tasks with the `spec-driven` skill: **activate it by name and follow its Execute
flow and Critical Rules.** Do not search for skill files by filesystem path. The skill is the
source of truth for the full flow (per-task cycle, sub-agent delegation, adequacy review,
Verifier, discrimination sensor).

**If the skill cannot be activated, STOP and tell the user — do not proceed without it.**

---

**Design**: `.specs/features/voltar/design.md`
**Status**: Done — T1–T10 (verificação: `validation.md`). Três fases → execução inline, sem workers por fase.
**Tools**: nenhuma MCP além do Context7 já consultado no Design (drift, share_plus). Skills: `spec-driven`.

---

## Test Coverage Matrix

> Generated from codebase, project guidelines, and spec. Guidelines found: `AGENTS.md` (Done means:
> `validar.py` exit 0, análise sem issues, docs reconciliados), `.specs/STATE.md` AD-004 (ID do
> requisito no início do nome do teste), AD-011 (migração testada contra o schema anterior congelado).
> Fora isso, strong defaults. Tag de rastreio = o prefixo `LEI-0N:`/`CONT-0N:`… (AD-004).

| Code Layer | Required Test Type | Coverage Expectation | Location Pattern | Run Command |
| --- | --- | --- | --- | --- |
| Motor `leitura/`, `selecao/` (regras puras) | unit | Todos os ramos; 1:1 com os ACs; todas as saídas da fonte de aleatoriedade enumeradas | `packages/ponto_motor/test/{leitura,selecao}/*_test.dart` | `cd packages/ponto_motor && dart test` |
| Banco (schema + migração) | integration (arquivo real cifrado + cofre falso) | Migração feliz com linhas irmãs intactas (L-006), migração que falha com rollback (L-007), schema migrado = schema novo | `apps/ponto_mobile/test/registro/migracao_test.dart` | `cd apps/ponto_mobile && flutter test` |
| Repositório de leituras (drift) | integration (SQLite real em memória; arquivo para persistência e bytes) | Cada operação: efeito + ordem + distinção + limite + origem + linha estragada + relógio que volta | `apps/ponto_mobile/test/leitura/*_test.dart` | idem |
| Telas (página, home, continue, aleatório, compartilhar) | widget (banco em memória) | Cada AC: caminho feliz + cada cenário listado + vazio/erro/indisponível; todas as partes do Expected (L-003) | `apps/ponto_mobile/test/{leitura,selecao,colecao}/*_test.dart`, `test/inicio_page_test.dart` | idem |
| Abertura do app | widget | Home é a primeira tela; favorito em 3 toques | `apps/ponto_mobile/test/app_test.dart` | idem |
| Config (pubspec, `.g.dart`, Gradle) | none | build gate (inclui `flutter build apk --debug`) | — | build gate |

## Parallelism Assessment

| Test Type | Parallel-Safe? | Isolation Model | Evidence |
| --- | --- | --- | --- |
| Motor unit | Yes | Funções puras | `packages/ponto_motor/test/` |
| Repositório / telas | Yes | Um `NativeDatabase.memory()` novo por teste | `test/registro/banco_de_teste.dart` |
| Banco em arquivo | Yes | Diretório temporário por teste | `test/registro/abrir_registro_test.dart` |

As tarefas são sequenciais na prática: quase todas tocam `ponto_page.dart`, `banco_registro.dart` ou
`inicio_page.dart`. Nenhuma marcada `[P]`.

## Gate Check Commands

| Gate Level | When to Use | Command |
| --- | --- | --- |
| Quick (motor) | Tarefas só do motor | `cd packages/ponto_motor && dart format --output=none --set-exit-if-changed . && dart analyze --fatal-infos && dart test` |
| Quick (app) | Tarefas do app | `cd apps/ponto_mobile && dart format --output=none --set-exit-if-changed lib test && flutter analyze --fatal-infos && flutter test` |
| Build | Última tarefa de cada fase; tarefas sem teste | `python3 livros/validar.py && python3 -m unittest discover -s livros -p 'test_*.py' && (cd packages/ponto_motor && dart format --output=none --set-exit-if-changed . && dart analyze --fatal-infos && dart test) && (cd apps/ponto_mobile && dart format --output=none --set-exit-if-changed lib test && flutter analyze --fatal-infos && flutter test && flutter build apk --debug)` |

**Test count antes da feature:** motor 51 · app 171 · validador 6. **Depois das tarefas:** motor 64 · app 222 · validador 6 (230 no app depois dos fixes).

---

## Execution Plan

### Phase 1: Motor (Sequential)
```
T1 → T2
```

### Phase 2: Leitura no banco e na página (Sequential)
```
T2 → T3 → T4 → T5
```

### Phase 3: Telas, compartilhar e docs (Sequential)
```
T5 → T6 → T7 → T8 → T9 → T10
```

---

## Task Breakdown

### T1: Origem da leitura e "para onde o continue aponta" ✅

**What**: `OrigemDaLeitura` (com `emSequencia`) e `pontoParaContinuar`, exportados pelo motor.
**Context**: Motor tem `colecao/`, `registro/`, `selecao/`; nenhum `leitura/`. Feito quando o enum
fechado das 5 origens existe com `emSequencia` verdadeiro só em `biblioteca` e `continuacao`, e
`pontoParaContinuar(colecao, ids)` devolve o primeiro id (do mais novo ao mais antigo) que existe na
coleção, ou nulo. A filtragem por origem acontece na consulta do app (T4), com a regra vinda daqui.
**Where**: `packages/ponto_motor/lib/src/leitura/{leitura,continuar}.dart`, `lib/ponto_motor.dart`, `test/leitura/*_test.dart`
**Depends on**: None
**Reuses**: `obterPonto`
**Requirement**: LEI-02, CONT-01, CONT-04, CONT-05
**Done when**:
- [x] `emSequencia` testado para cada um dos 5 valores
- [x] `pontoParaContinuar`: lista vazia → nulo; primeiro existente vence; id de outra coleção / número inexistente pulado; todos inexistentes → nulo
- [x] Gate quick (motor) verde
**Tests**: unit · **Gate**: quick (motor)
**Commit**: `✨ feat(motor): add reading origins and where to continue`

---

### T2: Um ponto para agora ✅

**What**: `pontoAleatorio` e `janelaDeRecentes = 10` em `selecao/`.
**Context**: T1 feito. Feito quando o sorteio respeita a ordem estável de candidatos (obras na ordem
da coleção, pontos em ordem de leitura), exclui os 10 primeiros distintos de `recentes`, encolhe a
janela a partir do mais antigo quando o filtro fica sem candidato, filtra por obra e consulta a fonte
com `n` = número de candidatos. Testes enumeram todas as saídas de um `Random` falso.
**Where**: `packages/ponto_motor/lib/src/selecao/ponto_aleatorio.dart`, `lib/ponto_motor.dart`, `test/selecao/ponto_aleatorio_test.dart`
**Depends on**: T1
**Reuses**: `Colecao.obras`, `Obra.pontos`
**Requirement**: AGORA-01, AGORA-02, AGORA-03, AGORA-04, AGORA-05
**Done when**:
- [x] AC-15: índice k → k-ésimo candidato; `nextInt` chamado com n
- [x] AC-16: 11 recentes distintos → P1..P10 fora, P11 dentro
- [x] AC-17: repetições contam uma vez
- [x] AC-18: obra de 5 pontos todos recentes → sempre o lido há mais tempo
- [x] AC-19 (motor): filtro por obra; obra sem ponto → nulo; obra de 1 ponto que é o último lido → ele mesmo
- [x] Gate build verde (fim da fase)
**Tests**: unit · **Gate**: build
**Commit**: `✨ feat(motor): pick a point for now away from recent reads`

---

### T3: Tabela de leituras e migração do registro para o schema 2 ✅

**What**: capturar o schema 1 congelado **antes** de mexer no banco; tabela `Leituras`; `schemaVersion: 2`; `onUpgrade` numa transação.
**Context**: T2 feito; banco no schema 1 (v0.3). Primeiro passo: abrir `BancoRegistro` atual em
memória e copiar `sqlite_master` para `test/registro/schema_v1.dart` (fixture, AD-011). Depois:
`lib/leitura/tabela_leituras.dart`, registrar a tabela no `@DriftDatabase`, `build_runner`, migração.
Feito quando um arquivo cifrado criado com o schema 1 + uma reflexão editada, um favorito e uma
coleção com ponto abre pela `abrirRegistro` com tudo intacto e `user_version` = 2; e um arquivo onde a
criação falha (objeto `leituras` conflitante) dá registro indisponível com `user_version` = 1 e as
linhas intactas.
**Where**: `apps/ponto_mobile/lib/leitura/tabela_leituras.dart`, `lib/registro/banco_registro.dart` (+ `.g.dart`), `test/registro/schema_v1.dart`, `test/registro/migracao_test.dart`
**Depends on**: T2
**Reuses**: `abrirRegistro`, `cofre_de_teste.dart`, `abrirBancoCifrado`
**Requirement**: LEI-06, LEI-07
**Done when**:
- [x] AC-06: cada campo de cada linha da v0.3 igual depois da migração; `user_version` = 2; leitura gravada e lida de volta
- [x] Schema migrado (`sqlite_master`) = schema de um banco novo
- [x] AC-07: abertura → `null`; arquivo com `user_version` = 1 e as mesmas linhas; nenhuma tabela pela metade
- [x] Os 171 testes anteriores continuam verdes
- [x] Gate quick (app) verde
**Tests**: integration · **Gate**: quick (app)
**Commit**: `✨ feat(mobile): migrate the registro to schema 2 with a readings table`

---

### T4: Repositório de leituras ✅

**What**: `LeiturasRepositorio` (`registrar`, `observarLidosEmSequencia`, `listarRecentes`) exposto como `registro.leituras`.
**Context**: T3 feito (tabela existe). Feito quando gravar uma leitura guarda PontoId, origem e
`lidoEm` em UTC; as duas consultas devolvem pontos distintos do mais novo (maior id) para o mais
antigo, com limite, a primeira só com origens `emSequencia`; linha com PontoId estragado é ignorada;
reabrir o arquivo devolve o mesmo lugar (AC-11); e os bytes do arquivo cifrado não contêm o PontoId lido (AC-08).
**Where**: `apps/ponto_mobile/lib/leitura/leituras_repositorio.dart`, `lib/registro/registro.dart`, `test/leitura/leituras_repositorio_test.dart`
**Depends on**: T3
**Reuses**: `lerPontoIdGravado`, `RelogioDeTeste`, `abrirBancoDeTeste`
**Requirement**: LEI-01, LEI-08, CONT-01, CONT-03, AGORA-03
**Done when**:
- [x] `registrar`: PontoId, origem e `lidoEm` (= relógio, UTC) — cada parte afirmada (L-003)
- [x] Ordem por gravação mesmo com o relógio voltando; repetidos aparecem uma vez; limite respeitado
- [x] `observarLidosEmSequencia` ignora `aleatorio`/`favoritos`/`colecao`; emite de novo após gravar
- [x] Linha estragada ignorada e mantida no banco
- [x] AC-11 (persistência em arquivo) e AC-08 (bytes do arquivo cifrado)
- [x] Gate quick (app) verde
**Tests**: integration · **Gate**: quick (app)
**Commit**: `✨ feat(mobile): record readings and list recent and sequential ones`

---

### T5: A página do ponto grava a leitura com a origem ✅

**What**: `registrarLeitura`; `PontoPage(origem:)` grava ao abrir (uma vez) e a cada Anterior/Próximo (`biblioteca`); `CapituloPage` → `biblioteca`; `PontoGuardadoTile(origem:)` → `favoritos` / `colecao`.
**Context**: T4 feito. Todos os construtores de `PontoPage` (lib e testes) passam a origem. Feito
quando abrir pela biblioteca, por Favoritos e por uma coleção grava a origem certa; Anterior/Próximo
gravam um por ponto mostrado; trocar tema/tamanho e guardar reflexão não grava; falha (registro nulo,
erro do banco, erro que não é do banco) não aparece ao leitor e vai ao log só pelo tipo; nada vai às preferências.
**Where**: `apps/ponto_mobile/lib/leitura/registrar_leitura.dart`, `lib/colecao/{ponto_page,capitulo_page}.dart`, `lib/registro/{ponto_guardado_tile,favoritos_page,colecao_pessoal_page}.dart`, `test/leitura/leitura_na_pagina_test.dart`, testes que montam `PontoPage`
**Depends on**: T4
**Reuses**: `relatarFalhaNoRegistro`, `montarTela`, `testWidgetsComRegistro`
**Requirement**: LEI-01, LEI-02 (biblioteca, favoritos, colecao), LEI-03, LEI-04, LEI-05, LEI-08 (preferências)
**Done when**:
- [x] AC-01 pela tela (obra → capítulo → ponto)
- [x] AC-02 para Favoritos e coleção pessoal
- [x] AC-03, AC-04, AC-05 (a/b/c), AC-08 (preferências)
- [x] Gate build verde (fim da fase)
**Tests**: widget · **Gate**: build
**Commit**: `✨ feat(mobile): record each point the reader opens and how they got there`

---

### T6: Tela inicial ✅

**What**: `InicioPage` com "Biblioteca"; `abrirApp` abre nela; `LER-01` substituído por `INI-01`.
**Context**: T5 feito. Feito quando o app abre na home (título da coleção, preferências, "Biblioteca"
→ obras com Favoritos e Coleções) e um favorito fica a 3 toques. Continue e aleatório entram em T7/T8.
O teste `LER-01: a successful load opens on the library` muda de expectativa por decisão do spec (A4).
**Where**: `apps/ponto_mobile/lib/inicio_page.dart`, `lib/app.dart`, `test/inicio_page_test.dart`, `test/app_test.dart`
**Depends on**: T5
**Reuses**: `BibliotecaPage`, `BotaoPreferencias`
**Requirement**: INI-01 (parte), INI-02
**Done when**:
- [x] App abre na home; "Biblioteca" leva às obras, Favoritos e Coleções
- [x] AC-22: favorito no terceiro toque
- [x] Nenhum teste anterior perdido: `LER-01` reescrito como `INI-01`
- [x] Gate quick (app) verde
**Tests**: widget · **Gate**: quick (app)
**Commit**: `✨ feat(mobile): open the app on a home screen`

---

### T7: Continue de onde parou na home ✅

**What**: `ContinueDeOndeParou` no topo da home.
**Context**: T6 feito. Feito quando a home mostra "Continue de onde parou" + referência do último ponto
em sequência existente (dentre `janelaDeRecentes`), abre a página com origem `continuacao`, atualiza ao
voltar, some sem leitura em sequência, sem registro ou com stream em erro (log pelo tipo), sem texto de falta.
**Where**: `apps/ponto_mobile/lib/leitura/continue_de_onde_parou.dart`, `lib/inicio_page.dart`, `test/leitura/continue_de_onde_parou_test.dart`
**Depends on**: T6
**Reuses**: `pontoParaContinuar`, `observarLidosEmSequencia`, `RegistroEscopo`
**Requirement**: CONT-01..06, LEI-02 (continuacao)
**Done when**:
- [x] AC-09, AC-10, AC-11 (tela sobre banco reaberto), AC-12 (a/b), AC-13, AC-14
- [x] AC-02 para `continuacao`
- [x] Gate quick (app) verde
**Tests**: widget · **Gate**: quick (app)
**Commit**: `✨ feat(mobile): continue from the last point read in sequence`

---

### T8: Um ponto para agora na home ✅

**What**: `UmPontoParaAgora` (filtro de obra + botão) na home, com `Random` injetado.
**Context**: T7 feito. Feito quando um toque abre o ponto sorteado pelo motor com os recentes do banco
(origem `aleatorio`), o filtro oferece "Todas as obras" + obras com ponto na ordem da coleção e se
mantém ao voltar, a falta de registro ou erro na consulta não impede o sorteio, a home tem a ordem
continue → aleatório → Biblioteca sem contagem nem ausência, e cabe em 320 px com texto grande.
**Where**: `apps/ponto_mobile/lib/selecao/um_ponto_para_agora.dart`, `lib/inicio_page.dart`, `test/selecao/um_ponto_para_agora_test.dart`, `test/inicio_page_test.dart`
**Depends on**: T7
**Reuses**: `pontoAleatorio`, `janelaDeRecentes`, `listarRecentes`, `usarTelaEstreita`
**Requirement**: AGORA-01, AGORA-05, AGORA-06, INI-01, INI-03, LEI-02 (aleatorio)
**Done when**:
- [x] AC-15 e AC-19 pela tela; AC-20 (a/b); AC-02 para `aleatorio`
- [x] AC-21 (ordem + nenhuma contagem/ausência) e AC-23 (320 px, escala 2,0, "Muito grande")
- [x] Nenhum id de obra em `apps/ponto_mobile/lib` (regra 1)
- [x] Gate quick (app) verde
**Tests**: widget · **Gate**: quick (app)
**Commit**: `✨ feat(mobile): offer a point for now with an optional work filter`

---

### T9: Compartilhar a referência ✅

**What**: dependência `share_plus`; `Compartilhar` + `compartilharPeloSistema`; ícone na barra da página; falha com aviso.
**Context**: T8 feito. Feito quando o toque entrega à porta exatamente `Referencia.texto` (sem texto
do ponto, reflexão, coleção ou PontoId), a falha mostra "Não foi possível compartilhar." e loga só o
tipo, o botão anuncia "Compartilhar referência" com alvo ≥ 48 dp, e `flutter build apk --debug` gera o
APK (subindo o AGP para 8.12.x só se o build exigir).
**Where**: `apps/ponto_mobile/pubspec.yaml` (+ lock), `lib/colecao/compartilhar_referencia.dart`, `lib/colecao/ponto_page.dart`, `test/colecao/compartilhar_test.dart`, talvez `android/settings.gradle.kts`
**Depends on**: T8
**Reuses**: `Referencia.texto`
**Requirement**: COMP-01, COMP-02, COMP-03
**Done when**:
- [x] AC-24 (cada "Must not" afirmado), AC-25, AC-26; capítulo sem título compartilha a referência sem capítulo
- [x] APK de debug gerado
- [x] Gate build verde
**Tests**: widget · **Gate**: build
**Commit**: `✨ feat(mobile): share a point's reference, never its text`

---

### T10: Docs do domínio ✅

**What**: `modelo.md` §4 (origens, continue em sequência), `dominios.md` (`leitura` e `selecao` no app, regra 4 com o continue), `livros`/AGENTS sem mudança.
**Context**: T9 feito. O vocabulário mudou (A7, A9); `modelo.md` é o dono dos termos. Roadmap e
backlog só mudam depois do Verifier (reconciliação de fechamento).
**Where**: `docs/modelo.md`, `docs/dominios.md`
**Depends on**: T9
**Requirement**: — (rastreio de vocabulário)
**Done when**:
- [x] Origem da leitura com os 5 valores da v0.4 + os 2 futuros marcados
- [x] "Última leitura" do Progresso diz "em sequência" e cita a regra
- [x] `dominios.md` aponta o código real de `leitura` e `selecao`
**Tests**: none · **Gate**: build
**Commit**: `📚 docs: describe reading origins and the sequence the reader continues`

---

## Fixes da verificação (rodadas 0 → 3)

Só testes; nenhum código de produto mudou. Cada um fecha um gap do `validation.md`.

| Fix | Gap | Rodada | Commit |
| --- | --- | --- | --- |
| F1 ✅ | AC-16 na tela: o app podia pedir 1 recente em vez de 10 (M31) | 0 | `feeea96` |
| F2 ✅ | AC-24 depois de Próximo compartilhava o ponto inicial (M36) | 0 | `0bb9e9c` |
| F3 ✅ | AC-09 "abaixo" sem asserção de posição (M27) | 0 | `a01b505` |
| F4 ✅ | AC-01 `toUtc()` nunca exercido: todo relógio de teste era UTC (M14) | 0 | `44f2801` |
| F5 ✅ | edge case: continue em capítulo sem título (M44) | 0 | `cbd69f1` |
| F6 ✅ | edge case: toques rápidos sem assentar | 0 | `5ad7377` |
| F7 ✅ | AD-004: três testes sem ID de requisito | 0 | `553e766` |
| F8 ✅ | AC-18 na tela: recentes entregues do mais antigo ao mais novo (M49) | 1 | `e0b59d0` |
| F9 ✅ | edge case 5 com gravação lenta: leitura descartada em voo (M45) | 1 | `cc8a550` |
| F10 ✅ | A12: janela do continue sem teste nas duas bordas (M64, M64b, M64c) | 2 | `79b1630` |

**Test count final:** motor 64 · app 230 · validador 6.

## Task Granularity Check

| Task | Scope | Status |
| --- | --- | --- |
| T1 | enum + 1 função pura do mesmo domínio | ⚠️ OK, coeso (a função depende do enum só no teste do app) |
| T2 | 1 função | ✅ |
| T3 | fixture + tabela + migração (a fixture precisa ser capturada antes da mudança — mesma unidade) | ⚠️ OK, coeso |
| T4 | 1 repositório + 1 linha no agregado | ✅ |
| T5 | 1 comportamento (gravar ao abrir) nos 3 lugares que abrem a página | ⚠️ OK, coeso |
| T6, T7, T8, T9 | 1 tela / 1 componente cada | ✅ |
| T10 | docs | ✅ |

## Diagram-Definition Cross-Check

| Task | Depends On (body) | Diagram Shows | Status |
| --- | --- | --- | --- |
| T1 | None | início | ✅ |
| T2 | T1 | T1 → T2 | ✅ |
| T3 | T2 | T2 → T3 | ✅ |
| T4 | T3 | T3 → T4 | ✅ |
| T5 | T4 | T4 → T5 | ✅ |
| T6 | T5 | T5 → T6 | ✅ |
| T7 | T6 | T6 → T7 | ✅ |
| T8 | T7 | T7 → T8 | ✅ |
| T9 | T8 | T8 → T9 | ✅ |
| T10 | T9 | T9 → T10 | ✅ |

## Test Co-location Validation

| Task | Code Layer | Matrix Requires | Task Says | Status |
| --- | --- | --- | --- | --- |
| T1, T2 | Motor | unit | unit | ✅ |
| T3 | Banco | integration | integration | ✅ |
| T4 | Repositório | integration | integration | ✅ |
| T5, T7, T8, T9 | Telas | widget | widget | ✅ |
| T6 | Abertura do app + tela | widget | widget | ✅ |
| T10 | Docs | none | none | ✅ |

## Requirement → Task

| Req | Tasks | | Req | Tasks |
| --- | --- | --- | --- | --- |
| LEI-01 | T4, T5 | | AGORA-01 | T2, T8 |
| LEI-02 | T1, T5, T7, T8 | | AGORA-02 | T2 |
| LEI-03 | T5 | | AGORA-03 | T2, T4 |
| LEI-04 | T5 | | AGORA-04 | T2 |
| LEI-05 | T5 | | AGORA-05 | T2, T8 |
| LEI-06 | T3 | | AGORA-06 | T8 |
| LEI-07 | T3 | | INI-01 | T6, T8 |
| LEI-08 | T4, T5 | | INI-02 | T6 |
| CONT-01 | T1, T4, T7 | | INI-03 | T8 |
| CONT-02 | T7 | | COMP-01 | T9 |
| CONT-03 | T4, T7 | | COMP-02 | T9 |
| CONT-04 | T1, T7 | | COMP-03 | T9 |
| CONT-05 | T1, T7 | | | |
| CONT-06 | T7 | | | |

**Coverage:** 26 total, 26 mapped to tasks.
