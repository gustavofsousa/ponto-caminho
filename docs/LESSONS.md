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

