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
- **Revisit trigger**: quando `registro` (v0.3) trouxer estado persistido observado por mais de uma tela.

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

## Handoff

- **Feature**: `.specs/features/ler`
- **Phase / Task**: Tasks escritas; Execute começa pela Fase 1 / T1
- **Completed**: none
- **In-progress** (file:line): none
- **Next step**: executar T1 (análise estática estrita)
- **Blockers**: none
- **Uncommitted files**: `.specs/` (commit no fim da fase de planejamento)
- **Branch**: `feat/v0.2-ler`
