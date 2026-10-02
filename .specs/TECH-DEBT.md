# Tech Debt Ledger

Tracked technical debt. Recorded = exists (AGENTS.md: no entry, no debt).
Format: `TD-NNN` · Status: `open | in-progress | resolved | wontfix`.
`docs/roadmap.md` › "Débito herdado" mostra o resumo; o detalhe vive aqui.

---

## TD-001 — Dado mock nas três obras

**Status:** open
**Opened:** 2026-10-02
**Origin:** v0.1 — texto inventado (`"nota": "mock"`) para desenvolver antes do texto real; índices de *Sulco* e *Forja* provisórios.

**What to investigate / change:**
1. Substituir `texto` pelo real, apagar `nota`, incrementar `versaoDados`.
2. Trocar os índices provisórios de *Sulco* e *Forja* pelos reais.

**Impact if ignored:** texto inventado chegaria ao leitor como se fosse do autor.

**Revisit trigger:** antes de qualquer build fora do aparelho do Gustavo — `python3 livros/validar.py --estrito` precisa passar.

---

## TD-002 — Caminho, capítulos 17–18 sem corte nem títulos

**Status:** open
**Opened:** 2026-10-02
**Origin:** índice reconstituído de fontes públicas; o intervalo 387–416 tem dois capítulos sem ponto de corte nem títulos conferidos.

**What to investigate / change:**
1. Conferir com o livro impresso: títulos e ponto de corte entre 17 e 18.

**Impact if ignored:** os dois capítulos aparecem como "Capítulo 17/18" sem contagem; referência sem nome de capítulo.

**Revisit trigger:** v1.0 (texto real), com o livro na mão.

---

## TD-003 — Contraste testado só nos tokens

**Status:** open
**Opened:** 2026-10-02
**Origin:** feature `ler` — o teste de contraste cobre os pares texto/fundo do tema, não cada combinação de widget.

**What to investigate / change:**
1. Auditoria de acessibilidade completa (contraste por tela, leitor de tela, alvos de toque).

**Impact if ignored:** uma combinação de cor fora dos tokens pode ficar abaixo de AA.

**Revisit trigger:** gate da v1.0 (auditoria de acessibilidade no roadmap).

---

## TD-004 — Sem execução em aparelho real

**Status:** open
**Opened:** 2026-10-02
**Origin:** v0.1/feature `ler` — a máquina de desenvolvimento não tem emulador nem aparelho; a verificação é teste + APK gerado.

**What to investigate / change:**
1. Rodar `flutter run` num Android real: abertura, navegação, fonte Literata, tema, tamanho.
2. Criar um AVD (`flutter emulators --create`) se for útil para o dia a dia.

**Impact if ignored:** comportamento nativo (splash, fonte variável, escala do sistema) nunca visto.

**Revisit trigger:** próxima sessão com um Android conectado — antes de fechar a v0.2 no roadmap.
