# LESSONS — auto-maintained by scripts/lessons.py

> Machine-owned. Do NOT hand-edit. Changes are overwritten on the next `lessons.py` write.
> Canonical state lives in `.specs/lessons.json`. Edit lessons only via the script.
> promote_threshold=2 distinct features · window_days=45 · quarantine_threshold=2

## Confirmed (load these at Specify/Design)

Corroborated across multiple features. Safe to apply as guidance.

_none_

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

### L-003 — When an AC's expected outcome lists several observable parts, assert each part, not only the most identifying one.
- signal: `ac_gap` · recurrence: 1 feature(s) · scope: `app` · harmful: 0
- features: ler
- evidence: apps/ponto_mobile/test/colecao/capitulo_page_test.dart:48-55 (AC-10) (app)
- last seen: 2026-10-02T17:33:00Z

### L-004 — When an AC requires an error to name an entity, specify what the error cites when the entity's own identifier is the malformed field.
- signal: `spec_precision_gap` · recurrence: 1 feature(s) · scope: `motor` · harmful: 0
- features: ler
- evidence: AC-01 / packages/ponto_motor/test/colecao/ler_colecao_test.dart:57 (motor)
- last seen: 2026-10-02T17:33:00Z

## Quarantined (failed when applied — ignore)

A confirmed lesson that recurred alongside failure. Kept for the maintainer to review.

_none_
