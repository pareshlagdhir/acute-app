# Catalog API

**Version:** v1  
**Base path:** `/api/v1`

Catalog endpoints are **public — no authentication is required**.

---

## Overview

The catalog exposes seeded reference lists used to power degree and speciality pickers in the mobile app. Both endpoints support prefix search and return up to 50 results ordered alphabetically by name.

---

## Endpoints

### GET /catalog/degrees

Returns degree catalog items. Supports prefix search on `name`.

```
GET /api/v1/catalog/degrees
```

#### Query Parameters

| Parameter | Type   | Required | Description                                               |
|-----------|--------|----------|-----------------------------------------------------------|
| `q`       | string | no       | Prefix search on degree name (e.g. `?q=MB` matches `MBBS`)|

#### Response — 200 OK

```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440010",
    "name": "MBBS"
  },
  {
    "id": "550e8400-e29b-41d4-a716-446655440011",
    "name": "MD"
  }
]
```

| Field  | Type   | Description                |
|--------|--------|----------------------------|
| `id`   | UUID   | Catalog item ID            |
| `name` | string | Degree name                |

---

### GET /catalog/specialities

Returns speciality catalog items. Supports prefix search on `name`.

```
GET /api/v1/catalog/specialities
```

#### Query Parameters

| Parameter | Type   | Required | Description                                                        |
|-----------|--------|----------|--------------------------------------------------------------------|
| `q`       | string | no       | Prefix search on speciality name (e.g. `?q=Card` matches `Cardiology`)|

#### Response — 200 OK

```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440020",
    "name": "Cardiology"
  },
  {
    "id": "550e8400-e29b-41d4-a716-446655440021",
    "name": "Dermatology"
  }
]
```

| Field  | Type   | Description                |
|--------|--------|----------------------------|
| `id`   | UUID   | Catalog item ID            |
| `name` | string | Speciality name            |

---

## Error Responses

| Status | When it occurs                           |
|--------|------------------------------------------|
| `422`  | Query parameter type validation failure  |

---

## Examples

### curl — Search degrees

```bash
curl "http://localhost:8000/api/v1/catalog/degrees?q=MB"
```

### curl — List all specialities

```bash
curl "http://localhost:8000/api/v1/catalog/specialities"
```

---

## Notes

- The catalog lists are seeded via Alembic migration and are not user-editable through this API.
- Search is prefix-based (anchored at the start of the name), case-insensitive. `?q=card` matches `Cardiology` but not `Electrocardiography`.
- Both endpoints return at most 50 results. Longer queries narrow results naturally.
- These endpoints have no authentication requirement — they are safe to call before login (e.g. on the registration screen).
