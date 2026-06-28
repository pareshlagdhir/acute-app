# Hospitals API

**Version:** v1  
**Base path:** `/api/v1`

All endpoints require authentication via `Authorization: Bearer <token>`.  
Obtain a token from `POST /auth/login` — see [auth.md](auth.md).

---

## Overview

The hospitals endpoint manages the **shared hospital/clinic master list**. Any authenticated doctor may search the list or add a new entry. When creating a hospital, `created_by` is automatically recorded as the authenticated doctor's ID.

Hospitals are referenced by experiences — use `GET /hospitals?q=` to find a hospital before creating an experience record.

---

## Endpoints

### GET /hospitals

Searches the shared hospital/clinic master list. Returns up to 50 results ordered by name.

```
GET /api/v1/hospitals
Authorization: Bearer <token>
```

#### Query Parameters

| Parameter | Type   | Required | Description                                                     |
|-----------|--------|----------|-----------------------------------------------------------------|
| `q`       | string | no       | Case-insensitive contains search on `name` (e.g. `?q=apollo`)  |

#### Response — 200 OK

```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440001",
    "name": "Apollo Hospital",
    "type": "hospital",
    "city": "Mumbai",
    "address": "Sahar Road, Andheri East"
  }
]
```

| Field     | Type           | Description                                  |
|-----------|----------------|----------------------------------------------|
| `id`      | UUID           | Hospital's unique identifier                 |
| `name`    | string         | Hospital or clinic name                      |
| `type`    | string         | `"hospital"` or `"clinic"`                   |
| `city`    | string \| null | City                                         |
| `address` | string \| null | Street address                               |

---

### POST /hospitals

Adds a new hospital or clinic to the shared master list. The authenticated doctor is recorded as the creator.

```
POST /api/v1/hospitals
Authorization: Bearer <token>
Content-Type: application/json
```

#### Request Body

```json
{
  "name": "Apollo Hospital",
  "type": "hospital",
  "city": "Mumbai",
  "address": "Sahar Road, Andheri East"
}
```

| Field     | Type           | Required | Description                               |
|-----------|----------------|----------|-------------------------------------------|
| `name`    | string         | yes      | Hospital or clinic name                   |
| `type`    | string         | no       | `"hospital"` or `"clinic"` (default: `"hospital"`) |
| `city`    | string \| null | no       | City                                      |
| `address` | string \| null | no       | Street address                            |

#### Response — 201 Created

Same shape as a single item from `GET /hospitals`.

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440001",
  "name": "Apollo Hospital",
  "type": "hospital",
  "city": "Mumbai",
  "address": "Sahar Road, Andheri East"
}
```

---

## Error Responses

| Status | When it occurs                                     |
|--------|----------------------------------------------------|
| `401`  | Missing or invalid `Authorization: Bearer` token   |
| `422`  | Request body fails Pydantic validation             |

---

## Examples

### curl — Search for a hospital

```bash
curl "http://localhost:8000/api/v1/hospitals?q=apollo" \
  -H "Authorization: Bearer <token>"
```

### curl — Add a new hospital

```bash
curl -X POST http://localhost:8000/api/v1/hospitals \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"name": "City Clinic", "type": "clinic", "city": "Pune"}'
```

---

## Notes

- The hospital master is shared across all doctors — a hospital added by one doctor is visible to all others.
- When creating an experience, pass the `id` returned here as `hospital_id` — see [doctors.md](doctors.md).
- `GET /hospitals` returns at most 50 results. Use `?q=` to narrow the results when searching for a specific hospital.
