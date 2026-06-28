# Health API

**Version:** v1
**Base path:** `/api/v1`

---

## Endpoints

### GET /health

Returns the liveness status and current version of the API.

#### Request

```
GET /api/v1/health
```

#### Response

**200 OK**

```json
{
  "status": "ok",
  "version": "0.1.0"
}
```

| Field     | Type   | Description             |
|-----------|--------|-------------------------|
| `status`  | string | Always `"ok"` when live |
| `version` | string | Deployed semver string  |

---

## Error Responses

| Status | When it occurs                 |
|--------|--------------------------------|
| `500`  | Unexpected server-side failure |

---

## Examples

### curl

```bash
curl http://localhost:8000/api/v1/health
```

### Python (httpx)

```python
import httpx
response = httpx.get("http://localhost:8000/api/v1/health")
print(response.json())  # {"status": "ok", "version": "0.1.0"}
```
