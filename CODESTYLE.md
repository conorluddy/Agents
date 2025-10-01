# Code Style Quick Reference

> **Core Principle**: Context is finite. Every token—code, comment, structure—competes for limited attention. Maximize signal, minimize noise.

## Essential Philosophy

**Jackson's Law**: The optimal code is the minimum necessary to solve the problem correctly. Every additional line is debt.

**Progressive Disclosure**: Structure code layer-by-layer. Understand high-level flow without drilling into details.

**Self-Documenting**: Names eliminate the need for comments. Comments explain "why," never "what."

## Key Patterns

### Function Design
```python
# ✅ Self-contained, explicit, clear contract
def authenticate_user_and_update_last_login(
    user_credentials: UserCredentials,
    database: Database,
    current_time: datetime
) -> AuthenticationResult:
    """
    Authenticate credentials and update last login timestamp.
    
    Returns AuthenticationResult with success status and user details if valid.
    Raises DatabaseConnectionError if connection fails.
    """
    pass

# ❌ Ambiguous, hidden dependencies
def process(user):
    if check(user):
        update_db(user)
        return True
    return False
```

**Rules**:
- Single responsibility (one clear purpose)
- Explicit dependencies (no hidden state)
- Type hints everywhere
- Descriptive names: `validate_user_credentials()` not `process_user()`

### File Organization
```python
class DataProcessor:
    """
    <architecture>
    Three-stage pipeline: Validation → Transformation → Persistence
    </architecture>
    """
    
    # ========================================
    # PUBLIC API
    # ========================================
    
    def process(self, data: RawData) -> ProcessedData:
        pass
    
    # ========================================
    # VALIDATION STAGE
    # ========================================
    
    def _validate_schema(self, data: RawData) -> ValidatedData:
        pass
```

**Rules**:
- Clear section boundaries (helps navigation)
- Public API first, implementation details after
- Group related functionality
- Max 300 lines per file (guideline, not rule)

### Error Handling
```python
# ✅ Actionable error with context
raise ValueError(
    f"user_email must be valid email format (received: '{user_email}'). "
    f"Expected: name@domain.com. Use validate_email_format() first."
)

# ❌ Opaque error
raise ValueError("Invalid input")
```

**Rules**:
- Never silently swallow errors
- Provide actionable guidance
- Include context (what failed, why, how to fix)

### Token-Efficient Tools
```python
# ✅ Returns focused summary with drill-down references
def get_user_activity_summary(user_id: str) -> ActivitySummary:
    """
    Returns activity summary. Use get_activity_details(event_id) for specifics.
    """
    return ActivitySummary(
        total_events=1247,
        recent_events=[...10 most recent...],
        event_ids_by_type={'login': [...], 'purchase': [...]}
    )

# ❌ Returns everything, wastes tokens
def get_user_activity(user_id: str) -> dict:
    return {'events': [...1000 events...]}  # Token bloat
```

**Rules**:
- Support pagination (`max_results`, `offset`)
- Return summaries, not dumps
- Provide references for drill-down

### Examples as Documentation
```python
def execute_batch_operation(
    operations: list[Operation],
    batch_size: int = 50,
    error_handling: ErrorStrategy = ErrorStrategy.FAIL_FAST
) -> BatchResult:
    """
    <examples>
    # Simple usage
    ops = [UpdateOperation(id=i, data=d) for i, d in enumerate(data)]
    result = execute_batch_operation(ops)
    
    # Continue on errors
    result = execute_batch_operation(
        ops, 
        batch_size=100,
        error_handling=ErrorStrategy.CONTINUE_ON_ERROR
    )
    </examples>
    """
    pass
```

**Rules**:
- Provide canonical examples for complex APIs
- Show diverse usage patterns
- Edge cases go in tests, not examples

## Architecture Patterns

### Module Isolation
```
project/
├── authentication/     # Self-contained context
│   ├── __init__.py    # Public API only
│   └── README.md      # Architecture guide
├── data_processing/   # Independent context
└── storage/           # Independent context
```

**Rules**:
- Group by feature/domain, not file type
- Minimal cross-module dependencies
- Each module is a clean context boundary
- Public APIs at `__init__.py`

### CLAUDE.md for Navigation
```markdown
# Project: Data Processing Pipeline

## Entry Points
- `main.py`: CLI interface
- `api/server.py`: REST API
- `processors/pipeline.py`: Core processing

## Key Patterns
- All processors implement `Processor` interface (processors/base.py)
- Config uses Pydantic models (config/models.py)
- External APIs via `APIClient` (external/client.py)

## Common Tasks
- Add data source → implement `DataSource` in `api/sources/`
- Add transformation → implement `Transformer` in `processors/transformers/`
```

**Rules**:
- Drop CLAUDE.md at project root
- List entry points, patterns, common tasks
- Keep under 200 lines

## Cognitive Load Management

**Reduce**: Remove unnecessary code. Question every feature.

**Hide**: Encapsulate complexity. Simple interfaces to complex systems.

**Explain**: Strategic comments for "why" decisions. Types communicate intent.

**Compartmentalize**: Separate concerns. Clear mental models.

## Anti-Patterns

❌ **Premature optimization** - Measure first, optimize second
❌ **Hasty abstractions** - Wait for 3rd duplication before extracting
❌ **Clever code** - Simple and obvious beats clever and compact
❌ **Silent failures** - Log and propagate, never swallow
❌ **Vague interfaces** - Be specific enough to guide, flexible enough to evolve

## Tests as Documentation

```python
def test_authentication_rejects_invalid_credentials():
    """
    Should fail gracefully for invalid credentials, returning clear error
    without exposing whether username exists (prevents enumeration attacks).
    """
    result = authenticator.authenticate(
        username="nonexistent@example.com",
        password="password123"
    )
    assert result.success is False
    assert result.error_code == "INVALID_CREDENTIALS"
```

**Rules**:
- Test names describe scenarios
- Docstrings explain "why"
- Tests demonstrate usage
- 80% coverage minimum

## Development Checklist

- [ ] Does it solve the stated problem?
- [ ] Is cognitive load reasonable? (can a new dev understand it?)
- [ ] Are errors handled with actionable messages?
- [ ] Is naming clear and consistent?
- [ ] Are there tests for critical paths?
- [ ] Would this work well with 200 lines of surrounding context?

## Remember

**Code is for humans (and AI agents)** - both have limited attention budgets. Write code that maximizes understanding within minimal context. Be ruthlessly intentional with every token you create.

*"Any fool can write code that a computer can understand. Good programmers write code that humans can understand." - Martin Fowler*
