# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**acute-app** is a monorepo containing a safety-alert platform for medical practitioners verified for IMA & state councils:

- **acute-doctor/** — Flutter mobile app (Android + iOS), Clean Architecture with Riverpod state management
- **acute-api/** — FastAPI backend server for OTP verification and health checks

## Directory Structure

```
shield/
├── acute-doctor/          # Flutter mobile app (Clean Architecture)
│   ├── lib/
│   │   ├── app/           # MaterialApp & root shell
│   │   ├── core/          # Cross-cutting: config, routing, theme, storage, network
│   │   ├── features/      # Feature modules (splash, auth, home, alerts, profile, etc.)
│   │   └── l10n/          # Localization (ARB files)
│   ├── test/ & integration_test/
│   ├── pubspec.yaml       # Dependencies & build config
│   └── README.md          # Setup & daily-run commands
│
└── acute-api/            # FastAPI backend
    ├── app/
    │   ├── main.py        # FastAPI app entrypoint
    │   ├── api/v1/        # Endpoint routers & handlers
    │   ├── core/          # Config, exceptions, middleware
    │   ├── schemas/       # Pydantic request/response models
    │   └── services/      # Business logic (MSG91Service)
    ├── tests/             # Pytest unit & integration tests
    ├── doc/               # Endpoint documentation (markdown)
    ├── pyproject.toml     # Python deps & build config
    └── .env.example       # Config template
```

## Development Commands

### Flutter Mobile App (acute-doctor/)

**First-time setup:**
```bash
cd acute-doctor
flutter pub get
dart run build_runner build --delete-conflicting-outputs
# See README.md for iOS/Android-specific setup (native folder generation, pods, emulator)
```

**Daily development:**
```bash
flutter run                                 # dev flavor on connected/available device
flutter run -d "iPhone 15 Pro"             # specify device
dart run build_runner watch                # watch for codegen changes (freezed, retrofit, riverpod)
flutter analyze                             # lint & static analysis
flutter test                                # unit + widget tests
flutter test integration_test/              # integration tests
```

**Build & formatting:**
```bash
dart format .
flutter clean && flutter pub get            # clean rebuild when deps break
```

**Flavor-specific runs** (after PLATFORMS.md setup):
```bash
./scripts/run.sh dev        # or staging / prod
# equivalent to:
flutter run --flavor dev -t lib/main_dev.dart
```

### FastAPI Backend (acute-api/)

**Setup:**
```bash
cd acute-api
python -m venv .venv
source .venv/bin/activate     # or .venv\Scripts\activate on Windows
pip install -e ".[dev]"       # editable install with dev deps
cp .env.example .env          # configure MSG91_AUTHKEY and MSG91_OTP_TEMPLATE_ID
```

**Local infrastructure (Postgres + Redis):**
```bash
docker compose up -d            # start Postgres (pgvector) + Redis
docker compose ps               # check health
alembic upgrade head            # apply DB migrations (enables pgvector)
docker compose down             # stop services (add -v to wipe data)
```

**Run server:**
```bash
uvicorn app.main:app --reload --port 8000
# Navigate to http://localhost:8000/docs for interactive API explorer
```

**Tests:**
```bash
pytest                        # all tests
pytest tests/api/v1/         # single directory
pytest -k test_health        # by test name pattern
pytest --cov=app             # with coverage report
```

**Code quality:**
```bash
# Built-in Python linting (no separate flake8/pylint configured yet)
# Rely on FastAPI's OpenAPI docs (/docs) to verify schema correctness
```

## Architecture & Key Patterns

### Flutter (acute-doctor/)

**State Management:** Riverpod 2 with `riverpod_generator` for automatic provider generation  
**Routing:** go_router with RouteGuards for auth state  
**Storage:** Hive for local persistence, flutter_secure_storage for tokens  
**Networking:** Dio + Retrofit with custom Dio interceptors for auth headers  
**Models:** Freezed for immutable classes, json_serializable for serialization  

**Feature module pattern:**
Each feature (auth, home, alerts) has three layers:
- `data/` — repositories, datasources, models (API serialization)
- `domain/` — entities, repository abstractions, use-cases
- `presentation/` — Riverpod controllers/providers, pages, widgets

**Design tokens** (`lib/core/theme/tokens/`) define color, typography, spacing system. Use `AcuteTheme` when building new screens.

### FastAPI (acute-api/)

**API structure:**  
- `app/main.py` — FastAPI instance with routers mounted
- `app/api/v1/router.py` — composes v1 endpoints (health, otp)
- `app/api/v1/endpoints/{feature}.py` — request handlers, HTTP exceptions
- `app/schemas/` — Pydantic models (request/response validation & docs)
- `app/services/` — business logic (e.g., MSG91Service for server-side OTP lifecycle: send, verify, resend via MSG91 v5 REST API)
- `app/core/config.py` — environment settings (use pydantic-settings, loaded from .env)

**Request/response flow:**  
HTTP request → Pydantic validation → endpoint handler → service logic → schema response  
Exceptions bubble to FastAPI's exception handlers (502 for MSG91 outages, 422 for validation).

**OTP flow:**  
`POST /api/v1/otp/send` initiates server-side OTP via MSG91 v5 REST API.  
`POST /api/v1/otp/verify` confirms the OTP, finds-or-creates the doctor, and returns a JWT session (no separate `/auth/login`).  
`POST /api/v1/otp/resend` re-sends via SMS or voice channel.

**Testing setup:**  
- Fixtures in `tests/conftest.py` provide AsyncClient with ASGI transport
- Tests are async; pytest-asyncio handles them with `asyncio_mode = "auto"`
- Use `respx` to mock HTTP calls to upstream (MSG91) in tests

## Important Notes

**Environment variables:**  
- Flutter: `.env` in acute-doctor/ (API base URL, feature flags per flavor)
- Backend: `.env` in acute-api/ (MSG91_AUTHKEY, others)

**Codegen:**  
Both projects require build_runner:
- Flutter: freezed, json_serializable, retrofit_generator, riverpod_generator
- Run `dart run build_runner build` (or watch) after editing annotated classes

**API documentation:**  
- FastAPI auto-generates OpenAPI at `/docs` (Swagger UI)
- Manual docs in `acute-api/doc/v1/` for endpoints — keep these in sync with code
- When adding endpoints, update both code and `doc/v1/*.md`

**Flavor configuration:**  
Three build flavors (dev, staging, prod) defined in native gradle/Xcode configs.  
Entry points: `lib/main_dev.dart`, `lib/main_staging.dart`, `lib/main_prod.dart`  
Until native config is complete, use plain `flutter run` (defaults to dev flavor).

**Mobile testing:**  
- Device/emulator must be running (`flutter devices` to list)
- iOS: Xcode, Signing & Capabilities must be configured (team, bundle ID)
- Android: Android Studio emulator or connected device with USB debugging
