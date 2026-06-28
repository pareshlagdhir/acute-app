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
