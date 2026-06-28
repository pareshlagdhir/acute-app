# Doctor Onboarding — Design Spec

- **Date:** 2026-06-28
- **Status:** Approved (pending implementation plan)
- **Scope:** Backend (`acute-api`) + Flutter (`acute-doctor`)

## Summary

Implement doctor onboarding for Shield. A doctor logs in with a mobile number
(MSG91 OTP). The backend issues a real session and reports whether onboarding is
needed. Existing/registered doctors land on the dashboard; new or incomplete
doctors enter a skippable, section-by-section onboarding hub that shows a profile
completion percentage. Onboarding captures personal information, education
(one or more, each with a registration number), specialities (one or more),
experience (associations with hospitals/clinics drawn from a shared master that
doctors can extend), and working hours per hospital.

All onboarding steps are optional. A doctor record is created on first successful
login, which alone counts as "registered" (so the dashboard is always reachable);
the completion percentage communicates remaining work and onboarding is resumable
from the profile at any time.

## Decisions (from brainstorming)

- **Deliverable:** Backend APIs and Flutter UI, full vertical slice.
- **Auth/session:** Backend issues a JWT and looks up the doctor by phone after
  MSG91 OTP verification.
- **"Registered":** Any doctor record exists → dashboard. First login creates the
  record. Onboarding remains resumable.
- **Hospitals/clinics:** Shared master list, searchable, doctors may add new ones
  that become available to everyone.
- **Degrees & specialities:** Predefined seeded lists, searchable, with the option
  to add a custom value.
- **Completion %:** Five sections, equal weight (20% each).
- **Onboarding flow:** Hub checklist with per-section forms; every section is
  skippable and resumable.
- **Working hours:** Per day-of-week, one or more time slots per day, per hospital.

### Assumed defaults (in scope unless changed)

- Personal info = `first_name`, `middle_name` (optional), `last_name`, `email`
  (optional). No date of birth, gender, or photo.
- A single long-lived JWT access token. No refresh-token endpoint in this scope.
- The IMA / state-council "verified" flag is out of scope here and does not gate
  the dashboard.

## Architecture choice

**Approach A — Resource-oriented REST.** One aggregate read (`GET /doctors/me`)
returning the doctor, all sub-collections, and the computed completion percentage,
plus dedicated CRUD endpoints per sub-resource. Chosen over a single aggregate
`PUT` document (awkward partial saves, clobbering) and GraphQL (not in stack).
It maps one-to-one to the hub sections and "add one or more" lists and fits the
existing Clean Architecture repository pattern.

## Backend data model (SQLAlchemy + Alembic)

All tables use UUID primary keys and `created_at` / `updated_at` timestamps, under
`Base.metadata`, in a single new Alembic revision.

- **`doctors`** — `id`, `mobile` (unique, E.164), `first_name`, `middle_name`
  (nullable), `last_name`, `email` (nullable). One row per phone number.
- **`degree_catalog`** — seeded reference list (MBBS, MD, MS, DM, DNB, …).
- **`speciality_catalog`** — seeded reference list (Cardiology, …).
- **`doctor_educations`** — `doctor_id` FK, `degree` (string; from catalog or
  custom), `registration_number`, `institution` (nullable),
  `year_of_completion` (nullable). Many per doctor.
- **`doctor_specialities`** — `doctor_id` FK, `name` (catalog or custom). Many per
  doctor.
- **`hospitals`** — shared master: `id`, `name`, `type` (`hospital` | `clinic`),
  `city` (nullable), `address` (nullable), `created_by` (doctor id, nullable for
  seeded rows). Searchable by name; any doctor may add one.
- **`doctor_experiences`** — `doctor_id` FK, `hospital_id` FK, `designation`
  (nullable), `start_date` (nullable), `end_date` (nullable), `is_current`
  (bool). The doctor↔hospital association.
- **`working_hours`** — `experience_id` FK, `day_of_week` (0–6), `start_time`,
  `end_time`. Multiple slots per day allowed (split shifts).

Seed data for `degree_catalog` and `speciality_catalog` ships in the migration.

## Auth / session

- **`POST /api/v1/auth/login`** — body `{ access_token }`, the MSG91 widget access
  token obtained on-device after a successful in-app `verifyOTP`. The backend
  validates it via the existing `MSG91Service.verify_otp_token`, resolving the
  mobile. Invalid token → `401`. Upserts the doctor by mobile, signs a JWT
  (`JWT_SECRET` from `.env`, long-lived), and returns:
  `{ token, token_type, is_new, onboarding_needed, profile_completion }`.
  `onboarding_needed` is true when `profile_completion < 100`.
- **`get_current_doctor`** dependency decodes the `Bearer` JWT, loads the doctor,
  guards every `/doctors/me/*` route, and enforces ownership of sub-resources
  (`404` when a record's `doctor_id` does not match).

## API endpoints

```
POST   /api/v1/auth/login

GET    /api/v1/catalog/degrees?q=
GET    /api/v1/catalog/specialities?q=

GET    /api/v1/hospitals?q=                 # search shared master
POST   /api/v1/hospitals                    # add new (shared for everyone)

GET    /api/v1/doctors/me                   # doctor + sub-collections + completion
PATCH  /api/v1/doctors/me                   # personal info (names, email)

POST   /api/v1/doctors/me/educations
PATCH  /api/v1/doctors/me/educations/{id}
DELETE /api/v1/doctors/me/educations/{id}

POST   /api/v1/doctors/me/specialities
DELETE /api/v1/doctors/me/specialities/{id}

POST   /api/v1/doctors/me/experiences
PATCH  /api/v1/doctors/me/experiences/{id}
DELETE /api/v1/doctors/me/experiences/{id}

GET    /api/v1/doctors/me/experiences/{id}/working-hours
POST   /api/v1/doctors/me/experiences/{id}/working-hours
DELETE /api/v1/doctors/me/experiences/{id}/working-hours/{wid}
```

## Completion percentage (server-computed)

Returned by `GET /doctors/me` as `profile_completion` (0–100) plus a per-section
breakdown. Five sections, 20% each:

- **personal** — `first_name` and `last_name` both present.
- **education** — at least one education entry.
- **speciality** — at least one speciality.
- **experience** — at least one experience.
- **working_hours** — at least one working-hours slot.

## Flutter

- **Login flow update:** after MSG91 widget `verifyOTP` succeeds, capture its
  access token, call `POST /auth/login`, store the returned JWT in
  `flutter_secure_storage` (replacing the `otp-verified:` marker), then route by
  `onboarding_needed`.
- **`profile_setup` feature** becomes the onboarding hub: a completion bar plus
  five section tiles (done/incomplete), each opening its own form page. Every
  section is skippable and a "Continue to dashboard" action is always available.
  The `profile` feature reuses the same controllers/repositories for later edits.
- **Layers:** `data` (Dio + Retrofit `DoctorApi`; models via freezed /
  json_serializable), `domain` (entities, repository abstractions),
  `presentation` (riverpod_generator controllers, pages).
- A Dio interceptor attaches the JWT; a go_router guard redirects to login when no
  valid token exists.

## Error handling

- Backend: `401` invalid/missing token, `422` validation, `404` for sub-resources
  not owned by the caller, `502` MSG91 outage (existing handler).
- Flutter: maps these to the existing `Failure` types with inline messages;
  offline maps to `NetworkFailure`.

## Testing & docs

- **Backend:** TDD via the `craft-api` workflow — pytest + `respx` (mock MSG91) +
  async client. Cover login (new vs existing vs invalid token), every CRUD path,
  completion computation, and auth/ownership guards. Update `acute-api/doc/v1/*.md`
  per endpoint.
- **Flutter:** unit tests for repositories/controllers (completion mapping, login
  routing) and widget tests for the hub and one form.
- **Security:** JWT secret and MSG91 keys live only in `.env` and are never logged
  or echoed.

## Out of scope

- Refresh-token rotation / token revocation.
- IMA / state-council verification workflow and the `verified` gate.
- Profile photo, demographics beyond names and email.
- Editing or moderating the shared hospital master beyond create + search.
