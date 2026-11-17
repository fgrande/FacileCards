#!/usr/bin/env bash
# Analisi, prove e avvio dell'app. Si ferma al primo errore.
# Uso: ./frun.sh [opzioni di flutter run, per esempio -d emulator-5554]
set -euo pipefail

cd "$(dirname "$0")/app"

echo "==> flutter analyze"
flutter analyze

echo "==> flutter test"
flutter test

echo "==> flutter run $*"
flutter run "$@"
