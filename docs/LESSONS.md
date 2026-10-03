# Lessons

## 2026-10-02 — Replanning into the workspace standard + mock data

- **Mock data needs a gate, not a promise.** Mocks live in the real files (so replacing them is
  an in-place edit) and carry `"nota": "mock"`; `validar.py --estrito` turns them into errors.
  Same pattern as the old licensing gate: make the rule mechanical so it doesn't depend on memory.
- **A validator should check the invariant you just broke.** The first Forja mock put point 82 in
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

