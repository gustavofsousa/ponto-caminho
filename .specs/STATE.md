# STATE

## Decisions

### AD-001
- **Decision**: Flutter + Dart; motor de pontos como pacote Dart puro (`packages/ponto_motor`), app em `apps/ponto_mobile`.
- **Reason**: ver `docs/adr/001-stack-mobile-flutter.md` (ADR-001 é o registro canônico).
- **Trade-off**: web futura não reaproveita o motor sem portar.
- **Scope**: projeto inteiro
- **Date**: 2026-10-02
- **Status**: active

### AD-002
- **Decision**: Estado compartilhado do app com `ValueNotifier` + `InheritedNotifier`; nenhum pacote de gerência de estado. Dado imutável (coleção) passa por construtor.
- **Reason**: há uma única peça de estado compartilhado (preferências); o Flutter já resolve sem dependência.
- **Trade-off**: se surgirem várias fontes de estado assíncrono, o encanamento manual cresce.
- **Scope**: `apps/ponto_mobile`
- **Date**: 2026-10-02
- **Status**: active
- **Revisit trigger**: quando `registro` (v0.3) trouxer estado persistido observado por mais de uma tela. → **revisto em AD-007** (continua sem pacote de estado).

### AD-003
- **Decision**: O motor é o único dono do formato de `livros/`; recebe I/O por porta (`carregarColecao(lerArquivo)`), nunca lê arquivo.
- **Reason**: motor puro e testável; app e teste de contrato não duplicam o formato.
- **Trade-off**: uma função a mais na API do motor.
- **Scope**: `packages/ponto_motor`, qualquer superfície que carregue a coleção
- **Date**: 2026-10-02
- **Status**: active

### AD-004
- **Decision**: Todo teste derivado de requisito começa o nome com o ID (`'LER-07: …'`, `'BASE-02: …'`). Dentro de um `group` sem ID (ex.: `group('criar', …)`), o ID abre a descrição do teste; o nome completo fica `criar COL-01: …` e isso basta.
- **Reason**: rastreio requisito → teste por busca textual, sem configuração de tags — o que conta é o ID estar no nome completo.
- **Trade-off**: disciplina manual de nomes.
- **Scope**: todos os testes (Dart, Flutter, Python)
- **Date**: 2026-10-02
- **Status**: active

### AD-005
- **Decision**: Preferências não sensíveis em `shared_preferences` (uma chave por campo, valor = `enum.name`; inválido → padrão). Dado pessoal sensível só no banco cifrado (drift, v0.3).
- **Reason**: preferência não exige cifra; leitura defensiva nunca trava a abertura.
- **Trade-off**: duas tecnologias de armazenamento a partir da v0.3.
- **Scope**: `apps/ponto_mobile/lib/preferencias`
- **Date**: 2026-10-02
- **Status**: active

### AD-006
- **Decision**: Navegação com `Navigator` + `MaterialPageRoute`; sem pacote de rotas.
- **Reason**: quatro telas lineares, sem deep link.
- **Trade-off**: migrar quando deep links chegarem.
- **Scope**: `apps/ponto_mobile`
- **Date**: 2026-10-02
- **Status**: active
- **Revisit trigger**: quando o deep link `ponto:` (backlog, Incubadora) for puxado para uma versão.

### AD-007
- **Decision**: Estado do registro nas telas = streams `watch()` do drift, criados no `initState` de cada widget e servidos por um `InheritedWidget` (`RegistroEscopo`, `Registro?` — nulo = indisponível). Nenhum pacote de gerência de estado.
- **Reason**: o gatilho do AD-002 disparou (várias telas observam o registro); o banco já emite a cada escrita, então toda tela aberta se atualiza sem encanamento manual.
- **Trade-off**: telas dependem do formato de stream do drift; um widget mal escrito que crie o stream no `build` re-consulta a cada reconstrução.
- **Scope**: `apps/ponto_mobile/lib/registro`
- **Date**: 2026-10-02
- **Status**: active
- **Revisit trigger**: estado derivado que cruze várias fontes (ex.: progresso da v1.3 combinando leitura + registro).

### AD-008
- **Decision**: Registro em drift + SQLite3MultipleCiphers (hook `sqlite3: source: sqlite3mc`), arquivo cifrado desde a criação; chave aleatória de 256 bits no Keystore/Keychain (`flutter_secure_storage`), gravada antes do arquivo; nunca gerar chave com banco existente; backup do Android desligado. Registro canônico: ADR-002.
- **Reason**: reflexões são dado pessoal religioso; cifrar depois exige migração (ADR-001); chave sem senha não se esquece.
- **Trade-off**: trocar de aparelho perde o registro até existir conta/exportação (v2.0).
- **Scope**: `apps/ponto_mobile/lib/infra`, `lib/registro`, manifesto Android
- **Date**: 2026-10-02
- **Status**: active

### AD-009
- **Decision**: Falha no registro vai ao log só com o **tipo** do erro (`FalhaNoRegistro(runtimeType)`), nunca a mensagem nem o objeto original.
- **Reason**: `SqliteException.toString()` inclui os parâmetros da instrução — o texto da reflexão vazaria para o log (regra 5 de `dominios.md`).
- **Trade-off**: diagnóstico mais pobre; a pilha continua no log.
- **Scope**: todo `catch` que envolva o banco do registro
- **Date**: 2026-10-02
- **Status**: active

### AD-010
- **Decision**: Leitura é um log de eventos (`leituras`) no banco cifrado do registro; "mais recente" = maior `id` autoincremento (ordem de gravação), nunca `lidoEm`.
- **Reason**: regra 4 (progresso derivado de eventos); o relógio do aparelho pode voltar, a ordem de gravação não. `AUTOINCREMENT` nunca reusa id.
- **Trade-off**: consultas de "distintos mais recentes" agrupam o histórico inteiro (TD-007).
- **Scope**: `apps/ponto_mobile/lib/leitura`, qualquer cálculo futuro de progresso (v1.3)
- **Date**: 2026-10-07
- **Status**: active

### AD-011
- **Decision**: Toda migração do registro roda dentro de `transaction()` no `onUpgrade` e é testada contra o schema anterior congelado (`test/registro/schema_vN.dart`, cópia do `sqlite_master` capturada antes da mudança), com duas provas: as linhas antigas sobrevivem e o schema migrado é igual ao de um banco novo.
- **Reason**: o drift não envolve o `onUpgrade` numa transação; e, depois que o código muda, não há outro jeito de criar um arquivo "da versão anterior" para testar.
- **Trade-off**: um arquivo de fixture por versão de schema.
- **Scope**: `apps/ponto_mobile/lib/registro/banco_registro.dart`, toda subida de `schemaVersion`
- **Date**: 2026-10-07
- **Status**: active

### AD-012
- **Decision**: CI no GitHub Actions (`ubuntu-latest`, Flutter fixo na versão de dev). O portão mora em `tool/check.sh`; o workflow só chama o script, um passo por portão (`livros`, `motor`, `app`, `codegen`), e o script fixa `TZ=America/Sao_Paulo`.
- **Reason**: repo público → minutos ilimitados nos runners padrão, sem conta nova; Codemagic só se paga com assinatura iOS, fora do roadmap próximo. Com o portão no script, o mesmo comando roda local e no CI, e o fuso fixado vale também numa máquina em UTC.
- **Trade-off**: assinatura iOS/TestFlight dá mais trabalho manual no Actions do que no Codemagic.
- **Scope**: `tool/`, `.github/workflows/`, todo portão de "Done means"
- **Date**: 2026-10-08
- **Status**: active
- **Revisit trigger**: quando o pipeline iOS (TD-005) for puxado para uma versão.

## Handoff

- **Feature**: `.specs/features/ci` (v0.1) — **verificada** (Verifier PASS local, rodada 0; run verde no GitHub)
- **Phase / Task**: Execute concluído (spec + AD-012, `tool/check.sh`, workflow, verificação); consolidação nos docs feita
- **Completed**: todos os passos do plano inline (Medium, sem `tasks.md`)
- **In-progress** (file:line): none
- **Next step**: UAT num Android real (TD-004) da v0.2–v0.4 — inclui as decisões A7–A22 marcadas "não — revisar/UAT" no spec da v0.4; antes de puxar "texto real" (v1.0), decidir onde o texto mora: o repo no GitHub é público (roadmap › Riscos)
- **Blockers**: nenhum aparelho conectado; o emulador do SDK não tem imagem de sistema nem `cmdline-tools`; iOS sem Mac (TD-005)
- **Uncommitted files**: none
- **Branch**: `feat/v0.1-ci` (sobre `feat/v0.4-voltar` → `feat/v0.3-guardar` → `main` local). No remoto: `feat/v0.4-voltar` e `feat/v0.1-ci`; `main` local está 31 commits à frente de `origin/main`; `feat/v0.3-guardar` nunca foi enviada (está contida em `feat/v0.4-voltar`)
