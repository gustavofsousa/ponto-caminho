# Roadmap — Ponto do Caminho

> **Ordem** em que o produto é construído. O *quê* cada domínio pode virar está em
> [`backlog.md`](backlog.md); *quais* domínios existem e onde moram no código, em
> [`dominios.md`](dominios.md). Visão de produto: [`onepager.md`](onepager.md).
> Execução de cada feature: `.specs/features/<feature>/` (spec-driven).

> **Modo: MVP.** Sem tração confirmada. O alvo da v1.0 não é escala — é **um leitor real usando o
> app por duas semanas sem pedir nada que não esteja lá**. Tudo que não serve a isso fica no backlog.

> **Status:** ✅ feito · ⚠️ feito c/ débito · 🔄 em andamento · 🗓️ planejado · ⚪ sem spec · 🔒 bloqueado
> **Domínio** (pasta durável, `dominios.md`) ≠ **Feature** (unidade de entrega). Tag por linha.
> **SemVer:** MAJOR = novo pilar · MINOR = feature no pilar · `0.x` = primeiro pilar em construção.
> **Invariante:** no máximo **1** linha `🔄` no documento inteiro.

O princípio que governa a ordem: **uma primeira versão extremamente bem executada em leitura,
registro e ponto aleatório vale mais que muitas funcionalidades superficiais.** Uma versão só
começa quando a anterior está *boa* — não quando está tecnicamente pronta.

---

## Visão geral (uma tela)

| Versão | Fase | Alvo da fase | Domínios | Status |
|--------|------|--------------|----------|--------|
| v0.1 | Fundações | o motor devolve um ponto mock num app que roda no celular | `colecao`, `selecao`, `— infra` | 🔄 |
| v0.2 | Ler | navegar obra → capítulo → ponto e ler com prazer | `colecao`, `selecao`, `preferencias` | 🗓️ |
| v0.3 | Guardar | guardar o que um ponto provocou | `registro` | 🗓️ |
| v0.4 | Voltar | um ponto para agora + continue de onde parou | `selecao`, `leitura` | 🗓️ |
| v1.0 | Leitor real | duas semanas de uso real, texto real, acessível | todos acima, ⟂ acessibilidade | 🗓️ |
| v1.1 | Ponto do dia | o app acompanha sem cobrar | `selecao`, `lembrete`, `preferencias` | ⚪ |
| v1.2 | Busca | reencontrar um ponto pela palavra | `busca` | ⚪ |
| v1.3 | Progresso | percurso visível, com discrição | `leitura` | ⚪ |
| v2.0 | Memória | o que foi escrito há meses devolve valor | `registro`, `conta`, `busca` | 💤 |
| v3.0 | Extensão | o motor sai do app | — | 💤 |

---

## v0.1 — Fundações 🔄
**Alvo:** abrir o app num celular real e ver o ponto 1 de *Caminho* (mock), vindo do motor — não
de um texto colado na tela.

| Feature | Domínio | Slice | Status |
|---------|---------|-------|--------|
| schema da obra + `validar.py` | `colecao` | — | ✅ |
| pontos mock nas três obras (`nota: "mock"`, `--estrito`) | `colecao` | — | ✅ |
| escolha de stack: Flutter + Dart, drift cifrável — [ADR-001](adr/001-stack-mobile-flutter.md) | `— infra` | — | ✅ |
| motor como pacote Dart puro: `lerColecao`, `PontoId`, `obterPonto`, `referenciaDe` | `colecao`, `selecao` | — | ✅ |
| app abre no ponto 1 vindo do motor — APK debug gerado; falta rodar num aparelho | `— infra` | — | 🔄 |
| CI: `validar.py`, lint, testes do motor | `— infra` | — | 🗓️ |

## v0.2 — Ler 🗓️
**Alvo:** alguém navega as três obras e lê um ponto inteiro sem nada atrapalhar.

| Feature | Domínio | Slice | Status |
|---------|---------|-------|--------|
| biblioteca: obra → capítulo (com contagem) → ponto | `colecao` | — | ⚪ |
| página do ponto: texto, referência completa, espaço em branco | `colecao` | — | ⚪ |
| anterior / próximo atravessando capítulos | `selecao` | — | ⚪ |
| tema claro/escuro/sistema + tamanho de fonte | `preferencias` | — | ⚪ |
| tipografia editorial provisória + tokens base | ⟂ design | — | ⚪ |

## v0.3 — Guardar 🗓️
**Alvo:** o leitor guarda, num ponto, o que ele provocou — e encontra de novo.

| Feature | Domínio | Slice | Status |
|---------|---------|-------|--------|
| reflexão: criar, editar, excluir, data e hora visíveis — **cifrada desde o primeiro byte** | `registro` | — | ⚪ |
| favorito | `registro` | — | ⚪ |
| coleção pessoal: um ponto em várias | `registro` | — | ⚪ |
| coleções sugeridas no primeiro uso, recusáveis | `registro` | — | ⚪ |
| reflexões e coleções do ponto exibidas na própria página | `registro` | — | ⚪ |

## v0.4 — Voltar 🗓️
**Alvo:** abrir o app sem saber por onde começar e chegar num ponto em um toque.

| Feature | Domínio | Slice | Status |
|---------|---------|-------|--------|
| registro de leitura (evento + origem) | `leitura` | — | ⚪ |
| continue de onde parou | `leitura` | — | ⚪ |
| um ponto para agora, evitando leituras recentes, filtro por obra | `selecao` | — | ⚪ |
| compartilhar **referência** (não o texto) | `colecao` | — | ⚪ |

## v1.0 — Leitor real 🗓️
**Alvo:** um leitor real usa por duas semanas sem pedir nada que não esteja lá.

| Feature | Domínio | Slice | Status |
|---------|---------|-------|--------|
| texto e índice reais nas três obras — `validar.py --estrito` verde | `colecao` | — | ⚪ |
| auditoria de acessibilidade: leitor de tela, contraste, fonte do sistema, alvos, reduzir movimento | ⟂ acessibilidade | — | ⚪ |
| tipografia e design system definitivos | ⟂ design | — | ⚪ |
| microcopy revisada contra [`tom-de-voz.md`](tom-de-voz.md) | ⟂ tom de voz | — | ⚪ |
| build instalável distribuído ao leitor de teste | `— infra` | — | ⚪ |

**Explicitamente fora da v1.0:** conta, sincronização, notificação, busca, exportação. Tudo local,
tudo offline, tudo no aparelho.

## v1.1 — Ponto do dia ⚪
**Alvo:** alguém volta por vontade própria depois de uma semana longe — e é recebido sem menção à ausência.

| Feature | Domínio | Slice | Status |
|---------|---------|-------|--------|
| ponto do dia determinístico na tela inicial | `selecao` | — | ⚪ |
| preferências: obra ou alternância, dias, horário | `preferencias` | — | ⚪ |
| notificação **opcional, desligada por padrão** | `lembrete` | — | ⚪ |
| histórico de pontos do dia (reconstruído, não armazenado) | `selecao` | — | ⚪ |

## v1.2 — Busca ⚪ · v1.3 — Progresso ⚪
Detalhe em [`backlog.md`](backlog.md) (`busca`, `leitura`). Ganham tabela quando forem puxadas.

## v2.0 — Memória 💤 · v3.0 — Extensão 💤
Revisita, conta opcional + sincronização, exportação, busca por ideia (v2.0); web, widget, desktop,
API do motor, segunda coleção (v3.0). Pool completo em [`backlog.md`](backlog.md).

---

## Domínios (referência — detalhe em `dominios.md`)
- **colecao** — corpus: obra, capítulo, ponto, tema · **selecao** — qual ponto mostrar ·
  **leitura** — o que foi lido e por onde retomar · **registro** — reflexão, favorito, coleção pessoal ·
  **preferencias** — como o leitor quer ler · **lembrete** — notificação do ponto do dia ·
  **busca** — reencontrar · **conta** — sincronização opcional.

## Débito herdado das fases fechadas

| TD | Origem | Status | Trigger de revisita |
|----|--------|--------|----------------------|
| TD-001 | v0.1 dado mock | open | antes de qualquer build fora do aparelho do Gustavo — `--estrito` precisa passar |
| TD-002 | `livros/caminho.json` caps. 17–18 sem corte confirmado | open | com o livro impresso na mão (v1.0) |

## Decisões pendentes (ordem em que travam o trabalho)

| # | Decisão | Trava | Onde |
|---|---------|-------|------|
| 1 | Tipografia editorial | v0.2 (provisória) / v1.0 (definitiva) | `backlog.md` › ⟂ design |
| 2 | Fronteira motor ↔ app (o que é pacote puro) | v0.2 em diante | `dominios.md` › regras |
| 3 | Edição de referência do texto | v1.0 texto real | `livros/README.md` |
| 4 | Formato de exportação | v2.0 | `backlog.md` › `registro` |

## Riscos

| Risco | Resposta |
|-------|----------|
| **Direitos autorais** — as três obras não são de domínio público | Desenvolvimento só com mock; `--estrito` impede publicar mock. Distribuição pública do texto real exige licença — decidir antes de qualquer build fora do círculo de teste. |
| Sensibilidade das reflexões | Cifradas desde a v0.3; nenhuma telemetria de conteúdo. |
| Migrar de banco em claro para cifrado depois | drift + `sqlite3mc` desde o primeiro registro (v0.3) — ADR-001. |
| Virar "mais um app de citações" | v0.3 (guardar) vem antes de qualquer feature de volume. |
| Gamificação pela porta dos fundos | Regra de domínio em `leitura`; ver "Fora de escopo". |

## Fora de escopo (decisão de NÃO fazer, não "ainda não")

| Item | Motivo |
| --- | --- |
| Sequências de dias, medalhas, rankings | Culpa e competição não pertencem à vida interior |
| Feed social, curtidas, comentários públicos | O registro é pessoal por natureza |
| IA que comenta ou interpreta os textos | Não é papel do produto; pertence a pessoas |
| Publicidade | Incompatível com a sensibilidade dos dados |
| Venda ou análise comercial de anotações | Proibido por princípio, não por política |
| Notificações de reengajamento | Manipulação; o app espera, não persegue |
