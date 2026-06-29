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

## Flutter (acute-doctor) — F1–F12
Baseline: removed stale test/widget_test.dart (template referencing MyApp/acutework). analyze clean, tests green.
Flutter BASE for F1 = HEAD after cleanup.

### Flutter cross-task contract facts (discovered F1 — inject into all later F-tasks)
- PACKAGE NAME is `acutework` (NOT `acute_doctor`). All brief imports `package:acute_doctor/...` must be `package:acutework/...`.
- flutter_riverpod ^3.3.1 (Riverpod 3.x). `StateProvider` is legacy.
- authTokenProvider = NotifierProvider<AuthTokenNotifier,String?>. READ: ref.read(authTokenProvider) -> String?. WRITE: ref.read(authTokenProvider.notifier).token = value.
- secureStorageProvider, dioProvider live in lib/core/network/dio_provider.dart.
Task F1: complete (commits 643e48d..99ad1fb, review clean; adapted to acutework pkg + Riverpod3 NotifierProvider)
  Minor (carry to final): dioProvider doesn't ref.onDispose(dio.close); authTokenProvider round-trip untested.
Task F2: complete (commits 99ad1fb..955078c, approved; Freezed-3.x abstract classes; generated files untracked per .gitignore convention)
  Minor (carry to final): Experience (nested Hospital+WorkingHour) deserialization not exercised in model test.
Task F3: complete (commits 955078c..fb66d3e, approved after fix; made addExperience isCurrent nullable bool? in both abstract+impl, coerce ?? false in body. NOTE: reviewer's literal "=false on abstract" fix was illegal Dart; used nullable instead.)
  Minor (carry to final): repo test lacks registerFallbackValue(<String,dynamic>{}) for future map-arg stubs.
Task F4: complete (commits fb66d3e..cdc6267, approved after fix; rewired auth->backend login exchange, AuthState plain class +onboardingNeeded, token write via .token setter, removed otp-verified marker + dup secureStorageProvider. _exchange refactored to sync-fold-then-await.)
  Minor (carry to final): AuthController.verifyOtp/_exchange (writeAuthToken + notifier set + onboardingNeeded) has no direct controller test; only DTO/repo-level test.
Task F5: complete (commits cdc6267..03f33ca, approved; 5 onboarding routes (placeholders), redirect guard, splash token bootstrap via .token setter, otp routes by onboardingNeeded. 8/8.)
  Minor (carry to final): authTokenProvider lives in dio_provider.dart (naming smell); duplicated route-constant test; guard doesn't bounce authed user off /login.
Task F6: complete (commits 03f33ca..aa486e1, approved; profileControllerProvider AsyncNotifier + OnboardingHubPage wired to profileSetup route, Icons.medical_services_outlined for speciality. 9/9.)
  Minor (carry to final): _SectionTile.onTap typed VoidCallback while caller is async lambda (no runtime risk); error UI shows raw exception toString.
Task F7: complete (commits aa486e1..bb4a241, approved; PersonalInfoPage with _seeded guard, mounted checks, route rewired. 11/11.)
  Minor (carry to final): profile-load error arm shows raw e.toString().
Task F8: complete (commits bb4a241..826e2af, approved after fix; EducationPage + reusable CatalogPicker, route rewired. Fixes: picker submit-on-blur (also helps F9), mounted guard in delete (ConsumerStatefulWidget), _saving reset on refresh failure. 12/12.)
  Minor (carry to final): no add-form/custom-entry widget test; CatalogPicker search has no debounce/out-of-order-cancel.
Task F9: complete (commits 826e2af..a69d744, approved after fix; SpecialityPage reusing CatalogPicker, route rewired. Fix: extract-then-await outside dartz fold in add/delete. 13/13.)
  NOTE: dartz fold+async-lambda hazard recurs across section pages. F8 education_page likely still has it -> FLAG for final-review sweep. F10/F11 told to use extract-then-await from the start.
Task F10: complete (commits a69d744..eea222a, approved after fix; ExperiencePage + HospitalSearchField (search/add-new), dates yyyy-MM-dd, extract-then-await mutations, route rewired. Fix: dropped transitive intl, local date formatter. 14/14.)
Task F11: complete (commits eea222a..ca2bd7d, approved after fix; WorkingHoursPage per-experience day-grouped slots, HH:mm:ss, end>start validation, empty-state, route rewired. Fix: surface delete errors via snackbar, fix add-slot refresh/pop ordering. 15/15.)
Task F12: complete (verification only, no commit needed — generated files untracked). build_runner clean (0 outputs changed), flutter analyze clean, 15/15 tests pass.

ALL 12 FLUTTER TASKS COMPLETE.

### IMPORTANT recovery (post-final-review)
- Discovered F4 commit 9d58569 OMITTED 3 auth files (msg91_otp_service, otp_repository_impl, otp_repository); their verifyOtp->access-token changes were left uncommitted. Committed branch didn't compile (auth_providers used new API, committed repo had old Unit signature). Tests always passed because on-disk files were correct. Reviews missed it because reviewers opened the working-tree files.
- The final-review fix subagent ran in an ISOLATED WORKTREE (agent-afd12b0d957d4ed52); its commits were stranded off-branch.
- RECOVERY: committed stranded auth files (d79839d); cherry-picked final-review code fixes (2625f49); removed worktree + branch; verified COMMITTED state: working tree clean vs HEAD, analyze clean, 16/16 tests green.

FLUTTER COMPLETE & MERGE-READY. feat/doctor-onboarding HEAD = 2625f49.
Deferred (documented, non-blocking): login redirect doesn't bounce authed user; dioProvider no dispose; authTokenProvider lives in dio_provider.dart (layering); CatalogPicker/HospitalSearchField no debounce/out-of-order-cancel; section error arms show raw Exception toString; thin mutation-flow widget coverage.
