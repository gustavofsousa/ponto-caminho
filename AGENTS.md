# AGENTS.md — Ponto do Caminho

> Project constitution. Loaded on top of the global `AGENTS.md`; where they differ, this file wins
> for this repo. Keep it short — detail lives in `docs/`.

## Constitution

```yaml
type: enxuto              # small and solid, straight to the store; named by the owner on 2026-10-14
open-source: false
rigor:                      # off | designed | enforced; types, defaults and events: _hq/ia/catalogs/project-types.md
  auth: designed
  privacy: designed
  tests: enforced
  ci: designed
  observability: designed
  scale: designed
```

- **Promotion is an event the owner names.** Never change `type` or raise an axis on your own.
  Types, defaults and events: `_hq/ia/catalogs/project-types.md`.
- **v1.0 gate.** One real reader uses the app for two weeks
  without asking for anything missing. Anything that doesn't serve that goes to `docs/backlog.md`.
- **Mobile-first, local-first.** v1.0 has no account, no server, no sync, no notifications.
- **Language.** Docs and UI copy: PT-BR (audience is Brazil only). Code structure, verbs, types,
  commits: EN. Domain nouns stay PT without accents — `ponto`, `obra`, `capitulo`, `colecao`,
  `anotacao`, `favorito` — never translated (`ponto` is not `Point`/`Quote`).
- **Stack: Flutter + Dart** (`docs/adr/001-stack-mobile-flutter.md`). `packages/ponto_motor` is
  pure Dart — no Flutter, no I/O; `apps/ponto_mobile` only orchestrates screens and does I/O.
  `apps/ponto_mobile/assets/livros` is a symlink to `livros/` — never copy the data.

## Map

| Question | Owner |
| --- | --- |
| What order do we build in? | `docs/roadmap.md` |
| Which domains exist, where does code go? | `docs/dominios.md` |
| What can each domain become? | `docs/backlog.md` |
| Fields, operations, UI vocabulary | `docs/modelo.md` |
| Pitch, audience, metrics | `docs/onepager.md` |
| Every visible string | `docs/tom-de-voz.md` |
| Original intent (verbatim, never edit) | `docs/mensagem-inicial.md` |
| Why it's built this way | `docs/adr/`, `.specs/STATE.md` (AD-NNN) |
| Feature specs, verification, debt | `.specs/features/`, `.specs/TECH-DEBT.md` |
| Content data + its rules | `livros/README.md` |

One fact, one owner — other docs link, they don't copy.

## Commands

```bash
tool/check.sh                        # the whole gate, as CI runs it: livros, motor, app, codegen
tool/check.sh app                    # one gate; it pins TZ=America/Sao_Paulo itself
python3 livros/validar.py            # dev: mock data is a warning
python3 livros/validar.py --estrito  # release: mock data is an error
python3 -m unittest discover -s livros -p 'test_*.py'
(cd packages/ponto_motor && dart analyze --fatal-infos && dart test)
(cd apps/ponto_mobile && flutter analyze --fatal-infos && flutter test)
(cd apps/ponto_mobile && dart run build_runner build)  # after editing lib/registro/banco_registro.dart; commit the .g.dart
(cd apps/ponto_mobile && flutter run)       # with an Android phone on adb
```

## Done means

- `tool/check.sh` exits 0 — the same gate CI runs on every push.
- `validar.py` exits 0 after any change under `livros/`.
- Any content change bumps that file's `versaoDados`.
- After a feature lands: reconcile `roadmap.md` status, `backlog.md` bands, `dominios.md` rows.
- Append what you learned to `docs/LESSONS.md`.

## Rules that must not drift

- **Mock is never published.** Every invented point/chapter carries `"nota": "mock"`; a release
  build requires `--estrito` green.
- **The engine doesn't know São Josemaría.** No work id (`caminho`, `sulco`, `forja`) outside
  `livros/` and tests.
- **User data anchors on `PontoId`** (`ponto:<colecao>/<obra>/<numero>`), never on position.
- **Reflections are sensitive religious personal data:** encrypted at rest, never in telemetry
  or logs (log the error type only — AD-009), never read by AI, never attached to a shared
  collection. A new database key only for a new database (ADR-002).
- **No guilt mechanics:** no streaks, badges, rankings, "you've been away" copy.
- **AI only finds the author's text.** It never explains, paraphrases or advises.

## Ask before

Changing the stack, adding any server/network call, adding telemetry, or touching
`docs/mensagem-inicial.md`.
