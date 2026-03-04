# Scaffold a FastAPI Endpoint

Create a new FastAPI endpoint following the project's established patterns.

## Input

Endpoint description: $ARGUMENTS

## Instructions

### Phase 1: Design

1. Ask the user for:
   - HTTP method (GET, POST, PUT, DELETE)
   - URL path (will be prefixed with `/private/`)
   - Purpose (what does this endpoint do?)
   - Does it need database access? (AsyncSession injection)
   - Does it need the authenticated user? (request.state.claims)
   - Request body fields (for POST/PUT)
   - Response fields

2. Read existing patterns:
   - `api/src/api/routes.py` — route registration
   - `api/src/api/request_models.py` — request model conventions
   - `api/src/api/response_models.py` — response model conventions

### Phase 2: Scaffold

#### 1. Request Model (if POST/PUT)

Add to `api/src/api/request_models.py`:
```python
class {EndpointName}Request(BaseModel):
    field_name: str
    # ... fields from user spec
```

#### 2. Response Model

Add to `api/src/api/response_models.py`:
```python
class {EndpointName}Response(BaseModel):
    field_name: str
    # ... fields from user spec
```

#### 3. Endpoint Handler

Create `api/src/api/{endpoint_name}_endpoints.py`:
```python
from fastapi import Depends, HTTPException, Request
from sqlmodel.ext.asyncio.session import AsyncSession
from src.db.database import get_async_session
import logging

logger = logging.getLogger(__name__)

async def {handler_name}(
    request: Request,
    db_session: AsyncSession = Depends(get_async_session),
) -> {ResponseModel}:
    try:
        username = request.state.claims["username"]
        # Implementation here
    except Exception as e:
        logger.error(f"Error in {handler_name}: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")
```

#### 4. Route Registration

Add to `api/src/api/routes.py`:
```python
from src.api.{endpoint_name}_endpoints import {handler_name}

protected_routes.add_api_route(
    "/{url_path}",
    endpoint={handler_name},
    methods=["{METHOD}"],
    response_model={ResponseModel},
)
```

### Phase 3: Verify

1. Show the user all generated code
2. Check that imports resolve: `cd api && python -c "from src.api.{endpoint_name}_endpoints import {handler_name}"`
3. Ask if they want a test scaffolded

## Important Rules

- All endpoints go under `protected_routes` (JWT required) unless explicitly requested otherwise
- Use `request.state.claims` for auth context, not custom auth parameters
- Use `Depends(get_async_session)` for database access
- Log errors with `logger.error()` before raising HTTPException
- Never expose internal error details to the client
