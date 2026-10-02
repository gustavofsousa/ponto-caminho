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
3. (v0.3) Abrir o registro no aparelho: chave criada no Keystore, `PRAGMA cipher` ativo,
   reabrir depois de fechar o app, e medir quanto a derivação da chave atrasa a abertura.

**Impact if ignored:** comportamento nativo (splash, fonte variável, escala do sistema) nunca visto.

**Revisit trigger:** próxima sessão com um Android conectado — antes de fechar a v0.2 no roadmap.

---

## TD-005 — Registro sem configuração nem teste no iOS

**Status:** open
**Opened:** 2026-10-02
**Origin:** feature `guardar` (v0.3) — sem Mac nesta máquina; só o Android foi configurado (backup desligado, ADR-002).

**What to investigate / change:**
1. Keychain: acessibilidade da chave (`first_unlock_this_device`, para não migrar para outro aparelho).
2. Excluir a pasta do registro do backup do iCloud (`NSURLIsExcludedFromBackupKey`), pelo mesmo motivo do Android.
3. Rodar a suíte e abrir o registro num iPhone/simulador.

**Impact if ignored:** no iOS, um backup do iCloud poderia restaurar o banco sem a chave — registro ilegível na abertura.

**Revisit trigger:** pipeline de iOS (backlog › `infra`), antes do primeiro TestFlight.

---

## TD-006 — drift_dev e sqlite3 presos abaixo da versão atual

**Status:** open
**Opened:** 2026-10-02
**Origin:** feature `guardar` (v0.3) — `drift_dev` ≥ 2.34.6 e `sqlite3` ≥ 3.6 pedem `meta`/`analyzer` mais novos do que o Flutter 3.41.7 fixa; o pub resolveu `drift` 2.34.4, `drift_dev` 2.34.0, `sqlite3` 3.5.2.

**What to investigate / change:**
1. Ao subir o Flutter, `flutter pub upgrade --major-versions` no app e rodar a suíte inteira (a cifra tem teste próprio).
2. Conferir se o SQLite3MultipleCiphers empacotado ganhou correção de segurança desde a 3.5.2.

**Impact if ignored:** correções do sqlite3mc e do drift ficam de fora.

**Revisit trigger:** próximo upgrade do Flutter.

