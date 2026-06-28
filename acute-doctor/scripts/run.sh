#!/usr/bin/env bash
set -euo pipefail
FLAVOR="${1:-dev}"
flutter run --flavor "$FLAVOR" -t "lib/main_${FLAVOR}.dart"
