#!/usr/bin/env bash
set -euo pipefail
FLAVOR="${1:-dev}"

ARGS=(--flavor "$FLAVOR" -t "lib/main_${FLAVOR}.dart")

# Pass MSG91 (and other) build-time config when a per-flavor env file exists.
# Without this the OTP widget is never initialised and sendOTP fails.
ENV_FILE="env/${FLAVOR}.json"
if [[ -f "$ENV_FILE" ]]; then
  ARGS+=(--dart-define-from-file="$ENV_FILE")
else
  echo "warning: $ENV_FILE not found; running without --dart-define-from-file" >&2
fi

flutter run "${ARGS[@]}"
