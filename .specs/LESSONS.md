# LESSONS — auto-maintained by scripts/lessons.py

> Machine-owned. Do NOT hand-edit. Changes are overwritten on the next `lessons.py` write.
> Canonical state lives in `.specs/lessons.json`. Edit lessons only via the script.
> promote_threshold=2 distinct features · window_days=45 · quarantine_threshold=2

## Confirmed (load these at Specify/Design)

Corroborated across multiple features. Safe to apply as guidance.

### L-003 — When an AC's expected outcome lists several observable parts, assert each part, not only the most identifying one.
- signal: `ac_gap` · recurrence: 2 feature(s) · scope: `app` · harmful: 1
- features: ler, guardar
- evidence: apps/ponto_mobile/test/colecao/capitulo_page_test.dart:48-55 (AC-10) (app) (+1 more)
- last seen: 2026-10-07T17:54:08Z

### L-008 — When an edge case applies to every screen that renders saved data, test it on each of those screens.
- signal: `surviving_mutant` · recurrence: 2 feature(s) · scope: `app` · harmful: 0
- features: guardar, voltar
- evidence: apps/ponto_mobile/lib/registro/colecoes_page.dart:87 (M47, edge case A14) (app) (+1 more)
- last seen: 2026-10-07T17:54:08Z

## Candidates (under observation — do NOT load as guidance yet)

Seen once or not yet corroborated. Tracked, not trusted.

### L-001 — When the spec says any failure maps to one outcome, test at least one failure type besides the domain exception, such as the platform I/O error.
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `app` · harmful: 0
- features: ler
- evidence: apps/ponto_mobile/lib/app.dart:37 (M12, AC-05) (app)
- last seen: 2026-10-02T17:33:00Z

### L-002 — Test a setting that follows the device under every device value, because a single value cannot tell following apart from hard-coding.
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `app` · harmful: 0
- features: ler
- evidence: apps/ponto_mobile/lib/preferencias/preferencias.dart:4 (M13, AC-15) (app)
- last seen: 2026-10-02T17:33:00Z

### L-004 — When an AC requires an error to name an entity, specify what the error cites when the entity's own identifier is the malformed field.
- signal: `spec_precision_gap` · recurrence: 1 feature(s) · scope: `motor` · harmful: 0
- features: ler
- evidence: AC-01 / packages/ponto_motor/test/colecao/ler_colecao_test.dart:57 (motor)
- last seen: 2026-10-02T17:33:00Z

### L-005 — Prove a duplicate-press guard by invoking the button callback twice before a rebuild, because consecutive tester.tap calls do not deliver the second press.
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `app` · harmful: 0
- features: guardar
- evidence: apps/ponto_mobile/lib/registro/editor_de_reflexao_page.dart:171 (M38, AC-06) (app)
- last seen: 2026-10-02T19:53:06Z

### L-006 — When a write targets one row, seed a sibling row and assert it stays untouched.
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `app` · harmful: 0
- features: guardar
- evidence: apps/ponto_mobile/lib/registro/reflexoes_repositorio.dart:55 (M22, AC-09) (app) (+1 more)
- last seen: 2026-10-02T19:53:06Z

### L-007 — To prove an all-or-nothing write, make a later statement fail, for example with an aborting SQLite trigger, and assert nothing persisted.
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `app` · harmful: 0
- features: guardar
- evidence: apps/ponto_mobile/lib/registro/colecoes_repositorio.dart:32-37 (M29, AC-16) (app) (+1 more)
- last seen: 2026-10-02T19:53:06Z

### L-009 — Define an encryption-is-active outcome by something that differs between an encrypted and a plain file, such as a missing header or a wrong key failing, not by a pragma the library answers either way.
- signal: `spec_precision_gap` · recurrence: 1 feature(s) · scope: `infra` · harmful: 0
- features: guardar
- evidence: AC-01 / apps/ponto_mobile/test/infra/banco_cifrado_test.dart:66-69 (P9) (infra)
- last seen: 2026-10-02T19:53:06Z

### L-010 — When the engine owns a rule, add one app-level test with enough data to prove the app passes the engine the rule's full input, such as the query limit.
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `app` · harmful: 0
- features: voltar
- evidence: apps/ponto_mobile/lib/selecao/um_ponto_para_agora.dart:94 (M31, AC-16) (app) (+1 more)
- last seen: 2026-10-07T18:17:23Z

### L-011 — When a page changes the shown item in place, test each action that depends on the shown item after a change, not only on first open.
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `app` · harmful: 0
- features: voltar
- evidence: apps/ponto_mobile/lib/colecao/ponto_page.dart:64 (M36, AC-24) (app)
- last seen: 2026-10-07T17:54:07Z

### L-012 — Assert relational words in an expected outcome, such as below or before, by comparing on-screen positions.
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `app` · harmful: 0
- features: voltar
- evidence: apps/ponto_mobile/lib/leitura/continue_de_onde_parou.dart:56-58 (M27, AC-09) (app)
- last seen: 2026-10-07T17:54:08Z

### L-013 — Drive time-zone conversion code with a local, non-UTC clock in at least one test, because a UTC test clock hides the conversion.
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `app` · harmful: 0
- features: voltar
- evidence: apps/ponto_mobile/lib/leitura/leituras_repositorio.dart:23 (M14, AC-01) (app)
- last seen: 2026-10-07T17:54:08Z

### L-014 — When an edge case says an action repeats quickly, drive it without settling between actions.
- signal: `ac_gap` · recurrence: 1 feature(s) · scope: `app` · harmful: 0
- features: voltar
- evidence: apps/ponto_mobile/test/leitura/leitura_na_pagina_test.dart:133-134 (edge case 5) (app)
- last seen: 2026-10-07T17:54:08Z

### L-015 — To prove writes keep pace with quick actions, slow each write in the test, for example with a delaying query interceptor, because an in-memory database finishes before the next frame.
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `app` · harmful: 0
- features: voltar
- evidence: apps/ponto_mobile/lib/colecao/ponto_page.dart:114-117 (M45, edge case 5, round 1) (app)
- last seen: 2026-10-07T18:17:23Z

### L-016 — Test a count window at its exact edge from both sides, because data smaller than the window lets any nearby cap pass.
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `app` · harmful: 0
- features: voltar
- evidence: apps/ponto_mobile/lib/leitura/continue_de_onde_parou.dart:37 (M64/M64b/M64c, A12/AC-13, round 2) (app)
- last seen: 2026-10-07T18:36:40Z

### L-017 — When a check regenerates files in place, the AC states whether green means the working tree or the committed state.
- signal: `spec_precision_gap` · recurrence: 1 feature(s) · scope: `ci` · harmful: 0
- features: ci
- evidence: CI-05 (validation.md gap 2) (ci)
- last seen: 2026-10-08T15:46:02Z

### L-018 — Name each gate or component with one identifier across ACs, step names and scripts.
- signal: `spec_precision_gap` · recurrence: 1 feature(s) · scope: `specs` · harmful: 0
- features: ci
- evidence: CI-02 (validation.md gap 3) (specs)
- last seen: 2026-10-08T15:46:02Z

## Quarantined (failed when applied — ignore)

A confirmed lesson that recurred alongside failure. Kept for the maintainer to review.

_none_
