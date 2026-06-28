# Doctors API

**Version:** v1  
**Base path:** `/api/v1`

All endpoints in this document require authentication via `Authorization: Bearer <token>`.  
Obtain a token from `POST /auth/login` — see [auth.md](auth.md).

---

## Overview

The doctors namespace exposes the authenticated doctor's own profile (personal info, educations, specialities, and work experiences with working hours). All sub-resources are scoped to the authenticated doctor — a doctor can only read and modify their own data.

### Profile Completion Model

`profile_completion` is an integer from 0 to 100 representing how many of the five onboarding sections are complete. Each section contributes 20 points.

| Section Key     | Condition for completion                                        |
|-----------------|-----------------------------------------------------------------|
| `personal`      | Both `first_name` and `last_name` are set                       |
| `education`     | At least one education record exists                            |
| `speciality`    | At least one speciality record exists                           |
| `experience`    | At least one experience record exists                           |
| `working_hours` | At least one experience has at least one working-hour slot      |

The `sections` map in `GET /doctors/me` returns the boolean state of each section.

---

## Endpoints

### GET /doctors/me

Returns the authenticated doctor's full profile including completion status.

```
GET /api/v1/doctors/me
Authorization: Bearer <token>
```

#### Response — 200 OK

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "mobile": "919876543210",
  "first_name": "Ananya",
  "middle_name": null,
  "last_name": "Sharma",
  "email": "ananya@example.com",
  "educations": [],
  "specialities": [],
  "experiences": [],
  "profile_completion": 20,
  "sections": {
    "personal": true,
    "education": false,
    "speciality": false,
    "experience": false,
    "working_hours": false
  }
}
```

| Field                | Type              | Description                                                  |
|----------------------|-------------------|--------------------------------------------------------------|
| `id`                 | UUID              | Doctor's unique identifier                                   |
| `mobile`             | string            | Phone number as verified by MSG91                            |
| `first_name`         | string \| null    | First name                                                   |
| `middle_name`        | string \| null    | Middle name                                                  |
| `last_name`          | string \| null    | Last name                                                    |
| `email`              | string \| null    | Email address                                                |
| `educations`         | array             | List of education records (see Education schema)             |
| `specialities`       | array             | List of speciality records (see Speciality schema)           |
| `experiences`        | array             | List of experience records (see Experience schema)           |
| `profile_completion` | integer           | 0–100, increments of 20                                      |
| `sections`           | object            | Boolean map of completion per section (see model above)      |

---

### PATCH /doctors/me

Updates the doctor's personal information. All fields are optional — only supplied fields are updated.

```
PATCH /api/v1/doctors/me
Authorization: Bearer <token>
Content-Type: application/json
```

#### Request Body

```json
{
  "first_name": "Ananya",
  "last_name": "Sharma",
  "email": "ananya@example.com"
}
```

| Field         | Type           | Required | Description   |
|---------------|----------------|----------|---------------|
| `first_name`  | string \| null | no       | First name    |
| `middle_name` | string \| null | no       | Middle name   |
| `last_name`   | string \| null | no       | Last name     |
| `email`       | string \| null | no       | Email address |

#### Response — 200 OK

Same shape as `GET /doctors/me`.

---

## Education Sub-resource

Base path: `/api/v1/doctors/me/educations`

### POST /doctors/me/educations

Adds an education record for the authenticated doctor.

#### Request Body

```json
{
  "degree": "MBBS",
  "registration_number": "MH-12345",
  "institution": "Grant Medical College",
  "year_of_completion": 2015
}
```

| Field                 | Type           | Required | Description                        |
|-----------------------|----------------|----------|------------------------------------|
| `degree`              | string         | yes      | Degree name (e.g. `"MBBS"`)        |
| `registration_number` | string         | yes      | Medical council registration number|
| `institution`         | string \| null | no       | Institution name                   |
| `year_of_completion`  | integer \| null| no       | Year completed                     |

#### Response — 201 Created

```json
{
  "id": "...",
  "degree": "MBBS",
  "registration_number": "MH-12345",
  "institution": "Grant Medical College",
  "year_of_completion": 2015
}
```

| Field                 | Type           | Description                        |
|-----------------------|----------------|------------------------------------|
| `id`                  | UUID           | Education record ID                |
| `degree`              | string         | Degree name                        |
| `registration_number` | string         | Registration number                |
| `institution`         | string \| null | Institution name                   |
| `year_of_completion`  | integer \| null| Year completed                     |

---

### PATCH /doctors/me/educations/{edu_id}

Partially updates an education record owned by the authenticated doctor.

| Field                 | Type           | Required | Description              |
|-----------------------|----------------|----------|--------------------------|
| `degree`              | string \| null | no       | Degree name              |
| `registration_number` | string \| null | no       | Registration number      |
| `institution`         | string \| null | no       | Institution name         |
| `year_of_completion`  | integer \| null| no       | Year completed           |

#### Response — 200 OK

Same shape as POST response.

#### Errors

| Status | When it occurs                                              |
|--------|-------------------------------------------------------------|
| `404`  | Education record not found or belongs to another doctor     |

---

### DELETE /doctors/me/educations/{edu_id}

Deletes an education record owned by the authenticated doctor.

**Response — 204 No Content**

#### Errors

| Status | When it occurs                                              |
|--------|-------------------------------------------------------------|
| `404`  | Education record not found or belongs to another doctor     |

---

## Speciality Sub-resource

Base path: `/api/v1/doctors/me/specialities`

### POST /doctors/me/specialities

Adds a speciality for the authenticated doctor.

#### Request Body

```json
{
  "name": "Cardiology"
}
```

| Field  | Type   | Required | Description    |
|--------|--------|----------|----------------|
| `name` | string | yes      | Speciality name|

#### Response — 201 Created

```json
{
  "id": "...",
  "name": "Cardiology"
}
```

---

### DELETE /doctors/me/specialities/{spec_id}

Deletes a speciality owned by the authenticated doctor.

**Response — 204 No Content**

#### Errors

| Status | When it occurs                                              |
|--------|-------------------------------------------------------------|
| `404`  | Speciality not found or belongs to another doctor           |

---

## Experience Sub-resource

Base path: `/api/v1/doctors/me/experiences`

### POST /doctors/me/experiences

Adds a work experience record linked to a hospital from the shared master. The `hospital_id` must reference an existing hospital (see [hospitals.md](hospitals.md)).

#### Request Body

```json
{
  "hospital_id": "550e8400-e29b-41d4-a716-446655440001",
  "designation": "Consultant Cardiologist",
  "start_date": "2018-06-01",
  "end_date": null,
  "is_current": true
}
```

| Field          | Type           | Required | Description                                 |
|----------------|----------------|----------|---------------------------------------------|
| `hospital_id`  | UUID           | yes      | ID from the shared hospital master          |
| `designation`  | string \| null | no       | Role/designation at the hospital            |
| `start_date`   | date \| null   | no       | Start date (ISO 8601: `YYYY-MM-DD`)         |
| `end_date`     | date \| null   | no       | End date; `null` if currently employed      |
| `is_current`   | boolean        | no       | `true` if this is the current position (default: `false`) |

#### Response — 201 Created

```json
{
  "id": "...",
  "designation": "Consultant Cardiologist",
  "start_date": "2018-06-01",
  "end_date": null,
  "is_current": true,
  "hospital": {
    "id": "550e8400-e29b-41d4-a716-446655440001",
    "name": "Apollo Hospital",
    "type": "hospital",
    "city": "Mumbai"
  },
  "working_hours": []
}
```

| Field          | Type           | Description                                     |
|----------------|----------------|-------------------------------------------------|
| `id`           | UUID           | Experience record ID                            |
| `designation`  | string \| null | Role/designation                                |
| `start_date`   | date \| null   | Start date                                      |
| `end_date`     | date \| null   | End date                                        |
| `is_current`   | boolean        | Whether currently employed here                 |
| `hospital`     | object         | Embedded hospital reference (id, name, type, city)|
| `working_hours`| array          | Working-hour slots for this experience          |

#### Errors

| Status | When it occurs                                    |
|--------|---------------------------------------------------|
| `422`  | `hospital_id` does not exist in the hospital master|

---

### PATCH /doctors/me/experiences/{exp_id}

Partially updates an experience record owned by the authenticated doctor.

| Field          | Type           | Required | Description                         |
|----------------|----------------|----------|-------------------------------------|
| `hospital_id`  | UUID \| null   | no       | Must reference an existing hospital |
| `designation`  | string \| null | no       | Role/designation                    |
| `start_date`   | date \| null   | no       | Start date                          |
| `end_date`     | date \| null   | no       | End date                            |
| `is_current`   | boolean \| null| no       | Current employment flag             |

#### Response — 200 OK

Same shape as POST response.

#### Errors

| Status | When it occurs                                      |
|--------|-----------------------------------------------------|
| `404`  | Experience not found or belongs to another doctor   |
| `422`  | `hospital_id` provided but does not exist           |

---

### DELETE /doctors/me/experiences/{exp_id}

Deletes an experience record (and its working hours) owned by the authenticated doctor.

**Response — 204 No Content**

#### Errors

| Status | When it occurs                                     |
|--------|-----------------------------------------------------|
| `404`  | Experience not found or belongs to another doctor  |

---

## Working Hours Sub-resource

Base path: `/api/v1/doctors/me/experiences/{exp_id}/working-hours`

### GET /doctors/me/experiences/{exp_id}/working-hours

Returns all working-hour slots for the specified experience.

**Response — 200 OK** — array of working-hour objects

```json
[
  {
    "id": "...",
    "day_of_week": 1,
    "start_time": "09:00:00",
    "end_time": "17:00:00"
  }
]
```

#### Errors

| Status | When it occurs                                        |
|--------|-------------------------------------------------------|
| `404`  | Experience not found or belongs to another doctor     |

---

### POST /doctors/me/experiences/{exp_id}/working-hours

Adds a working-hour slot to an experience.

#### Request Body

```json
{
  "day_of_week": 1,
  "start_time": "09:00:00",
  "end_time": "17:00:00"
}
```

| Field         | Type    | Required | Description                                          |
|---------------|---------|----------|------------------------------------------------------|
| `day_of_week` | integer | yes      | Day index: `0`=Monday, `1`=Tuesday, …, `6`=Sunday   |
| `start_time`  | time    | yes      | Start time (`HH:MM:SS`)                              |
| `end_time`    | time    | yes      | End time (`HH:MM:SS`); must be after `start_time`    |

#### Response — 201 Created

```json
{
  "id": "...",
  "day_of_week": 1,
  "start_time": "09:00:00",
  "end_time": "17:00:00"
}
```

| Field         | Type    | Description                           |
|---------------|---------|---------------------------------------|
| `id`          | UUID    | Working-hour slot ID                  |
| `day_of_week` | integer | Day index (0=Monday … 6=Sunday)       |
| `start_time`  | time    | Start time                            |
| `end_time`    | time    | End time                              |

#### Errors

| Status | When it occurs                                           |
|--------|----------------------------------------------------------|
| `404`  | Experience not found or belongs to another doctor        |
| `422`  | `day_of_week` out of range, or `end_time <= start_time`  |

---

### DELETE /doctors/me/experiences/{exp_id}/working-hours/{wid}

Deletes a working-hour slot.

**Response — 204 No Content**

#### Errors

| Status | When it occurs                                          |
|--------|---------------------------------------------------------|
| `404`  | Experience not found, or working-hour slot not found    |

---

## Common Error Responses

| Status | When it occurs                                           |
|--------|----------------------------------------------------------|
| `401`  | Missing or invalid `Authorization: Bearer` token         |
| `422`  | Request body fails Pydantic validation                   |

---

## Examples

### curl — Get current profile

```bash
curl http://localhost:8000/api/v1/doctors/me \
  -H "Authorization: Bearer <token>"
```

### curl — Add education

```bash
curl -X POST http://localhost:8000/api/v1/doctors/me/educations \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"degree": "MBBS", "registration_number": "MH-12345"}'
```

### curl — Add working hours

```bash
curl -X POST http://localhost:8000/api/v1/doctors/me/experiences/<exp_id>/working-hours \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"day_of_week": 0, "start_time": "09:00:00", "end_time": "17:00:00"}'
```
