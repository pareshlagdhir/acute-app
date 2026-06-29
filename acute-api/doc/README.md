# Shield API — Endpoint Index

| Version | Method | Path                                                               | Description                                        | Doc                              |
|---------|--------|--------------------------------------------------------------------|----------------------------------------------------|----------------------------------|
| v1      | GET    | `/api/v1/health`                                                   | Liveness check                                     | [health.md](v1/health.md)        |
| v1      | POST   | `/api/v1/otp/verify`                                               | Verify MSG91 OTP widget token                      | [otp.md](v1/otp.md)              |
| v1      | POST   | `/api/v1/auth/login`                                               | Exchange MSG91 token for a session JWT             | [auth.md](v1/auth.md)            |
| v1      | GET    | `/api/v1/doctors/me`                                               | Current doctor profile + completion                | [doctors.md](v1/doctors.md)      |
| v1      | PATCH  | `/api/v1/doctors/me`                                               | Update doctor personal information                 | [doctors.md](v1/doctors.md)      |
| v1      | POST   | `/api/v1/doctors/me/educations`                                    | Add education record                               | [doctors.md](v1/doctors.md)      |
| v1      | PATCH  | `/api/v1/doctors/me/educations/{edu_id}`                           | Update education record                            | [doctors.md](v1/doctors.md)      |
| v1      | DELETE | `/api/v1/doctors/me/educations/{edu_id}`                           | Delete education record                            | [doctors.md](v1/doctors.md)      |
| v1      | POST   | `/api/v1/doctors/me/specialities`                                  | Add speciality                                     | [doctors.md](v1/doctors.md)      |
| v1      | DELETE | `/api/v1/doctors/me/specialities/{spec_id}`                        | Delete speciality                                  | [doctors.md](v1/doctors.md)      |
| v1      | POST   | `/api/v1/doctors/me/experiences`                                   | Add work experience                                | [doctors.md](v1/doctors.md)      |
| v1      | PATCH  | `/api/v1/doctors/me/experiences/{exp_id}`                          | Update work experience                             | [doctors.md](v1/doctors.md)      |
| v1      | DELETE | `/api/v1/doctors/me/experiences/{exp_id}`                          | Delete work experience                             | [doctors.md](v1/doctors.md)      |
| v1      | GET    | `/api/v1/doctors/me/experiences/{exp_id}/working-hours`            | List working-hour slots for an experience          | [doctors.md](v1/doctors.md)      |
| v1      | POST   | `/api/v1/doctors/me/experiences/{exp_id}/working-hours`            | Add working-hour slot                              | [doctors.md](v1/doctors.md)      |
| v1      | DELETE | `/api/v1/doctors/me/experiences/{exp_id}/working-hours/{wid}`      | Delete working-hour slot                           | [doctors.md](v1/doctors.md)      |
| v1      | GET    | `/api/v1/hospitals`                                                | Search shared hospital/clinic master               | [hospitals.md](v1/hospitals.md)  |
| v1      | POST   | `/api/v1/hospitals`                                                | Add hospital/clinic to shared master               | [hospitals.md](v1/hospitals.md)  |
| v1      | GET    | `/api/v1/catalog/degrees`                                          | Search degree catalog (public)                     | [catalog.md](v1/catalog.md)      |
| v1      | GET    | `/api/v1/catalog/specialities`                                     | Search speciality catalog (public)                 | [catalog.md](v1/catalog.md)      |
