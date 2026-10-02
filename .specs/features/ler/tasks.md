# Ler (v0.2) — Tasks

## Execution Protocol (MANDATORY -- do not skip)

Implement these tasks with the `spec-driven` skill: **activate it by name and follow its Execute
flow and Critical Rules.** Do not search for skill files by filesystem path. The skill is the
source of truth for the full flow (per-task cycle, sub-agent delegation, adequacy review,
Verifier, discrimination sensor).

**If the skill cannot be activated, STOP and tell the user — do not proceed without it.**

---

**Design**: `.specs/features/ler/design.md`
**Status**: Approved (delegado) · In Progress

---

## Test Coverage Matrix

> Generated from codebase, project guidelines, and spec. Guidelines found: `AGENTS.md` (Done means:
> `validar.py` exit 0, análise sem issues), `.specs/STATE.md` AD-004 (ID do requisito no nome do
> teste). Fora isso, strong defaults.

| Code Layer | Required Test Type | Coverage Expectation | Location Pattern | Run Command |
| --- | --- | --- | --- | --- |
| Motor (domínio: `colecao`, `selecao`) | unit | Todos os ramos; 1:1 com os ACs; todo edge case listado tem teste | `packages/ponto_motor/test/<dominio>/*_test.dart` | `cd packages/ponto_motor && dart test` |
| Contrato motor ↔ `livros/` | integration (arquivos reais) | Coleção real carrega e todo ponto resolve | `packages/ponto_motor/test/livros_contract_test.dart` | idem |
| Validador de dados (`validar.py`) | unit (stdlib `unittest`) | Cada invariante nova: caso que falha + caso que passa | `livros/test_*.py` | `python3 -m unittest discover -s livros -p 'test_*.py'` |
| Preferências (modelo, repositório, controller) | unit (`flutter_test`) | gravar→ler, inválido→padrão, fatores, controller persiste | `apps/ponto_mobile/test/preferencias/*_test.dart` | `cd apps/ponto_mobile && flutter test` |
| Tema (tokens) | unit | Contraste AA de cada par texto/fundo, família da fonte de leitura | `apps/ponto_mobile/test/tema_test.dart` | idem |
| Telas | widget | Cada tela: caminho feliz + cada edge case do spec + estado vazio/erro | `apps/ponto_mobile/test/<dominio>/*_test.dart` | idem |
| Abertura do app | widget | Falha → mensagem humana; sucesso → biblioteca; tema e escala aplicados | `apps/ponto_mobile/test/app_test.dart` | idem |
| Config (analysis_options, pubspec, fontes) | none | build gate | — | build gate |

## Parallelism Assessment

| Test Type | Parallel-Safe? | Isolation Model | Evidence |
| --- | --- | --- | --- |
| Motor unit | Yes | Funções puras, fixture imutável `const` | `packages/ponto_motor/test/fixtures.dart` |
| Contrato | Yes | Só leitura de `livros/` | `livros_contract_test.dart` |
| `validar.py` unit | Yes | Arquivo temporário por teste | `tempfile` por caso |
| Flutter widget/unit | Yes | `testWidgets` isola a árvore; `SharedPreferences.setMockInitialValues` por teste | padrão do pathling |

As tarefas são sequenciais na prática: várias tocam os mesmos arquivos (`colecao.dart`, telas encadeadas).

## Gate Check Commands

| Gate Level | When to Use | Command |
| --- | --- | --- |
| Quick (motor) | Tarefas só do motor | `cd packages/ponto_motor && dart analyze --fatal-infos && dart test` |
| Quick (dados) | Tarefas do validador | `python3 -m unittest discover -s livros -p 'test_*.py' && python3 livros/validar.py` |
| Quick (app) | Tarefas do app | `cd apps/ponto_mobile && flutter analyze --fatal-infos && flutter test` |
| Build | Última tarefa de cada fase; tarefas sem teste | `python3 livros/validar.py && python3 -m unittest discover -s livros -p 'test_*.py' && (cd packages/ponto_motor && dart format --output=none --set-exit-if-changed . && dart analyze --fatal-infos && dart test) && (cd apps/ponto_mobile && dart format --output=none --set-exit-if-changed lib test && flutter analyze --fatal-infos && flutter test && flutter build apk --debug)` |

**Test count antes da feature:** motor 18 · app 1 · validador 0.

---

## Execution Plan

### Phase 1: Motor e dados (Sequential)

```
T1 → T2 → T3 → T4 → T5 → T6 → T7
```

### Phase 2: Base visual e preferências (Sequential)

```
T7 → T8 → T9 → T10 → T11
```

### Phase 3: Telas e abertura (Sequential, de baixo para cima)

```
T11 → T12 → T13 → T14 → T15 → T16 → T17
```

---

## Task Breakdown

### T1: Análise estática estrita nos dois pacotes

**What**: Ligar `strict-casts`, `strict-inference`, `strict-raw-types` nos dois `analysis_options.yaml` e corrigir o que acusar.
**Context**: Base da v0.1 commitada; análise usa só os lints recomendados (achado R8). Feito quando os dois pacotes analisam com zero issues em modo estrito. Primeira tarefa porque tudo depois é escrito sob ela.
**Where**: `packages/ponto_motor/analysis_options.yaml`, `apps/ponto_mobile/analysis_options.yaml` (+ arquivos que o analisador acusar)
**Depends on**: None
**Requirement**: — (achado de revisão R8)
**Tools**: Skill `dart:dart-core-engineering`
**Done when**:
- [ ] Três modos estritos ligados nos dois pacotes
- [ ] `dart analyze --fatal-infos` e `flutter analyze --fatal-infos`: zero issues
- [ ] Build gate passa; contagem de testes inalterada (18 + 1)
**Tests**: none · **Gate**: build
**Commit**: `🔧 chore: enable strict analysis in motor and app`

### T2: validar.py recusa número repetido e capítulo inexistente

**What**: Duas invariantes novas no validador + primeiros testes `unittest` dele.
**Context**: `validar.py` checa intervalos e mock, mas aceita em silêncio ponto com número repetido e ponto cujo `capituloNumero` não existe (o range check usa `.get(..., (None, None))`). Feito quando os dois casos dão erro (exit 1) e os dados reais seguem verdes.
**Where**: `livros/validar.py`, `livros/test_validar.py` (novo)
**Depends on**: T1
**Requirement**: BASE-02, BASE-03 (metade do validador)
**Tools**: NONE
**Done when**:
- [ ] Número repetido → erro citando o número
- [ ] Capítulo inexistente → erro citando ponto e capítulo
- [ ] Caso válido sem esses erros (teste)
- [ ] `python3 livros/validar.py` segue exit 0
- [ ] Quick (dados) passa; 3 testes novos
**Tests**: unit · **Gate**: quick (dados)
**Commit**: `✨ feat(livros): reject duplicate points and unknown chapters`

### T3: Fronteira do motor recusa tipo errado, duplicado e capítulo inexistente

**What**: `lerColecao` lança `FormatException` (nunca `TypeError`) para id de obra não-texto, campo opcional de tipo errado, número repetido e capítulo inexistente.
**Context**: Achados R1–R3: `cast<String>()` e `as String?` vazam `TypeError`; `_porNumero` sobrescreve duplicado; ponto com capítulo inexistente passa. Feito quando cada caso lança `FormatException` com mensagem nomeando obra e número/campo, e a coleção real segue carregando.
**Where**: `packages/ponto_motor/lib/src/colecao/ler_colecao.dart`, `packages/ponto_motor/test/colecao/ler_colecao_test.dart`
**Depends on**: T2
**Requirement**: BASE-01, BASE-02, BASE-03 (metade do motor)
**Tools**: Skill `dart:dart-core-engineering`
**Done when**:
- [ ] id de obra não-texto em `colecao.json` → `FormatException`
- [ ] `titulo`/`slug` de capítulo não-texto → `FormatException` nomeando a obra
- [ ] número repetido → `FormatException` com obra e número
- [ ] `capituloNumero` inexistente → `FormatException` com ponto e capítulo
- [ ] Quick (motor) passa; 18 + 4 testes
**Tests**: unit · **Gate**: quick (motor)
**Commit**: `🐛 fix(motor): reject malformed collections at the boundary`

### T4: Motor dono do formato de livros/ (`carregarColecao`)

**What**: `carregarColecao(lerArquivo)` no motor; teste de contrato passa a usá-lo.
**Context**: Hoje o app (`lib/colecao/carregar_colecao.dart`) e o teste de contrato repetem "colecao.json lista as obras, cada uma em `<id>.json`" (R4). Feito quando a função existe, pede exatamente esses arquivos, propaga falha de leitura, e o contrato carrega `livros/` real por ela. O app migra na T16.
**Where**: `packages/ponto_motor/lib/src/colecao/carregar_colecao.dart` (novo), `lib/ponto_motor.dart`, `test/colecao/carregar_colecao_test.dart` (novo), `test/livros_contract_test.dart`
**Depends on**: T3
**Reuses**: `lerColecao`
**Requirement**: BASE-04
**Tools**: NONE
**Done when**:
- [ ] Pede `colecao.json` e depois `<id>.json` de cada obra listada, na ordem
- [ ] Exceção de `lerArquivo` propaga sem virar coleção parcial
- [ ] JSON que não é objeto → `FormatException`
- [ ] Contrato usa `carregarColecao`
- [ ] Quick (motor) passa; +3 testes
**Tests**: unit + integration · **Gate**: quick (motor)
**Commit**: `✨ feat(motor): own the livros file layout behind a reader port`

> **Ruling (execução):** o export de `carregarColecao` no motor colidiu com a função homônima do
> app (`ambiguous_import`). Para cada commit compilar, a migração do app para a porta (antes na
> T16) entrou aqui: `lib/colecao/carregar_colecao.dart` removido, `main.dart` e o teste de abertura
> usam o motor. Custo se errado: nenhum — T16 fica menor.

### T5: Referência com formato único no motor

**What**: `Referencia` vira classe com `texto`; o app usa `referencia.texto`.
**Context**: `modelo.md`: a referência tem um formato único (página, compartilhar, exportar). Hoje o formato vive em `ponto_page.dart:42-45` (R11). Feito quando o motor formata e a página consome.
**Where**: `packages/ponto_motor/lib/src/colecao/colecao.dart`, `test/colecao/referencia_test.dart`, `apps/ponto_mobile/lib/colecao/ponto_page.dart`
**Depends on**: T4
**Requirement**: LER-06
**Tools**: NONE
**Done when**:
- [ ] Com título: `"Caminho, capítulo Caráter, ponto 1"`
- [ ] Sem título: `"Caminho, ponto 387"`
- [ ] `ponto_page.dart` sem formatação própria; teste do app segue verde
- [ ] Quick (motor) + Quick (app) passam; +2 testes motor
**Tests**: unit · **Gate**: quick (motor) + quick (app)
**Commit**: `♻️ refactor(motor): make the reference format a domain rule`

### T6: Índice do capítulo — intervalo, contagem e pontos

**What**: `Capitulo.pontoInicial/pontoFinal/totalPontos` e `Obra.pontosDoCapitulo(n)`; buscas lineares viram `firstOrNull` (R7).
**Context**: A tela da obra precisa da contagem editorial (A4) e a do capítulo, dos pontos disponíveis em ordem. Feito quando a contagem bate com o intervalo, é nula com intervalo incompleto, e `pontosDoCapitulo` devolve só os pontos daquele capítulo em `ordem`.
**Where**: `packages/ponto_motor/lib/src/colecao/colecao.dart`, `lib/src/colecao/ler_colecao.dart`, `test/colecao/indice_test.dart` (novo), `test/fixtures.dart`
**Depends on**: T5
**Requirement**: LER-02 (contagem), LER-03 (motor)
**Tools**: NONE
**Done when**:
- [ ] Intervalo 1–55 → `totalPontos == 55`
- [ ] Intervalo sem fim ou sem início → `totalPontos == null`
- [ ] `pontosDoCapitulo` só do capítulo pedido, em `ordem`; capítulo sem pontos → lista vazia
- [ ] Intervalo de tipo errado → `FormatException`
- [ ] Quick (motor) passa; +4 testes
**Tests**: unit · **Gate**: quick (motor)
**Commit**: `✨ feat(motor): expose chapter ranges and points per chapter`

### T7: Sequência — próximo e anterior

**What**: `proximoPonto` e `pontoAnterior` em `selecao/sequencia.dart`.
**Context**: A página do ponto precisa andar pela obra em `ordem`, atravessando capítulos, só por pontos disponíveis (A2, A3). Feito quando a fixture com buraco entre capítulos, pontas e id desconhecido se comporta como o spec.
**Where**: `packages/ponto_motor/lib/src/selecao/sequencia.dart` (novo), `lib/ponto_motor.dart`, `test/selecao/sequencia_test.dart` (novo), `test/fixtures.dart`
**Depends on**: T6
**Requirement**: LER-07, LER-08, LER-09 (motor)
**Tools**: NONE
**Done when**:
- [ ] Último do capítulo → primeiro disponível do capítulo seguinte com pontos (atravessa buraco)
- [ ] Anterior é o espelho
- [ ] Primeiro da obra → anterior nulo; último da obra → próximo nulo (não atravessa obras)
- [ ] Id desconhecido → nulo nos dois
- [ ] Build gate passa (fim da fase 1); +5 testes
**Tests**: unit · **Gate**: build
**Commit**: `✨ feat(motor): step to the next and previous point`

### T8: Tema provisório com Literata e contraste AA

**What**: `lib/tema.dart` (tokens + `temaClaro`/`temaEscuro`), fonte Literata empacotada (OFL) no pubspec.
**Context**: A11 + AC-19/20. Cores do roadmap: azul-noite, marfim, terracota, âmbar. Feito quando os dois temas existem, o texto de leitura usa "Literata" e todo par texto/fundo passa 4,5:1.
**Where**: `apps/ponto_mobile/lib/tema.dart` (novo), `assets/fonts/` (TTF + OFL.txt), `pubspec.yaml`, `test/tema_test.dart` (novo)
**Depends on**: T7
**Requirement**: TIPO-01, TIPO-02
**Tools**: NONE
**Done when**:
- [ ] Contraste ≥ 4,5:1 de texto principal e secundário sobre o fundo, nos dois temas
- [ ] Estilo de leitura (`bodyLarge`) e títulos com `fontFamily == 'Literata'`
- [ ] Fonte declarada no pubspec; licença OFL junto
- [ ] Quick (app) passa; +3 testes
**Tests**: unit · **Gate**: quick (app)
**Commit**: `✨ feat(mobile): add the provisional reading theme`

### T9: Preferências — modelo e repositório

**What**: `Tema`, `TamanhoTexto`, `Preferencias` e `PreferenciasRepositorio` sobre `shared_preferences`.
**Context**: AC-16 (fatores), AC-17, AC-18; AD-005. Feito quando gravar→ler devolve o mesmo valor e qualquer valor ausente/inválido vira o padrão sem lançar.
**Where**: `apps/ponto_mobile/lib/preferencias/preferencias.dart`, `lib/preferencias/preferencias_repositorio.dart` (novos), `pubspec.yaml`, `test/preferencias/preferencias_repositorio_test.dart` (novo)
**Depends on**: T8
**Reuses**: padrão defensivo do `shared_prefs_progress_store.dart` (pathling)
**Requirement**: PREF-02 (fatores), PREF-03, PREF-04
**Tools**: NONE
**Done when**:
- [ ] Fatores 0,9 / 1,0 / 1,15 / 1,3; padrão Sistema + Médio
- [ ] Gravar Escuro + Grande → ler devolve Escuro + Grande
- [ ] Valor desconhecido ou ausente em cada chave → padrão daquele campo
- [ ] Quick (app) passa; +4 testes
**Tests**: unit · **Gate**: quick (app)
**Commit**: `✨ feat(mobile): store reading preferences locally`

### T10: Preferências — controller e escopo

**What**: `PreferenciasController` (`ValueNotifier`) e `PreferenciasEscopo` (`InheritedNotifier`).
**Context**: AD-002. Feito quando mudar tema/tamanho troca o valor na hora e grava no repositório, e um widget abaixo do escopo reconstrói ao mudar.
**Where**: `apps/ponto_mobile/lib/preferencias/preferencias_controller.dart` (novo), `test/preferencias/preferencias_controller_test.dart` (novo)
**Depends on**: T9
**Requirement**: PREF-03 (controller grava)
**Tools**: NONE
**Done when**:
- [ ] `mudarTema(escuro)` → `value.tema == escuro` e repositório devolve escuro
- [ ] `mudarTamanho(grande)` idem
- [ ] Widget sob o escopo reconstrói com o novo valor
- [ ] Quick (app) passa; +3 testes
**Tests**: unit/widget · **Gate**: quick (app)
**Commit**: `✨ feat(mobile): share reading preferences across the app`

### T11: Tela de preferências de leitura

**What**: `PreferenciasPage` com escolha de tema (Sistema/Claro/Escuro) e tamanho (4 passos).
**Context**: AC-15/16 do lado da escolha. Feito quando tocar numa opção muda o controller e a opção aparece selecionada; controles com rótulo acessível.
**Where**: `apps/ponto_mobile/lib/preferencias/preferencias_page.dart` (novo), `test/preferencias/preferencias_page_test.dart` (novo), `test/montar_tela.dart` (helper novo)
**Depends on**: T10
**Requirement**: PREF-01 (escolha), PREF-02 (escolha)
**Tools**: NONE
**Done when**:
- [ ] Tocar "Escuro" → controller com escuro, opção selecionada
- [ ] Tocar "Grande" → controller com grande
- [ ] UX DoD: rótulos de texto (não só ícone); alvo ≥ 48 px (padrão Material); funciona em 320 px sem rolagem horizontal
- [ ] Build gate passa (fim da fase 2); +2 testes
**Tests**: widget · **Gate**: build
**Commit**: `✨ feat(mobile): let the reader choose theme and text size`

### T12: Página do ponto com anterior/próximo

**What**: `PontoPage` troca o ponto no lugar via motor; botões só quando há destino; texto em Literata; botão de preferências.
**Context**: AC-12..14, AC-19. A v0.1 mostra um ponto fixo. Feito quando, numa coleção de teste, próximo atravessa capítulos, as pontas escondem o botão, a rolagem volta ao topo e o texto usa o estilo de leitura.
**Where**: `apps/ponto_mobile/lib/colecao/ponto_page.dart`, `test/colecao/ponto_page_test.dart` (substitui o teste de abertura da v0.1, que migra para `app_test.dart` na T16), `test/colecao_de_teste.dart` (novo)
**Depends on**: T11
**Requirement**: LER-07, LER-08, LER-09 (tela), TIPO-01 (uso)
**Tools**: NONE
**Done when**:
- [ ] Próximo no último ponto do cap. 1 → abre o primeiro disponível do cap. seguinte; referência atualiza
- [ ] Anterior volta
- [ ] Primeiro da obra: sem "Anterior"; último: sem "Próximo"
- [ ] Texto do ponto com família "Literata"
- [ ] UX DoD: botões com rótulo de texto; referência como cabeçalho semântico; página rola com texto grande
- [ ] Quick (app) passa
**Tests**: widget · **Gate**: quick (app)
**Commit**: `✨ feat(mobile): read on with previous and next`

### T13: Tela do capítulo

**What**: `CapituloPage`: pontos disponíveis com número e prévia; estado vazio; toque abre o ponto.
**Context**: AC-08..10. Feito quando a lista bate com o capítulo, o vazio mostra a frase de A5 e o toque abre a página certa.
**Where**: `apps/ponto_mobile/lib/colecao/capitulo_page.dart` (novo), `test/colecao/capitulo_page_test.dart` (novo)
**Depends on**: T12
**Requirement**: LER-03, LER-04, LER-05
**Tools**: NONE
**Done when**:
- [ ] Itens = pontos do capítulo em ordem, com número e prévia (máx. 2 linhas)
- [ ] Capítulo sem pontos → "Os pontos deste capítulo ainda não estão disponíveis."
- [ ] Toque no ponto N → `PontoPage` com a referência de N
- [ ] Quick (app) passa; +3 testes
**Tests**: widget · **Gate**: quick (app)
**Commit**: `✨ feat(mobile): list the points of a chapter`

### T14: Tela da obra

**What**: `ObraPage`: capítulos com número, título (ou "Capítulo N") e "M pontos" quando houver contagem.
**Context**: AC-07. Feito quando a lista mostra todos os capítulos em ordem, inclusive os sem pontos.
**Where**: `apps/ponto_mobile/lib/colecao/obra_page.dart` (novo), `test/colecao/obra_page_test.dart` (novo)
**Depends on**: T13
**Requirement**: LER-02
**Tools**: NONE
**Done when**:
- [ ] Capítulo com título e intervalo → "Caráter" e "55 pontos" (na fixture equivalente)
- [ ] Sem título → "Capítulo N"; sem intervalo completo → sem contagem
- [ ] Capítulo sem pontos disponíveis aparece
- [ ] Toque → `CapituloPage` daquele capítulo
- [ ] Quick (app) passa; +3 testes
**Tests**: widget · **Gate**: quick (app)
**Commit**: `✨ feat(mobile): show a work's chapters`

### T15: Biblioteca

**What**: `BibliotecaPage`: obras na ordem da coleção; toque abre a obra; botão de preferências.
**Context**: AC-06. Feito quando a ordem é a da coleção e o toque abre a obra certa.
**Where**: `apps/ponto_mobile/lib/colecao/biblioteca_page.dart` (novo), `test/colecao/biblioteca_page_test.dart` (novo)
**Depends on**: T14
**Requirement**: LER-01
**Tools**: NONE
**Done when**:
- [ ] Obras na ordem da coleção (fixture com ordem não alfabética)
- [ ] Toque → `ObraPage` da obra
- [ ] Botão de preferências com rótulo acessível abre `PreferenciasPage`
- [ ] Quick (app) passa; +3 testes
**Tests**: widget · **Gate**: quick (app)
**Commit**: `✨ feat(mobile): open on the library`

### T16: Abertura do app

**What**: `app.dart` (`abrirApp`, `PontoApp`, `_FalhaAoAbrir`) e `main.dart` ligando dependências reais; app passa a carregar pelo motor; `lib/colecao/carregar_colecao.dart` sai.
**Context**: AC-05, AC-15/16 aplicados, BASE-04 lado do app, achados R5/R6/R10. Feito quando falha vira mensagem humana sem texto da exceção, sucesso abre a biblioteca, tema e escala seguem as preferências, e um teste abre com `livros/` real.
**Where**: `apps/ponto_mobile/lib/app.dart` (novo), `lib/main.dart`, `lib/colecao/carregar_colecao.dart` (removido), `test/app_test.dart` (novo; absorve o teste de abertura da v0.1)
**Depends on**: T15
**Requirement**: BASE-04 (app), BASE-05, PREF-01 (aplicado), PREF-02 (aplicado)
**Tools**: NONE
**Done when**:
- [ ] Carregador que lança → "Não foi possível abrir os livros. Feche o app e abra de novo."; texto da exceção ausente
- [ ] Sucesso → biblioteca
- [ ] Escuro escolhido → `Theme.of(context).brightness == dark`; Sistema segue o brilho do aparelho
- [ ] Escala do sistema 1,5 × Grande → escala efetiva 1,725
- [ ] Abertura com `livros/` real pelo `rootBundle` mostra "Caminho", "Sulco", "Forja"
- [x] App não lê mais `colecao.json` por conta própria *(antecipado na T4)*
- [ ] Quick (app) passa
**Tests**: widget · **Gate**: quick (app)
**Commit**: `✨ feat(mobile): open through the motor with a humane failure screen`

### T17: Remover `primeiroPonto`

**What**: Apagar `primeiroPonto` e seu teste — ficou sem uso com A1.
**Context**: Achado R9. Depois da T16 nada chama `primeiroPonto`. Remover comportamento morto remove o teste dele (não é enfraquecer teste: o comportamento deixa de existir). Feito quando a busca não acha mais o nome e o build gate passa.
**Where**: `packages/ponto_motor/lib/src/selecao/obter_ponto.dart`, `test/selecao/obter_ponto_test.dart`
**Depends on**: T16
**Requirement**: — (R9)
**Tools**: NONE
**Done when**:
- [ ] `grep -r primeiroPonto` vazio em `packages/` e `apps/`
- [ ] Build gate passa (fim da feature); contagem de testes = antes − 1 (o teste removido) + novos
**Tests**: unit (existentes) · **Gate**: build
**Commit**: `♻️ refactor(motor): drop the unused first-point helper`

---

## Parallel Execution Map

```
Phase 1 (Sequential): T1 → T2 → T3 → T4 → T5 → T6 → T7
Phase 2 (Sequential): T8 → T9 → T10 → T11
Phase 3 (Sequential): T12 → T13 → T14 → T15 → T16 → T17
```

Nada `[P]`: as tarefas compartilham arquivos (`colecao.dart`, fixtures, telas encadeadas).

---

## Task Granularity Check

| Task | Scope | Status |
| --- | --- | --- |
| T1 | config em 2 arquivos (+ correções) | ⚠️ OK — mesma mudança nos dois pacotes |
| T2 | 1 função + 1 arquivo de teste | ✅ |
| T3 | 1 função (fronteira) | ✅ |
| T4 | 1 função nova | ✅ |
| T5 | 1 classe + 1 consumidor | ⚠️ OK — consumidor quebraria sem ela |
| T6 | 2 membros do mesmo modelo + leitura dos campos | ⚠️ OK — coeso (índice do capítulo) |
| T7 | 2 funções espelho, 1 arquivo | ✅ |
| T8 | 1 arquivo + fonte | ✅ |
| T9 | modelo + repositório | ⚠️ OK — repositório é o único consumidor do modelo nesta tarefa |
| T10 | 1 arquivo | ✅ |
| T11 | 1 tela | ✅ |
| T12 | 1 tela | ✅ |
| T13 | 1 tela | ✅ |
| T14 | 1 tela | ✅ |
| T15 | 1 tela | ✅ |
| T16 | abertura (1 arquivo novo + main) | ✅ |
| T17 | remoção de 1 função | ✅ |

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
| T11 | T10 | T10 → T11 | ✅ |
| T12 | T11 | T11 → T12 | ✅ |
| T13 | T12 | T12 → T13 | ✅ |
| T14 | T13 | T13 → T14 | ✅ |
| T15 | T14 | T14 → T15 | ✅ |
| T16 | T15 | T15 → T16 | ✅ |
| T17 | T16 | T16 → T17 | ✅ |

## Test Co-location Validation

| Task | Code Layer | Matrix Requires | Task Says | Status |
| --- | --- | --- | --- | --- |
| T1 | config | none | none | ✅ |
| T2 | validador | unit | unit | ✅ |
| T3 | motor | unit | unit | ✅ |
| T4 | motor + contrato | unit + integration | unit + integration | ✅ |
| T5 | motor (+ tela consumidora) | unit (+ widget existente) | unit | ✅ — teste de widget existente continua no gate |
| T6 | motor | unit | unit | ✅ |
| T7 | motor | unit | unit | ✅ |
| T8 | tema | unit | unit | ✅ |
| T9 | preferências | unit | unit | ✅ |
| T10 | preferências | unit | unit/widget | ✅ |
| T11 | tela | widget | widget | ✅ |
| T12 | tela | widget | widget | ✅ |
| T13 | tela | widget | widget | ✅ |
| T14 | tela | widget | widget | ✅ |
| T15 | tela | widget | widget | ✅ |
| T16 | abertura | widget | widget | ✅ |
| T17 | motor (remoção) | unit | unit (existentes) | ✅ |

**Tools:** MCP `context7` só se uma API do Flutter surpreender; skill `dart:dart-core-engineering`
como referência de estilo. Nenhum outro MCP necessário.

## Requirement → Task

| Requirement | Tasks |
| --- | --- |
| BASE-01 | T3 |
| BASE-02 | T2, T3 |
| BASE-03 | T2, T3 |
| BASE-04 | T4, T16 |
| BASE-05 | T16 |
| LER-01 | T15 |
| LER-02 | T6, T14 |
| LER-03 | T6, T13 |
| LER-04 | T13 |
| LER-05 | T13 |
| LER-06 | T5 |
| LER-07..09 | T7, T12 |
| PREF-01 | T11, T16 |
| PREF-02 | T9, T11, T16 |
| PREF-03 | T9, T10 |
| PREF-04 | T9 |
| TIPO-01 | T8, T12 |
| TIPO-02 | T8 |

**Coverage:** 20 requisitos, 20 mapeados, 0 sem tarefa.
