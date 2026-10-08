#!/usr/bin/env bash
# The quality gate — the same one CI runs (.github/workflows/ci.yml), one gate per CI step.
# Usage: tool/check.sh [livros|motor|app|codegen]   (no argument: all four, in this order)
set -euo pipefail

gates=(livros motor app codegen)

cd "$(dirname "$0")/.."

# INVARIANT: tests run outside UTC — the reflection date test only catches a missing toLocal() off
# UTC, and CI runners are UTC. Without tzdata the libc silently falls back to UTC, hence the check.
export TZ=America/Sao_Paulo
if [[ "$(date +%z)" == "+0000" ]]; then
  echo "check: TZ=$TZ did not take effect (is tzdata installed?)" >&2
  exit 1
fi

check_livros() (
  python3 livros/validar.py
  python3 -m unittest discover -s livros -p 'test_*.py'
)

check_motor() (
  cd packages/ponto_motor
  dart pub get
  dart analyze --fatal-infos
  dart test
)

check_app() (
  cd apps/ponto_mobile
  flutter pub get
  flutter analyze --fatal-infos
  flutter test
)

# Regenerates drift code and fails if that changed any *.g.dart — compared with the tree as it was,
# not with HEAD, so uncommitted work elsewhere doesn't trip it. The regenerated file stays, ready to commit.
check_codegen() (
  cd apps/ponto_mobile
  before="$(generated_checksums)"
  dart run build_runner build
  after="$(generated_checksums)"
  if [[ "$before" != "$after" ]]; then
    echo "check: generated code was out of date — commit the regenerated files:" >&2
    git status --short -- '*.g.dart' >&2
    git --no-pager diff -- '*.g.dart' >&2
    exit 1
  fi
)

generated_checksums() {
  find lib -name '*.g.dart' -print0 | sort -z | xargs -0 --no-run-if-empty sha256sum
}

if [[ $# -gt 1 ]]; then
  echo "usage: tool/check.sh [gate] — gates: ${gates[*]}" >&2
  exit 2
fi

selected=("${gates[@]}")
if [[ $# -eq 1 ]]; then
  if [[ " ${gates[*]} " != *" $1 "* ]]; then
    echo "check: unknown gate '$1' — valid gates: ${gates[*]}" >&2
    exit 2
  fi
  selected=("$1")
fi

# An ERR trap wouldn't fire here: a gate failing inside its subshell under set -e skips it (bash 5.2).
gate=""
trap 'status=$?; if (( status != 0 )) && [[ -n "$gate" ]]; then echo "== check: $gate FAILED" >&2; fi' EXIT
for gate in "${selected[@]}"; do
  echo "== check: $gate"
  "check_$gate"
done
gate=""
echo "== check: passed (${selected[*]})"
