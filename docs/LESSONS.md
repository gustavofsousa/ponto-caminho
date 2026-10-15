# Lessons

## 2026-10-02 — Replanning into the workspace standard + mock data

- **Mock data needs a gate, not a promise.** Mocks live in the real files (so replacing them is
  an in-place edit) and carry `"nota": "mock"`; `validar.py --estrito` turns them into errors.
  Same pattern as the old licensing gate: make the rule mechanical so it doesn't depend on memory.
- **A validator must check the invariant you just broke.** The first Forja mock put point 82 in
  chapter 2 while chapter 1 ran 1–82. The "point inside its chapter range" check was added after
  catching it by hand.
- **Decide encryption with the storage, not later.** Both expo-sqlite (SQLCipher) and drift
  (SQLite3MultipleCiphers) can't encrypt an existing plaintext DB in place — it takes an explicit
  export/migration. So the stack RFD includes a cipher-capable store from v0.1.
- **Two "coleções" is a naming hazard.** The content corpus (`Colecao`) and the user's list
  (`ColecaoPessoal`) share a word; written down as a boundary rule before any code exists.

## 2026-10-02 — Stack decision + v0.1 skeleton

- **YAGNI beat reuse.** I recommended Expo for a hypothetical v3.0 TS web; Gustavo rejected it —
  porting pure logic later costs days, the wrong tool now costs every day. Became a global rule.
- **Dart 3 map patterns are a cheap boundary validator.** `if (json case {'numero': int n, ...})`
  narrows untrusted JSON without a codegen dependency; anything else throws `FormatException`.
- **A contract test over the real `livros/` keeps data and motor from drifting** — unit tests use
  an invented fixture so mock-text changes don't break them.
- **Flutter assets can come through a symlink**, so `livros/` stays the single source. Listing
  files explicitly keeps `validar.py` and the README out of the APK.
- **`rootBundle` in a widget test is real I/O** — load it inside `tester.runAsync`.

## 2026-10-02 — v0.2 "Ler" with full spec-driven + independent verifier

- **Strict analysis pays on day one.** `strict-inference` caught a sort comparator whose
  arguments were silently `dynamic` in code that already "passed".
- **A UX floor test finds real bugs.** The "320 px with big text" check found the
  Anterior/Próximo row overflowing — `OverflowBar` stacks the buttons instead.
- **Exporting a name from a shared package can break the consumer's build.** Moving
  `carregarColecao` into the motor collided with the app's function of the same name; the
  migration moved into the same task so every commit compiles (merge backward).
- **Tests replay scenario shapes, not today's mock values** (spec A13). Swapping mock text for
  the real text won't break behavior tests.
- **The author's own adequacy review missed two weak tests; the independent verifier's mutants
  found them.** A "follows the device" setting tested with one device value can't tell
  following from hard-coding; "any failure" tested with one exception type can't tell a
  catch-all from a narrow catch. Both are now in `.specs/LESSONS.md` as candidates.
- **`TextScaler` multiplies, not replaces.** A small wrapper keeps Android's nonlinear system
  scaling and applies the reader's factor on top.

## 2026-10-03 — v0.3 "Guardar" with full spec-driven + independent verifier

- **Encryption is proven by the bytes, not by the library's word.** `PRAGMA cipher` answers
  `chacha20` even for a plaintext file, and a plaintext file opened with a key can't be read
  either. Only "no stored text, no `SQLite format 3` header in the file" tells encrypted from
  plain — the verifier's probes P9 and P10 caught both false proofs.
- **A SQLite error message is a data leak.** `SqliteException.toString()` prints the statement
  parameters — the reflection text. Registro failures log the error type only (AD-009).
- **The secure store can silently forget.** `flutter_secure_storage` deletes a key it can't
  decrypt (`resetOnError`). The guard that matters: never generate a key when the database
  already exists, or the old file becomes unreadable forever (ADR-002).
- **`sqlite3_flutter_libs` is EOL; encryption is a build hook now.** `hooks: user_defines:
  sqlite3: source: sqlite3mc` bundles SQLite3MultipleCiphers for the APK *and* `flutter test`.
  Flutter 3.41 pins `meta`, which caps `drift_dev` at 2.34.0 and `sqlite3` at 3.5.x (TD-006).
- **drift in widget tests has two traps.** (1) Losing a stream's last listener schedules a
  `Timer.run`; inside the fake clock the test ends with a pending timer and `close()` hangs —
  end each test by dropping the tree and pumping 1 ms (`testWidgetsComRegistro`). (2) A stream
  first listened to inside `runAsync` is cached in the real zone and the screen never updates —
  check the database with `get()`, never `observar()`.
- **`enterText` doesn't rebuild.** A button enabled by the text is still disabled until the next
  `pump()`; tapping it does nothing and the test fails far from the cause.
- **Two `tester.tap` calls are not a double tap.** The second press never reaches the handler;
  call the captured `onPressed` twice before a rebuild (L-005).
- **The author's tests proved the happy path; the verifier's mutants found the must-nots.** Six
  survivors, all closed with tests only: seed a sibling row when a write targets one row (L-006),
  make a later statement fail with an aborting trigger to prove all-or-nothing (L-007), test an
  edge case on every screen that shows saved data (L-008). L-003 is now confirmed.
- **`cmd | tail && git commit` commits on a red gate.** The pipe swallowed the test exit code and
  one commit landed with a failing test (undone with `reset --soft`). Every gate since runs with
  `set -o pipefail`.


## 2026-10-07 — v0.4 Voltar: reading log, home screen, point for now, share

- **A migration test needs the old file, and the old file needs the old schema.** Once the
  table is added, no code path can create "a v0.3 database" anymore. Copy `sqlite_master` from
  the current code *before* touching the schema into a frozen fixture (`test/registro/schema_v1.dart`)
  and assert two things: every old row survives, and the migrated schema equals a fresh one (AD-011).
- **drift does not wrap `onUpgrade` in a transaction.** Wrap it yourself. `user_version` is only
  written after `onUpgrade` returns, so a failing upgrade leaves the file at the old version —
  proven by a test, not assumed.
- **To make `CREATE TABLE IF NOT EXISTS` fail, use an index.** An existing table or view with the
  same name is silently skipped; an index with that name is an error. That is the conflicting
  object the rollback test plants.
- **A test harness can make a test lie.** `montarTela` uses a fixed theme, so changing the
  preferences controller in a test never reached the page. We deleted the "record once per opening"
  guard and the test still passed. Wrap the page in a `Theme` that changes,
  the way `MaterialApp.themeMode` does, and the mutant dies.
- **"Most recent" is insertion order, not the clock.** A phone's clock can go back; an
  `AUTOINCREMENT` id cannot (AD-010).
- **Lazy lists hide what is below the fold.** In a `ListView`, a widget off screen is not built
  until scrolled near; after `scrollUntilVisible`, pump before `hitTestable()`.
- **An `IconButton`'s tooltip is its semantics `tooltip`, not its `label`**, and its 48 dp touch
  target belongs to the `IconButton`, not the 40 dp `Tooltip` box. `containsSemantics` is
  deprecated in Flutter 3.41 — use `isSemantics`.
- **Two expected errors in one widget test become "Multiple exceptions".** When a scenario
  legitimately fails twice (a dropped table breaks both the read and the write), collect
  `FlutterError.onError` reports and assert each one.
- **A plugin's documented build floor is a claim; the APK build is the test.** `share_plus` 13.3.1
  says AGP ≥ 8.12.1; the debug APK builds on 8.11.1, so no Gradle upgrade was made.
- **A rule proven in the motor is not proven in the app.** The motor's window tests were
  exhaustive. Yet two mutants in the home kept every test green: one asked the registro for one
  recent point (M31), one handed them over oldest first (M49). The screen needs its own test of the rule's
  full input: enough points to tell 10 from 9, and an order that only the right end shrinks.
- **An in-memory database is too fast to show a race.** "Quick taps record every point" passed
  even with a guard that dropped readings while a write was in flight, because each write finished
  inside one frame. A drift `QueryInterceptor` that delays every INSERT by 50 ms made the race
  visible (L-015).
- **Test the action after the in-place change, not only before.** The point page swaps its point
  on Próximo; sharing was only tested on the first point, so sharing the initial reference after
  Próximo survived (M36).
- **Relational words in an AC are assertions.** "The reference *below* the label" needs a
  position check; asserting both texts exist let a title/subtitle swap survive (M27).

## 2026-10-08 — v0.1 CI

- **Simulate the runner with a fresh clone, not the dev tree.** The gate was green in the repo and
  red in a clean clone: `dart analyze` doesn't run `pub get`, and the motor's `pubspec.lock` isn't
  committed, so a new checkout has no package config. The clone caught it before the first push.
- **A test that depends on the machine's time zone needs the zone pinned by the gate itself.** The
  whole app suite passed under `TZ=UTC` with `toLocal()` removed; under `America/Sao_Paulo`, 10
  tests failed. Pinning TZ in `tool/check.sh` (not only in the YAML) makes every run catch it — and
  without tzdata the libc silently falls back to UTC, so the script checks the offset took effect.
- **Under `set -e`, an ERR trap doesn't fire when a subshell function fails** (bash 5.2). An EXIT
  trap does, and keeps the exit status — that is what names the failed gate.
- **Keep the CI entry point thin.** The workflow only calls `tool/check.sh <gate>`; the sensor ran
  all six mutants locally against the same script, so no broken commit had to be pushed to a public
  repo to prove the CI goes red.
- **"Public repo" is a product fact, not only a CI detail.** It made Actions free — and it means the
  real text of the three works can never be committed here (roadmap › Riscos).
