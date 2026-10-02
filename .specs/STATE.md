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
- **Decision**: Todo teste derivado de requisito começa o nome com o ID (`'LER-07: …'`, `'BASE-02: …'`).
- **Reason**: rastreio requisito → teste por busca textual, sem configuração de tags.
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

## Handoff

- **Feature**: `.specs/features/ler` — **verificada** (Verifier PASS, rodada 1)
- **Phase / Task**: Execute concluído (T1–T17 + F1–F5); consolidação nos docs feita
- **Completed**: T1–T17, F1–F5
- **In-progress** (file:line): none
- **Next step**: UAT num Android real (TD-004) das premissas A1, A3, A4, A5, A7, A10, A11, A12; depois puxar v0.3 "Guardar" (`registro`) — rever AD-002 (gatilho)
- **Blockers**: nenhum aparelho/emulador nesta máquina
- **Uncommitted files**: none
- **Branch**: `feat/v0.2-ler` (empilhada sobre `feat/v0.1-fundacoes`; nada enviado ao remoto)
