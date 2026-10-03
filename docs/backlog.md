# Backlog — Ponto do Caminho

> **Versão** 0.1 · out/2026. Organizado **por domínio** (espelha [`dominios.md`](dominios.md)).
> É o **pool não sequenciado**: os caminhos que cada domínio pode tomar. Nada entra no
> [`roadmap.md`](roadmap.md) sem passar por aqui e ganhar uma Versão.

**Faixas:** *Amadurecer* (concreto, quase pronto para spec) · *Novo / Visão* · *Decisão ao puxar
pro spec* · *Dívida técnica*. Só aparecem as faixas com conteúdo.

**Status:** ✅ feito · 🔄 em andamento · 🗓️ planejado · ⚪ sem spec · 💤 futuro (v2+)

---

## Core · Texto

### colecao
- **Amadurecer:** schema + validador (v0.1) ✅ · pontos mock + `--estrito` (v0.1) ✅ · fronteira firme
  dos livros (v0.2) ✅ · biblioteca obra → capítulo → ponto (v0.2) ✅ · página do ponto com
  referência completa (v0.2) ✅ ·
  compartilhar referência (v0.4) ⚪ · texto e índice reais (v1.0) ⚪.
- **Novo / Visão:** temas como dado de conteúdo, transversais às três obras (alimenta `busca`) ·
  referências bíblicas por ponto · segunda coleção provando a troca (v3.0) 💤 · outros idiomas 💤.
- **Decisão ao puxar pro spec:** edição de referência (editora, ano, tradutor) para o texto real —
  trava v1.0 · empacotar o JSON no app ou baixar por versão — recomendação: **empacotar** na v1
  (offline total, zero servidor).
- **Dívida técnica:** TD-001 mock nas três obras · TD-002 corte dos caps. 17–18 de *Caminho* ·
  índice de *Sulco* e *Forja* é provisório (capítulos de tamanho igual).
- **Guarda-corpo:** nenhum id de obra fora de `livros/` (regra 1).

### selecao
- **Amadurecer:** `obterPonto(id)` (v0.1) ✅ · anterior/próximo atravessando capítulos (v0.2) ✅ ·
  um ponto para agora, evitando recentes, filtro por obra (v0.4) ⚪ · ponto do dia determinístico
  (v1.1) ⚪ · histórico do ponto do dia reconstruído (v1.1) ⚪.
- **Novo / Visão:** filtro do aleatório por capítulo ou tema · gesto de deslizar para anterior/próximo
  na página do ponto (fora da v0.2: os botões resolvem e são acessíveis).
- **Decisão ao puxar pro spec:** janela de "recentes" para o aleatório (N pontos ou N dias) ·
  semente do ponto do dia antes de existir conta — recomendação: gerada no primeiro uso, local.
- **Guarda-corpo:** determinismo onde prometido; aleatoriedade injetada (regra 6).

## Core · Memória

### leitura
- **Amadurecer:** evento de leitura com origem (v0.4) ⚪ · continue de onde parou (v0.4) ⚪ ·
  progresso por capítulo e obra (v1.3) ⚪ · estado do capítulo (v1.3) ⚪.
- **Decisão ao puxar pro spec:** **marcação manual de capítulo concluído** — o roadmap antigo
  pedia; o [`modelo.md`](modelo.md) diz que progresso "nunca é escrito à mão". Recomendação:
  registrar como *evento* (`capituloConcluido`) que o cálculo respeita — mantém a regra 4.
  · O que conta como "lido": abrir, rolar até o fim ou tempo mínimo na página?
- **Guarda-corpo:** nenhum streak, meta ou "dias seguidos" (regra 4).

### registro
- **Amadurecer:** reflexão cifrada (v0.3) ✅ · favorito (v0.3) ✅ · coleção pessoal, renomear e
  excluir (v0.3) ✅ · coleções sugeridas recusáveis (v0.3) ✅ · reflexões e coleções do ponto na
  própria página (v0.3) ✅.
- **Novo / Visão:** linha do tempo de reflexões (v2.0) 💤 · "você escreveu sobre este ponto há um
  ano", só ao abrir o ponto (v2.0) 💤 · releitura por período/obra/coleção (v2.0) 💤 · exportação
  Markdown/PDF/texto (v2.0) 💤 · compartilhar coleção = só `PontoId[]` (v3.0) 💤 · marcador na
  lista de pontos de um capítulo (tem reflexão, é favorito) · reordenar coleções e os pontos dentro
  delas · sugestão única "Se algo aqui ficou, escreva" depois do primeiro ponto (`tom-de-voz.md` §3).
- **Decisão ao puxar pro spec:** formato de exportação (v2.0) — condiciona a promessa de
  portabilidade. *(Resolvida na v0.3: o termo de código é `Reflexao`; "anotação" é sinônimo só no
  `modelo.md`.)*
- **Guarda-corpo:** reflexão nunca sai daqui sem pedido explícito (regra 5).

## Suporte

### preferencias
- **Amadurecer:** tema claro/escuro/sistema + tamanho de fonte (v0.2) ✅ · preferências do ponto do
  dia (v1.1) ⚪.

### lembrete
- **Amadurecer:** notificação opcional, desligada por padrão, cópia serena (v1.1) ⚪.
- **Guarda-corpo:** uma por dia, no horário escolhido; quem não abrir não ouve sobre isso.

### busca
- **Amadurecer:** palavra-chave no conteúdo (v1.2) ⚪ · filtros obra/capítulo/número/favorito/
  coleção (v1.2) ⚪ · busca local nas próprias reflexões (v1.2) ⚪ · histórico apagável (v1.2) ⚪.
- **Novo / Visão:** busca por ideia — linguagem natural, resultado sempre ponto com referência
  (v2.0) 💤 *(cruza ⟂ IA)*.
- **Decisão ao puxar pro spec:** busca semântica no aparelho ou em servidor — servidor quebra o
  "tudo local" e exige revisão de privacidade.

### conta
- **Novo / Visão:** conta opcional · sincronização cifrada · exclusão integral em caminho curto (v2.0) 💤.
- **Decisão ao puxar pro spec:** identidade e modelo de sincronização — **decisão macro**, RFD
  próprio quando a v2.0 for puxada.

## Genérico

### infra
- **Amadurecer:** stack Flutter (v0.1) ✅ ADR-001 · banco drift + `sqlite3mc`, chave no Keystore,
  fora do backup (v0.3) ✅ ADR-002 · CI (v0.1) 🗓️ — rodar os testes com um fuso fora de UTC fixado
  (`TZ=America/Sao_Paulo`): o teste de data só pega a falta de `toLocal()` fora de UTC ·
  pipeline iOS na nuvem (Codemagic ou runner macOS) antes do primeiro TestFlight ⚪.
- **Decisão ao puxar pro spec:** CI: GitHub Actions ou Codemagic para tudo — **decisão macro**, RFD.
- **Dívida técnica:** TD-005 registro sem iOS · TD-006 `drift_dev`/`sqlite3` presos pelo Flutter.

---

## Transversal (corta domínios — não é domínio, não é pasta)

- **Acessibilidade** — **sempre ligada**; auditoria formal no gate da v1.0.
- **Design / tipografia** — tipografia provisória Literata + tokens AA (v0.2) ✅ · definitiva + design system (v1.0) ·
  paleta azul-noite, marfim/areia, terracota/cobre, âmbar · referência nas capas históricas de *Caminho*.
- **Tom de voz** — microcopy revisada (v1.0) contra [`tom-de-voz.md`](tom-de-voz.md).
- **Privacidade** — telemetria só de eventos; decidir **se** há telemetria na v1.0 (recomendação: não).
- **IA** — só busca por ideia (v2.0). Nunca comenta, parafraseia ou aconselha; nunca lê reflexões.
- **Marca** — fechar nome, território e narrativa ("Ponto" vs "Ponto do Caminho").

---

## Incubadora (sem domínio ainda — nada aqui está decidido)

- **Widget de tela inicial** com o ponto do dia (v3.0) — provável casa: `selecao` + app.
- **Superfícies além do celular** — web, desktop, extensão de navegador (v3.0).
- **Integração com notas** (Obsidian, Notion) — provável casa: exportação de `registro`.
- **Grupos de formação e círculos de estudo** — quem, exatamente? Sem usuário definido ainda.

- **Telas de boas-vindas** (`tom-de-voz.md` §2: três telas puláveis + "Comece pelo ponto 1") — fora
  da v0.2; provável casa: app, junto do "continue de onde parou" (v0.4).

**Cru — a destilar:** API do motor · deep link `ponto:` abrindo o app.
