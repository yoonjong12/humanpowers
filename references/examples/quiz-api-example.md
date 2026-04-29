# TF-{X} Generic POST API — Expected Outputs Quiz (EXAMPLE, signed_off)

> Status: signed_off
> action_type: api
> Developer articulation: 6 questions / 22 turns

## Q1: Request shape

POST /api/resource — accepted body shape?

**Developer answer**:
```json
{
  "name": "string, 1-100 chars, required",
  "type": "enum: type_a | type_b | type_c, required",
  "metadata": {
    "key": "string, optional",
    "tags": ["string array, max 10 items, each 1-50 chars"]
  }
}
```

Content-Type: application/json. Other = 415.

**Critique log**: Vagueness ("string"→length?), Specificity (type→enum values?), Completeness (Content-Type rejection?)

## Q2: Response shape — success

201 Created body?

**Developer answer**:
```json
{
  "id": "uuid v4",
  "created_at": "ISO 8601 UTC",
  "name": "echoed",
  "type": "echoed",
  "metadata": "echoed or null"
}
```

Header: `Location: /api/resource/{id}`.

## Q3: Response shape — error

4xx body shape?

**Developer answer**:
```json
{
  "error": {
    "code": "string (e.g., VALIDATION_FAILED, NOT_FOUND)",
    "message": "human-readable",
    "field": "name of failed field, or null"
  }
}
```

400 = validation, 401 = auth, 403 = permission, 404 = not found, 409 = conflict, 422 = unprocessable.

## Q4: Auth

Required?

**Developer answer**:
- Bearer token in Authorization header
- Token = JWT signed with HS256
- Token expiry 1 hour
- Missing/invalid token = 401 with `error.code = AUTH_REQUIRED` or `AUTH_INVALID`

## Q5: Rate limit

**Developer answer**:
- 100 req/min per user
- 429 response with `Retry-After: {seconds}` header
- Body = standard error shape with `code: RATE_LIMITED`

## Q6: Idempotency

Same request, retry-safe?

**Developer answer**:
- Optional `Idempotency-Key` header (UUID)
- Same key + same body within 24h = return original response
- Same key + different body = 409 conflict

**Test spec**:
- cURL with valid body → 201, body shape matches
- cURL missing required field → 400, error.field = name
- cURL invalid Content-Type → 415
- cURL no auth → 401
- cURL same idempotency key + body → same response (cached)
- cURL same key + different body → 409
- 101 rapid requests → 429 with Retry-After
