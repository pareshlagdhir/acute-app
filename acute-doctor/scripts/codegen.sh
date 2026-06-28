#!/usr/bin/env bash
set -euo pipefail
flutter pub get
dart run build_runner build --delete-conflicting-outputs
