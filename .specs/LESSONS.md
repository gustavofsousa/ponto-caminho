# LESSONS — auto-maintained by scripts/lessons.py

> Machine-owned. Do NOT hand-edit. Changes are overwritten on the next `lessons.py` write.
> Canonical state lives in `.specs/lessons.json`. Edit lessons only via the script.
> promote_threshold=2 distinct features · window_days=45 · quarantine_threshold=2

## Confirmed (load these at Specify/Design)

Corroborated across multiple features. Safe to apply as guidance.

### L-003 — When an AC's expected outcome lists several observable parts, assert each part, not only the most identifying one.
- signal: `ac_gap` · recurrence: 2 feature(s) · scope: `app` · harmful: 0
- features: ler, guardar
- evidence: apps/ponto_mobile/test/colecao/capitulo_page_test.dart:48-55 (AC-10) (app) (+1 more)
- last seen: 2026-10-02T19:53:06Z

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

### L-008 — When an edge case applies to every screen that renders saved data, test it on each of those screens.
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `app` · harmful: 0
- features: guardar
- evidence: apps/ponto_mobile/lib/registro/colecoes_page.dart:87 (M47, edge case A14) (app)
- last seen: 2026-10-02T19:53:06Z

### L-009 — Define an encryption-is-active outcome by something that differs between an encrypted and a plain file, such as a missing header or a wrong key failing, not by a pragma the library answers either way.
- signal: `spec_precision_gap` · recurrence: 1 feature(s) · scope: `infra` · harmful: 0
- features: guardar
- evidence: AC-01 / apps/ponto_mobile/test/infra/banco_cifrado_test.dart:66-69 (P9) (infra)
- last seen: 2026-10-02T19:53:06Z

## Quarantined (failed when applied — ignore)

A confirmed lesson that recurred alongside failure. Kept for the maintainer to review.

_none_
