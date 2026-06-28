# Doctor Onboarding — Backend Progress Ledger

Branch: feat/doctor-onboarding
Plan: docs/superpowers/plans/2026-06-28-doctor-onboarding-backend.md
Baseline commit (BASE for B1): 1279966

Task B1: complete (commits 616ac62..8579a05, review clean)
Task B2: complete (commits 8579a05..dd5a0de, approved; Important fix applied: explicit Uuid on Hospital.created_by)
  Minor (carry to final review): conftest engine.dispose not in try/finally; client fixture AsyncGenerator annotation (from brief); test_models.py minimal coverage (spec-scoped).
Task B3: complete (commits dd5a0de..89ef98c, review clean)
Task B4: complete (commits 89ef98c..30daa7f, approved; Important fix applied: explicit-dict serialize, no __dict__)
  Minor (carry to final): PATCH /doctors/me has no dedicated test; ExperienceOut.hospital non-optional (hospital_id is NOT NULL in model, so low risk).
Task B5: complete (commits 30daa7f..2d023ff, approved; 2 minors fixed: opaque 502 detail, long JWT secret in tests -> output pristine)
Task B6: complete (commits 2d023ff..a3e8155, review clean)
Task B7: complete (commits a3e8155..5c3de1b, review clean)
Task B8: complete (commits 5c3de1b..96462fe, approved after fix; reverted per-request db.refresh, fixed test session to expire_on_commit=True + expunge in make_doctor)
Task B9: complete (commits 96462fe..b340529, review clean)
  Minor (carry to final): specialities ownership-404 guard exists but has no dedicated test (brief had only one test).
Task B10: complete (commits b340529..fd6329b, approved; added PATCH-unknown-hospital 422 test)
  Minor (carry to final): 422 errors use plain HTTPException body shape (plan-mandated) rather than FastAPI RequestValidationError shape.
Task B11: complete (commits fd6329b..fda0a53, approved; added day_of_week range + cross-doctor 404 tests; full suite 40/40)
Task B12: complete (commit fda0a53..a390219, approved; docs verified accurate vs code)
  Minor (carry to final): doctors.md could note embedded hospital omits address; catalog.md could state no-q behavior.

ALL 12 BACKEND TASKS COMPLETE.

## Final-review fixes (2026-06-28)

Applied a set of post-review corrections to the migration and test suite:

- **Migration 0002**: Added all missing FK indexes (`ix_doctor_educations_doctor_id`, `ix_doctor_specialities_doctor_id`, `ix_doctor_experiences_doctor_id`, `ix_doctor_experiences_hospital_id`, `ix_working_hours_experience_id`) and replaced implicit Postgres unique constraints on `degree_catalog.name`, `speciality_catalog.name`, and `doctors.mobile` with explicit named unique indexes. Also corrected `doctors.created_at` / `updated_at` to `NOT NULL`.
- **test_doctors_me.py**: Added `test_patch_me_updates_personal_info` covering PATCH /doctors/me with first_name, last_name, email; asserts 200, correct values, `sections.personal=True`, `profile_completion=20`.
- **test_working_hours.py**: Added `test_delete_experience_cascades_working_hours` verifying that deleting an experience causes its working-hours to be gone (GET returns 404).
- Postgres autogenerate drift-check was run and confirmed clean (generated file contained only `pass`).
- Full suite: 42 passed, 0 warnings.
