# Guardar (v0.3) — Tasks

## Execution Protocol (MANDATORY -- do not skip)

Implement these tasks with the `spec-driven` skill: **activate it by name and follow its Execute
flow and Critical Rules.** Do not search for skill files by filesystem path. The skill is the
source of truth for the full flow (per-task cycle, sub-agent delegation, adequacy review,
Verifier, discrimination sensor).

**If the skill cannot be activated, STOP and tell the user — do not proceed without it.**

---

**Design**: `.specs/features/guardar/design.md`
**Status**: Execute concluído — T1–T21 (execução inline, sem workers por fase: o usuário pediu o
fluxo completo sem pausas; nenhum sub-agente além do Verifier). Verificação: `validation.md`

---

## Test Coverage Matrix

> Generated from codebase, project guidelines, and spec. Guidelines found: `AGENTS.md` (Done means:
> `validar.py` exit 0, análise sem issues, docs reconciliados), `.specs/STATE.md` AD-004 (ID do
> requisito no início do nome do teste). Fora isso, strong defaults. Tag de rastreio = o próprio
> prefixo `CIFRA-0N:`/`REF-0N:`… (AD-004 substitui a tag `@spec`).

| Code Layer | Required Test Type | Coverage Expectation | Location Pattern | Run Command |
| --- | --- | --- | --- | --- |
| Motor `registro/` (regras puras) | unit | Todos os ramos; 1:1 com os ACs; todo edge case listado | `packages/ponto_motor/test/registro/*_test.dart` | `cd packages/ponto_motor && dart test` |
| Repositórios do registro (drift) | integration (SQLite real em memória) | Cada operação: efeito no banco + ordem + idempotência + transação + cascata | `apps/ponto_mobile/test/registro/*_repositorio_test.dart` | `cd apps/ponto_mobile && flutter test` |
| Infra (cifra, chave, abertura) | integration (arquivo real em diretório temporário + cofre falso) | Cada AC CIFRA: caminho feliz + cada falha listada (L-001: mais de um tipo de falha) | `apps/ponto_mobile/test/infra/*_test.dart`, `test/registro/abrir_registro_test.dart` | idem |
| Formatação de data | unit | Cada exemplo da AC-12 | `apps/ponto_mobile/test/registro/data_da_reflexao_test.dart` | idem |
| Telas do registro | widget (banco em memória) | Cada tela: caminho feliz + cada edge case + vazio/erro/indisponível; todas as partes do Expected (L-003) | `apps/ponto_mobile/test/registro/*_test.dart` | idem |
| Abertura do app | widget | Registro indisponível não impede a leitura | `apps/ponto_mobile/test/app_test.dart` | idem |
| Manifesto Android | unit (leitura do XML) | `allowBackup=false` + regras excluem nuvem e transferência | `apps/ponto_mobile/test/infra/backup_test.dart` | idem |
| Config (pubspec, build.yaml, analysis_options, `.g.dart`) | none | build gate | — | build gate |

## Parallelism Assessment

| Test Type | Parallel-Safe? | Isolation Model | Evidence |
| --- | --- | --- | --- |
| Motor unit | Yes | Funções puras | `packages/ponto_motor/test/` |
| Repositórios / telas | Yes | Um `NativeDatabase.memory()` novo por teste, fechado no `tearDown` | padrão desta feature |
| Infra | Yes | Diretório temporário por teste (`Directory.systemTemp.createTemp`) | spike de cifra |

As tarefas são sequenciais na prática: quase todas tocam `pubspec`, `ponto_page.dart` ou o mesmo
banco. Nenhuma marcada `[P]`.

## Gate Check Commands

| Gate Level | When to Use | Command |
| --- | --- | --- |
| Quick (motor) | Tarefas só do motor | `cd packages/ponto_motor && dart format --output=none --set-exit-if-changed . && dart analyze --fatal-infos && dart test` |
| Quick (app) | Tarefas do app | `cd apps/ponto_mobile && dart format --output=none --set-exit-if-changed lib test && flutter analyze --fatal-infos && flutter test` |
| Build | Última tarefa de cada fase; tarefas sem teste | `python3 livros/validar.py && python3 -m unittest discover -s livros -p 'test_*.py' && (cd packages/ponto_motor && dart format --output=none --set-exit-if-changed . && dart analyze --fatal-infos && dart test) && (cd apps/ponto_mobile && dart format --output=none --set-exit-if-changed lib test && flutter analyze --fatal-infos && flutter test && flutter build apk --debug)` |

**Test count antes da feature:** motor 38 · app 46 · validador 6. **Depois:** motor 51 · app 164 · validador 6.

---

## Execution Plan

### Phase 1: Motor (Sequential)
```
T1 → T2
```

### Phase 2: Banco, cifra e chave (Sequential)
```
T2 → T3 → T4 → T5 → T6 → T7 → T8 → T9
```

### Phase 3: Abertura e reflexão (Sequential)
```
T9 → T10 → T11 → T12 → T13 → T14
```

### Phase 4: Favoritos e coleções (Sequential)
```
T14 → T15 → T16 → T17 → T18 → T19 → T20
```

### Phase 5: Consolidação (Sequential)
```
T20 → T21 → Verifier
```

---

## Task Breakdown

### T1: Tipo `Reflexao` e regra do texto ✅

**What**: `packages/ponto_motor/lib/src/registro/reflexao.dart` com `Reflexao` e `limparTextoDeReflexao`; exportados no barrel.
**Context**: Motor da v0.2 sem pasta `registro/`. Feito quando o tipo existe e a regra do texto (pontas removidas; vazio/só espaços → nulo) tem teste. Primeiro porque repositório e editor dependem dela.
**Where**: `packages/ponto_motor/lib/src/registro/reflexao.dart`, `lib/ponto_motor.dart`, `test/registro/reflexao_test.dart`
**Depends on**: None
**Reuses**: `PontoId`
**Requirement**: REF-02
**Done when**:
- [ ] `'REF-02: …'` testes: "" → nulo; "  \n\t " → nulo; "  Quero ser útil.\n" → "Quero ser útil."; texto interno (quebras no meio) preservado
- [ ] Gate quick (motor) verde; motor ≥ 38 + novos
**Tests**: unit · **Gate**: quick (motor)
**Commit**: `✨ feat(motor): add the reflection type and its text rule`

---

### T2: Tipo `ColecaoPessoal` e regra do nome ✅

**What**: `packages/ponto_motor/lib/src/registro/colecao_pessoal.dart` com `ColecaoPessoal`, `limiteDoNomeDeColecao`, `NomeDeColecao` (sealed) e `validarNomeDeColecao`.
**Context**: T1 feito. Feito quando a regra do nome da AC-18 / A12 está no motor, com teste de cada resultado (aceito, vazio, repetido ignorando caixa, longo, renomear para o próprio nome) e `contem`. Última do motor: fecha a fase com build gate.
**Where**: `packages/ponto_motor/lib/src/registro/colecao_pessoal.dart`, `lib/ponto_motor.dart`, `test/registro/colecao_pessoal_test.dart`
**Depends on**: T1
**Requirement**: COL-03, PAG-01 (contem)
**Done when**:
- [ ] `'COL-03: …'`: "  Trabalho " → `NomeAceito('Trabalho')`; "" e "   " → `NomeVazio`; "  família " com "Família" existente → `NomeRepetido`; 61 caracteres → `NomeLongo`; 60 → aceito; renomear "Família" → "família" na própria coleção → aceito
- [ ] `contem(PontoId)` verdadeiro/falso
- [ ] Gate build verde
**Tests**: unit · **Gate**: build
**Commit**: `✨ feat(motor): add personal collections and their name rule`

---

### T3: Banco do registro (drift) + repositório de reflexões ✅

**What**: dependências (drift, sqlite3, uuid, drift_dev, build_runner), `build.yaml`, exclusão de `*.g.dart` no analyzer, `BancoRegistro` com as 5 tabelas, `ReflexoesRepositorio`.
**Context**: Motor com `registro/`. App sem banco. Feito quando o schema v1 gera (`dart run build_runner build`), o `.g.dart` está versionado e o repositório de reflexões tem teste sobre SQLite em memória (sem cifra ainda — a cifra entra na T6 sem mudar o repositório).
**Where**: `apps/ponto_mobile/pubspec.yaml`, `build.yaml`, `analysis_options.yaml`, `lib/registro/banco_registro.dart` (+ `.g.dart`), `lib/registro/reflexoes_repositorio.dart`, `test/registro/reflexoes_repositorio_test.dart`, `test/registro/banco_de_teste.dart`
**Depends on**: T2
**Requirement**: REF-01, REF-02, REF-04, REF-05, REF-06 (camada de dados)
**Done when**:
- [ ] `escrever` grava texto limpo, `criadaEm` = relógio (UTC), `editadaEm` nulo; vazio → `ArgumentError` e nada gravado
- [ ] `editar`: texto novo + `editadaEm`; mesmo texto → nada muda; `criadaEm` intacta
- [ ] `excluir` apaga só aquela
- [ ] `observar(ponto)`: só as do ponto, mais antiga primeiro; empate de momento → ordem de inserção; emite de novo após escrita
- [ ] Gate quick (app) verde
- *(Desvio: "linha com `pontoId` inválido ignorada" saiu daqui — reflexões são consultadas pelo
  próprio `PontoId`, então a linha lida é válida por construção. Fica em T4 e T5.)*
**Tests**: integration · **Gate**: quick (app)
**Commit**: `✨ feat(mobile): store reflections in a local database`

---

### T4: Repositório de favoritos ✅

**What**: `lib/registro/favoritos_repositorio.dart`.
**Context**: Banco da T3 existe. Feito quando favoritar/desfavoritar/observar têm teste: idempotência, ordem mais recente primeiro.
**Where**: `apps/ponto_mobile/lib/registro/favoritos_repositorio.dart`, `test/registro/favoritos_repositorio_test.dart`
**Depends on**: T3
**Requirement**: FAV-01, FAV-02 (camada de dados)
**Done when**:
- [ ] favoritar duas vezes → um favorito; desfavoritar remove; `observar` mais recente primeiro
- [ ] Gate quick (app) verde
**Tests**: integration · **Gate**: quick (app)
**Commit**: `✨ feat(mobile): store favourite points`

---

### T5: Repositório de coleções + sugestões ✅

**What**: `lib/registro/colecoes_repositorio.dart` e o agregado `Registro` (`lib/registro/registro.dart`).
**Context**: T3–T4 feitos. Feito quando criar (com ponto, em transação), renomear, excluir (cascata só nos vínculos), guardar/tirar e sugestões (respondidas, criar escolhidas na ordem dada) têm teste; nome inválido lança `NomeDeColecaoInvalido`.
**Where**: `apps/ponto_mobile/lib/registro/colecoes_repositorio.dart`, `lib/registro/registro.dart`, `test/registro/colecoes_repositorio_test.dart`
**Depends on**: T4
**Requirement**: COL-01, COL-02, COL-03, COL-04, COL-05, COL-06, COL-07, SUG-02, SUG-03 (camada de dados)
**Done when**:
- [ ] `criar('Família', comPonto: X)` → coleção com X; nome repetido → lança e **nada** criado (nem a coleção, nem o vínculo)
- [ ] guardar duas vezes → um vínculo; tirar afeta só aquela coleção
- [ ] `observar`: coleções em ordem de criação; pontos mais recente primeiro
- [ ] `renomear` com regras; `excluir` remove coleção e vínculos, favoritos/reflexões/outras coleções intactos
- [ ] `sugestoesRespondidas` falso → `responderSugestoes([...])` cria na ordem dada e marca; `responderSugestoes([])` só marca
- [ ] Gate quick (app) verde
**Tests**: integration · **Gate**: quick (app)
**Commit**: `✨ feat(mobile): store personal collections and the suggestions answer`

---

### T6: Banco cifrado (sqlite3mc) ✅

**What**: hook `sqlite3mc` no pubspec; `lib/infra/banco_cifrado.dart` com `abrirBancoCifrado` e `prepararCifra`.
**Context**: Repositórios testados em memória. Feito quando um `BancoRegistro` sobre arquivo cifrado grava uma reflexão e os bytes não têm o texto nem o cabeçalho; `prepararCifra` recusa SQLite sem cifra e chave fora do formato.
**Where**: `apps/ponto_mobile/pubspec.yaml`, `lib/infra/banco_cifrado.dart`, `test/infra/banco_cifrado_test.dart`
**Depends on**: T5
**Requirement**: CIFRA-01, CIFRA-02
**Done when**:
- [ ] `'CIFRA-01: …'` bytes sem "silêncio-que-ninguém-lê" nem "SQLite format 3"; `PRAGMA cipher` não vazio
- [ ] `'CIFRA-02: …'` SQLite sem cifra (fake de `Database`) → `StateError`; chave não-hex → `ArgumentError`, antes de qualquer `PRAGMA key`
- [ ] Chave errada não lê o banco
- [ ] Gate quick (app) verde
**Tests**: integration · **Gate**: quick (app)
**Commit**: `✨ feat(mobile): open the registro database encrypted with sqlite3mc`

---

### T7: Guarda da chave ✅

**What**: `lib/infra/guarda_da_chave.dart` com `CofreDeChaves`, `CofreDoSistema` (`flutter_secure_storage`), `obterChave`, `ChaveIndisponivel`.
**Context**: Banco cifrado existe mas a chave vem de fora. Feito quando as três situações da AC-03/AC-04 têm teste com cofre falso.
**Where**: `apps/ponto_mobile/pubspec.yaml`, `lib/infra/guarda_da_chave.dart`, `test/infra/guarda_da_chave_test.dart`
**Depends on**: T6
**Requirement**: CIFRA-03, CIFRA-04
**Done when**:
- [ ] cofre vazio + sem banco → gera 64 hex, grava **antes** de devolver, devolve a gravada
- [ ] cofre com chave → devolve a mesma, não grava
- [ ] cofre vazio + banco existe → `ChaveIndisponivel`, nada gravado
- [ ] cofre que lança ao ler → o erro propaga, nada gravado
- [ ] Gate quick (app) verde
**Tests**: integration · **Gate**: quick (app)
**Commit**: `✨ feat(mobile): keep the registro key in the system keystore`

---

### T8: Abrir o registro + falha sem conteúdo ✅

**What**: `lib/registro/abrir_registro.dart` (`abrirRegistro`) e `lib/registro/falha_no_registro.dart` (`relatarFalhaNoRegistro`, `FalhaNoRegistro`).
**Context**: Chave e cifra prontas. Feito quando abrir num diretório temporário cria chave → banco cifrado, reabre lendo os dados, e qualquer falha devolve `null` sem tocar o arquivo e loga só o tipo.
**Where**: `apps/ponto_mobile/lib/registro/abrir_registro.dart`, `lib/registro/falha_no_registro.dart`, `test/registro/abrir_registro_test.dart`
**Depends on**: T7
**Requirement**: CIFRA-01, CIFRA-03, CIFRA-04
**Done when**:
- [ ] primeira abertura grava a chave antes de o arquivo existir (cofre falso registra se `registro.db` existia no `gravar`)
- [ ] fechar e reabrir com o mesmo cofre lê a reflexão; o cofre recebeu um único `gravar`
- [ ] banco existe + cofre vazio → `null`; bytes e data de modificação do arquivo iguais; nenhum `gravar`
- [ ] banco existe + cofre que lança → `null`, arquivo igual
- [ ] chave errada → `null`, arquivo igual
- [ ] log da falha contém o tipo do erro e não contém a mensagem original
- [ ] Gate quick (app) verde
**Tests**: integration · **Gate**: quick (app)
**Commit**: `✨ feat(mobile): open the registro or fail without touching it`

---

### T9: Backup desligado no Android ✅

**What**: `android:allowBackup="false"` + `android:dataExtractionRules="@xml/regras_de_extracao"` excluindo todos os domínios em `cloud-backup` e `device-transfer`.
**Context**: Registro abre cifrado. Feito quando o manifesto tem as duas regras, um teste lê os XMLs e o APK debug gera com o hook do sqlite3mc. Última da fase: build gate (inclui `flutter build apk --debug`).
**Where**: `apps/ponto_mobile/android/app/src/main/AndroidManifest.xml`, `android/app/src/main/res/xml/regras_de_extracao.xml`, `test/infra/backup_test.dart`
**Depends on**: T8
**Requirement**: CIFRA-05
**Done when**:
- [ ] `'CIFRA-05: …'` manifesto com `allowBackup="false"` e `dataExtractionRules` apontando para o XML; XML exclui `root`, `file`, `database`, `sharedpref`, `external` nas duas modalidades
- [ ] Gate build verde (APK debug gerado)
**Tests**: unit · **Gate**: build
**Commit**: `🔒 feat(mobile): keep the registro out of Android backups`

---

### T10: Registro na abertura do app + escopo + aviso ✅

**What**: `RegistroEscopo` + `AvisoRegistroIndisponivel`; `abrirApp(abrirRegistro:)`; `main.dart` liga pasta + `CofreDoSistema`; `montarTela(registro:)`.
**Context**: `abrirRegistro` existe. Feito quando o app abre com o registro (ou sem ele) e a leitura funciona nos dois casos; telas acham o `Registro` no escopo.
**Where**: `apps/ponto_mobile/lib/registro/registro_escopo.dart`, `lib/app.dart`, `lib/main.dart`, `pubspec.yaml` (path_provider), `test/montar_tela.dart`, `test/app_test.dart`, `test/registro/banco_de_teste.dart`
**Depends on**: T9
**Requirement**: CIFRA-04
**Done when**:
- [ ] `'CIFRA-04: …'` `abrirApp` com `abrirRegistro` devolvendo `null` → biblioteca abre e um ponto é lido
- [ ] testes da v0.2 continuam verdes sem mudança de asserção
- [ ] Gate quick (app) verde
**Tests**: widget · **Gate**: quick (app)
**Commit**: `✨ feat(mobile): open the registro with the app`

---

### T11: Data e hora da reflexão ✅

**What**: `lib/registro/data_da_reflexao.dart` com `dataEHora(DateTime)` e `escritoEm(Reflexao)`.
**Context**: Independente das telas; o editor e a página usam. Feito quando os exemplos da AC-12 e da AC-09 passam.
**Where**: `apps/ponto_mobile/lib/registro/data_da_reflexao.dart`, `test/registro/data_da_reflexao_test.dart`
**Depends on**: T10
**Requirement**: REF-07
**Done when**:
- [ ] `'REF-07: …'` 06:40 → "6h40"; 06:00 → "6h"; 21:05 → "21h05"; 00:00 → "0h"; "12 de março de 2026"; os 12 meses
- [ ] momento em UTC mostrado no fuso local (`toLocal`)
- [ ] `escritoEm` sem edição: "Escrito em 12 de março de 2026, 6h40." · com: "Escrito em 12 de março de 2026, 6h40 · editado em 14 de março de 2026, 21h05."
- [ ] Gate quick (app) verde
**Tests**: unit · **Gate**: quick (app)
**Commit**: `✨ feat(mobile): write reflection dates the way the product speaks`

---

### T12: Escrever uma reflexão a partir do ponto ✅

**What**: `RegistroDoPonto` (ação "Escrever uma reflexão" + lista de reflexões) embutido na `PontoPage`; `EditorDeReflexaoPage` (criação).
**Context**: Escopo e repositório prontos. Feito quando escrever → guardar volta à página com o texto e a data; vazio desabilita; toque duplo grava uma; falha mantém o texto e loga sem conteúdo; várias reflexões aparecem na ordem.
**Where**: `apps/ponto_mobile/lib/registro/registro_do_ponto.dart`, `lib/registro/editor_de_reflexao_page.dart`, `lib/colecao/ponto_page.dart`, `test/registro/reflexao_na_pagina_test.dart`
**Depends on**: T11
**Requirement**: REF-01, REF-02, REF-06, REF-08
**Done when**:
- [ ] `'REF-01'`: texto e "Escrito em …" com o relógio do teste; dois toques rápidos → 1 linha no banco
- [ ] `'REF-02'`: "Guardar" desabilitado com "" e "  \n "; texto guardado sem pontas
- [ ] `'REF-06'`: duas do Caminho 2 em ordem, a do 81 ausente
- [ ] `'REF-08'`: falha (dois tipos de erro — L-001) → editor aberto, texto intacto, mensagem; log com o tipo e sem o texto
- [ ] UX: 320 px + texto "Muito grande" sem transbordar; campo com dica; botões com rótulo
- [ ] Gate quick (app) verde
**Tests**: widget · **Gate**: quick (app)
**Commit**: `✨ feat(mobile): write a reflection on a point`

---

### T13: Não perder o que foi escrito ao voltar ✅

**What**: `PopScope` no editor com o diálogo "Descartar o que você escreveu?".
**Context**: Editor existe. Feito quando voltar com mudança pergunta, "Continuar escrevendo" mantém, "Descartar" sai sem gravar, e sem mudança sai direto.
**Where**: `apps/ponto_mobile/lib/registro/editor_de_reflexao_page.dart`, `test/registro/editor_de_reflexao_test.dart`
**Depends on**: T12
**Requirement**: REF-03
**Done when**:
- [ ] `'REF-03'`: as três situações (com mudança → diálogo nas duas respostas; sem mudança e só espaços → sem diálogo); voltar pelo botão do sistema também
- [ ] Gate quick (app) verde
**Tests**: widget · **Gate**: quick (app)
**Commit**: `✨ feat(mobile): ask before discarding an unsaved reflection`

---

### T14: Editar e excluir uma reflexão ✅

**What**: tocar numa reflexão abre o editor em modo edição; "Excluir" com confirmação.
**Context**: Criação e descarte prontos. Feito quando editar muda texto e mostra "editado em", sem duplicar; excluir confirma e some. Última da fase: build gate.
**Where**: `apps/ponto_mobile/lib/registro/editor_de_reflexao_page.dart`, `lib/registro/registro_do_ponto.dart`, `test/registro/editor_de_reflexao_test.dart`
**Depends on**: T13
**Requirement**: REF-04, REF-05
**Done when**:
- [ ] `'REF-04'`: data de criação preservada, sufixo "editado em 14 de março de 2026, 21h05", uma só linha; guardar sem mudar não altera `editadaEm`
- [ ] `'REF-05'`: diálogo "Excluir esta reflexão? Não dá para desfazer."; "Cancelar" mantém; "Excluir" apaga só ela
- [ ] Gate build verde
**Tests**: widget · **Gate**: build
**Commit**: `✨ feat(mobile): edit and delete a reflection`

---

### T15: Favoritar e a lista de favoritos ✅

**What**: botão de favorito no `RegistroDoPonto`; `PontoGuardadoTile`; `FavoritosPage`; entrada "Favoritos" na biblioteca.
**Context**: Repositório de favoritos pronto. Feito quando favoritar alterna rótulo/ícone e persiste, e a lista mostra os favoritos na ordem com referência e prévia, abrindo o ponto.
**Where**: `apps/ponto_mobile/lib/registro/registro_do_ponto.dart`, `lib/registro/ponto_guardado_tile.dart`, `lib/registro/favoritos_page.dart`, `lib/colecao/biblioteca_page.dart`, `test/registro/favoritos_test.dart`
**Depends on**: T14
**Requirement**: FAV-01, FAV-02
**Done when**:
- [ ] `'FAV-01'`: rótulo "Favoritar" ↔ "Remover dos favoritos" + ícone + banco
- [ ] `'FAV-02'`: ordem, referência completa e início do texto em cada item, toque abre a página certa, estado vazio
- [ ] UX: botão de ícone com tooltip/rótulo; alvo ≥ 48 px
- [ ] Gate quick (app) verde
**Tests**: widget · **Gate**: quick (app)
**Commit**: `✨ feat(mobile): favourite a point and list favourites`

---

### T16: Guardar um ponto em coleções ✅

**What**: `GuardarEmColecaoPage`, `NomeDeColecaoDialog`, linha "Nas coleções: …" e ação "Guardar em uma coleção" no `RegistroDoPonto`.
**Context**: Repositório de coleções pronto. Sugestões ainda não existem — nesta tarefa o portão não é chamado (T19 o liga). Feito quando criar a partir do ponto, marcar/desmarcar várias e as regras do nome funcionam na tela, e a página mostra as coleções do ponto.
**Where**: `apps/ponto_mobile/lib/registro/guardar_em_colecao_page.dart`, `lib/registro/nome_de_colecao_dialog.dart`, `lib/registro/registro_do_ponto.dart`, `test/registro/guardar_em_colecao_test.dart`
**Depends on**: T15
**Requirement**: COL-01, COL-02, COL-03, PAG-01
**Done when**:
- [ ] `'COL-01'`, `'COL-02'`, `'COL-03'` (repetido → mensagem; vazio → confirmar desabilitado; 61 → campo limita a 60), `'PAG-01'` (linha com as duas na ordem de criação; ponto sem coleção → sem linha)
- [ ] UX: caixas de marcar com rótulo = nome; diálogo com validação inline
- [ ] Gate quick (app) verde
**Tests**: widget · **Gate**: quick (app)
**Commit**: `✨ feat(mobile): keep a point in one or more collections`

---

### T17: Coleções e os pontos de uma coleção ✅

**What**: `ColecoesPage`, `ColecaoPessoalPage`, entrada "Coleções" na biblioteca.
**Context**: Coleções já são criadas pela página do ponto. Feito quando a lista mostra ordem + contagem + "Nova coleção" + vazio, e a coleção mostra seus pontos na ordem + vazio, abrindo o ponto.
**Where**: `apps/ponto_mobile/lib/registro/colecoes_page.dart`, `lib/registro/colecao_pessoal_page.dart`, `lib/colecao/biblioteca_page.dart`, `test/registro/colecoes_test.dart`
**Depends on**: T16
**Requirement**: COL-04, COL-05
**Done when**:
- [ ] `'COL-04'`: três itens na ordem com "2 pontos"/"1 ponto"/"Nenhum ponto"; "Nova coleção" cria; vazio
- [ ] `'COL-05'`: ordem, referência + prévia, toque abre; vazio
- [ ] Gate quick (app) verde
**Tests**: widget · **Gate**: quick (app)
**Commit**: `✨ feat(mobile): list collections and their points`

---

### T18: Renomear e excluir uma coleção ✅

**What**: menu na `ColecaoPessoalPage` com "Renomear" (reusa `NomeDeColecaoDialog`) e "Excluir coleção" com confirmação.
**Context**: Telas de coleção prontas. Feito quando renomear reflete em toda parte e excluir confirma e preserva favoritos/reflexões.
**Where**: `apps/ponto_mobile/lib/registro/colecao_pessoal_page.dart`, `test/registro/colecoes_test.dart`
**Depends on**: T17
**Requirement**: COL-06, COL-07
**Done when**:
- [ ] `'COL-06'`: nome novo na coleção, na lista e na página do ponto; repetido recusado
- [ ] `'COL-07'`: diálogo com o texto da AC-27; "Cancelar" mantém; "Excluir" apaga só a coleção (favorito e reflexão do ponto continuam)
- [ ] Gate quick (app) verde
**Tests**: widget · **Gate**: quick (app)
**Commit**: `✨ feat(mobile): rename and delete a collection`

---

### T19: Coleções sugeridas no primeiro contato ✅

**What**: `SugestoesPage` + `passarPelasSugestoes`, chamado antes de "Coleções" e de "Guardar em uma coleção".
**Context**: Repositório já guarda a resposta. Feito quando o primeiro contato mostra as sete, nenhuma marcada; criar escolhidas segue para o destino; recusar/voltar não cria e nunca mais aparece (nem reabrindo o banco).
**Where**: `apps/ponto_mobile/lib/registro/sugestoes_page.dart`, `lib/registro/colecoes_page.dart` (ou chamador), `lib/registro/registro_do_ponto.dart`, `lib/colecao/biblioteca_page.dart`, `test/registro/sugestoes_test.dart`
**Depends on**: T18
**Requirement**: SUG-01, SUG-02, SUG-03
**Done when**:
- [ ] `'SUG-01'`: título, sete nomes na ordem, nenhum marcado, "Criar" desabilitado, "Agora não" habilitado — pelos dois caminhos
- [ ] `'SUG-02'`: criadas na ordem da A11; chega ao destino; segundo contato vai direto; reabrir o banco mantém
- [ ] `'SUG-03'`: "Agora não" → destino, nada criado; voltar → tela anterior; nunca mais aparece
- [ ] Gate quick (app) verde
**Tests**: widget · **Gate**: quick (app)
**Commit**: `✨ feat(mobile): suggest starter collections once`

---

### T20: Página que acompanha + registro indisponível nas telas ✅

**What**: testes e ajustes para PAG-02 (estado novo ao voltar; registro segue o "Próximo") e para a mensagem de indisponível na página, em Favoritos e em Coleções; piso de 320 px da linha de ações.
**Context**: Todas as telas existem. Feito quando PAG-02 e o lado de tela da AC-04 têm teste. Última da fase: build gate.
**Where**: `apps/ponto_mobile/lib/registro/*.dart` (só o necessário), `test/registro/registro_do_ponto_test.dart`
**Depends on**: T19
**Requirement**: PAG-02, CIFRA-04
**Done when**:
- [ ] `'PAG-02'` (a): após cada escrita e voltar, sem reabrir; (b) "Próximo" troca favorito, coleções e reflexões para os do Caminho 81
- [ ] `'CIFRA-04'`: registro nulo → mensagem na página (sem botões do registro), em Favoritos e em Coleções; texto do ponto continua
- [ ] UX: 320 px + "Muito grande" na página com registro, sem transbordar
- [ ] Gate build verde
**Tests**: widget · **Gate**: build
**Commit**: `🧪 test(mobile): pin the point page to the registro it shows` *(o código das tarefas anteriores já cumpria; só testes)*

---

### T21: Débito e comandos do registro ✅

**What**: TD-005 (iOS) e TD-004 ampliado (abrir o registro no aparelho, medir a KDF); comando de codegen e regra do `.g.dart` no `AGENTS.md`; Handoff. (ADR-002 e AD-007..009 já entraram no commit de planejamento, na fase Design.)
**Context**: Código completo. Feito quando débito e comandos vivem no dono certo antes do Verifier ler o projeto.
**Where**: `.specs/TECH-DEBT.md`, `AGENTS.md`, `.specs/STATE.md` (Handoff)
**Depends on**: T20
**Requirement**: — (rastreabilidade das decisões)
**Done when**:
- [ ] arquivos atualizados; gate build verde
**Tests**: none · **Gate**: build
**Commit**: `📚 docs: record registro debt and codegen commands`

---

## Task Granularity Check

| Task | Scope | Status |
| --- | --- | --- |
| T1, T2 | 1 arquivo de motor cada | ✅ |
| T3 | schema + 1 repositório (o repositório é o que torna o schema testável — merge backward) | ⚠️ OK, coeso |
| T4, T5 | 1 repositório cada (T5 + agregado de 3 linhas) | ✅ |
| T6, T7, T8 | 1 componente de infra cada | ✅ |
| T9 | 1 configuração | ✅ |
| T10 | escopo + ligação na abertura (mesma mudança) | ⚠️ OK, coeso |
| T11 | 1 função | ✅ |
| T12 | seção da página + editor (o editor só é alcançável pela seção — merge backward) | ⚠️ OK, coeso |
| T13, T14 | 1 comportamento do editor cada | ✅ |
| T15 | botão + lista (FAV-02 precisa de favoritos vindos da página) | ⚠️ OK, coeso |
| T16 | tela + diálogo + linha (um fluxo) | ⚠️ OK, coeso |
| T17 | 2 telas encadeadas | ⚠️ OK, coeso |
| T18, T19, T20 | 1 comportamento cada | ✅ |
| T21 | docs | ✅ |

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
| T18 | T17 | T17 → T18 | ✅ |
| T19 | T18 | T18 → T19 | ✅ |
| T20 | T19 | T19 → T20 | ✅ |
| T21 | T20 | T20 → T21 | ✅ |

## Test Co-location Validation

| Task | Code Layer | Matrix Requires | Task Says | Status |
| --- | --- | --- | --- | --- |
| T1, T2 | Motor | unit | unit | ✅ |
| T3, T4, T5 | Repositórios | integration | integration | ✅ |
| T6, T7, T8 | Infra | integration | integration | ✅ |
| T9 | Manifesto | unit | unit | ✅ |
| T10 | Abertura do app | widget | widget | ✅ |
| T11 | Formatação | unit | unit | ✅ |
| T12–T20 | Telas | widget | widget | ✅ |
| T21 | Docs | none | none | ✅ |

## Requirement → Task

| Req | Tasks | | Req | Tasks |
| --- | --- | --- | --- | --- |
| CIFRA-01 | T6, T8 | | FAV-01 | T4, T15 |
| CIFRA-02 | T6 | | FAV-02 | T4, T15 |
| CIFRA-03 | T7, T8 | | COL-01 | T5, T16 |
| CIFRA-04 | T7, T8, T10, T20 | | COL-02 | T5, T16 |
| CIFRA-05 | T9 | | COL-03 | T2, T5, T16 |
| REF-01 | T3, T12 | | COL-04 | T5, T17 |
| REF-02 | T1, T3, T12 | | COL-05 | T5, T17 |
| REF-03 | T13 | | COL-06 | T5, T18 |
| REF-04 | T3, T14 | | COL-07 | T5, T18 |
| REF-05 | T3, T14 | | PAG-01 | T2, T16 |
| REF-06 | T3, T12 | | PAG-02 | T20 |
| REF-07 | T11 | | SUG-01 | T19 |
| REF-08 | T12 | | SUG-02 | T5, T19 |
| | | | SUG-03 | T5, T19 |

**Coverage:** 27 total, 27 mapped to tasks.

**Tools:** MCP `context7` (drift, flutter_secure_storage) quando a API for incerta · Skills: `spec-driven`, `tdd` (loop interno), `commit-conventions`, `dart:dart-core-engineering`.
