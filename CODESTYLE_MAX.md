# Code Style Guide: Human and AI Agent Collaboration

**Modern software development demands code that serves two audiences**: human developers who maintain and evolve systems, and AI agents that assist in building them. This guide synthesizes proven software engineering principles with emerging context engineering techniques to create code that is maintainable, understandable, and optimally structured for both human and AI collaboration.

## Core principle: Context is a finite resource

Whether you're writing for a human reviewer with limited working memory or an AI agent with a bounded context window, **the fundamental challenge remains identical**: optimize for clarity within constraints. Every line of code, every comment, every structural decision either aids understanding or depletes the limited attention budget available to whoever—or whatever—is processing your code. The most effective code maximizes signal while minimizing noise.

This isn't about writing more documentation or adding more structure. It's about being ruthlessly intentional with every token of context you create. As Anthropic's research demonstrates, LLMs experience "context rot" as token counts increase—their ability to accurately recall and reason about information degrades, much like human working memory becomes overwhelmed. The solution isn't larger context windows; it's better context engineering.

## Jackson's Law and cognitive load management

**Jackson's Law states that the optimal amount of code is the minimum necessary to solve the problem correctly.** Every additional line represents technical debt—something that must be read, understood, maintained, and reasoned about. This principle applies doubly when AI agents are involved, as each token in your codebase competes for space in the model's limited attention budget.

Manage cognitive load by **practicing aggressive minimalism**. Before adding any code, ask: "Is this the simplest possible solution?" Before adding any comment, ask: "Does this clarify something non-obvious, or just repeat what the code already says?" Before introducing any abstraction, ask: "Does this reduce complexity, or merely relocate it?"

AI agents excel at navigating codebases when given clear, minimal implementations. A 50-line function that does one thing well is far more valuable than a 500-line function attempting to handle every edge case. **The Goldilocks altitude for instructions** applies to code: specific enough to be unambiguous, flexible enough to be maintainable. Avoid hardcoding brittle logic that makes false assumptions about future states. Avoid vague implementations that fail to communicate intent.

## Structure code for progressive disclosure

Both humans and AI agents benefit from **progressive disclosure**—the ability to understand code layer by layer, discovering details as needed rather than all at once. This mirrors how Anthropic's Claude Code operates: maintaining lightweight identifiers and dynamically loading data into context at runtime.

**Organize your codebase to support just-in-time understanding.** File names should clearly indicate purpose. Directory structures should mirror conceptual hierarchies. Imports should be grouped logically. Function names should be descriptive enough that you can understand what they do without reading their implementation.

Consider this example:

```python
# Poor: Forces reader to parse everything at once
def process(data, config, mode=None, validate=True, transform=None, callbacks=None):
    if validate: 
        # 50 lines of validation logic
    if mode == 'batch':
        # 40 lines of batch processing
    elif mode == 'stream':
        # 40 lines of streaming
    # More complex logic...
```

```python
# Better: Enables progressive disclosure
def process(data: ProcessedData, config: ProcessConfig) -> ProcessResult:
    """Transform validated data according to config specifications."""
    validated_data = _validate_and_prepare(data, config.validation_rules)
    
    if config.processing_mode == ProcessingMode.BATCH:
        return _process_batch(validated_data, config)
    return _process_stream(validated_data, config)
```

The second version allows both humans and AI agents to understand the high-level flow immediately, then drill down into specifics only when needed. **Each function becomes a clean context boundary**, containing just the information necessary for its specific task.

## Write self-documenting code with strategic comments

The best code is self-documenting: variable and function names clearly express intent, structure reveals architecture, and the logic flows naturally. **Comments should explain "why," not "what."** An AI agent parsing your code can understand what `user_id = request.params.get('user_id')` does. It cannot infer why you're extracting it at this specific point in the request lifecycle, or what business rule necessitates this approach.

```python
# Poor: Explains what the code does (redundant)
# Get the user ID from the request parameters
user_id = request.params.get('user_id')

# Better: Explains why (provides context)
# Extract user_id before authentication to enable audit logging
# even for failed auth attempts, per SOC2 requirements
user_id = request.params.get('user_id')
```

**For AI agents, strategic commenting provides high-signal tokens** that dramatically improve their ability to make correct decisions. When modifying a function, an agent that understands why the code exists—not just what it does—can preserve intent while adapting implementation.

Document non-obvious decisions explicitly. If you chose algorithm A over algorithm B for subtle performance reasons, state that. If you're working around a third-party library bug, explain it. If a seemingly simple function has surprising edge cases, enumerate them. These explanations are **high-value context that would otherwise be lost**.

## Organize code with clear sectioning and XML-inspired structure

Anthropic's research emphasizes using structural markers like XML tags or Markdown headers to delineate distinct sections of context. This principle extends naturally to code organization.

**Use consistent structural patterns throughout your codebase:**

```python
class DataProcessor:
    """
    Core data transformation pipeline.
    
    <architecture>
    This processor implements a three-stage pipeline:
    1. Validation - ensures data meets schema requirements
    2. Transformation - applies business logic transformations  
    3. Persistence - stores results to appropriate destinations
    </architecture>
    
    <usage>
    processor = DataProcessor(config)
    result = processor.process(raw_data)
    </usage>
    """
    
    # ============================================================================
    # PUBLIC API
    # ============================================================================
    
    def process(self, data: RawData) -> ProcessedData:
        """Main entry point for data processing."""
        pass
    
    # ============================================================================
    # VALIDATION STAGE
    # ============================================================================
    
    def _validate_schema(self, data: RawData) -> ValidatedData:
        """Ensures data conforms to expected schema."""
        pass
    
    # ============================================================================
    # TRANSFORMATION STAGE  
    # ============================================================================
    
    def _apply_transforms(self, data: ValidatedData) -> TransformedData:
        """Applies configured business logic transformations."""
        pass
```

These clear section boundaries help both humans and AI agents quickly navigate to relevant code. **When an agent needs to understand validation logic, it can locate the VALIDATION STAGE section and ignore everything else**, keeping its context focused and efficient.

## Design functions and modules as self-contained context units

Every function should be a **complete, self-contained unit of understanding**. An ideal function can be comprehended entirely without needing to reference other parts of the codebase. This aligns with Anthropic's guidance that tools should be "self-contained, robust to error, and extremely clear with respect to their intended use."

**Apply these principles to function design:**

1. **Single responsibility**: Each function does exactly one thing. If you can't describe what a function does in a single, clear sentence, it's doing too much.

2. **Explicit dependencies**: Make all dependencies clear through parameters. Avoid hidden dependencies on global state, module-level variables, or distant imports.

3. **Clear input/output contracts**: Use type hints extensively. Document expected inputs, outputs, and any exceptions that might be raised.

4. **Descriptive, unambiguous names**: Instead of `process_user()`, use `validate_user_credentials()`. Instead of a parameter named `data`, use `user_authentication_data`. Make the specific purpose crystal clear.

```python
# Poor: Ambiguous, hidden dependencies, unclear contract
def process(user):
    if check(user):
        update_db(user)
        return True
    return False

# Better: Self-contained, explicit, clear contract  
def authenticate_user_and_update_last_login(
    user_credentials: UserCredentials,
    database: Database,
    current_time: datetime
) -> AuthenticationResult:
    """
    Authenticate user credentials and update their last login timestamp.
    
    Args:
        user_credentials: Username and password to validate
        database: Database connection for queries and updates
        current_time: Timestamp to record as last login time
        
    Returns:
        AuthenticationResult with success status and user details if valid
        
    Raises:
        DatabaseConnectionError: If database connection fails
        ValidationError: If credentials format is invalid
    """
    pass
```

When an AI agent encounters the second version, it has **complete context for understanding and modifying the function** without needing to explore the entire codebase.

## Implement token-efficient tools and utilities

For codebases designed to work with AI agents, **every utility function and tool should be optimized for token efficiency**. This means functions should return precisely the information needed—no more, no less.

Apply these token-efficiency patterns:

**Pagination and filtering**: Any function that could return large result sets should support limiting output size:

```python
def find_matching_records(
    query: str,
    max_results: int = 100,  # Sensible default limit
    offset: int = 0
) -> list[Record]:
    """Find records matching query, with pagination support."""
    pass
```

**Structured summaries over raw dumps**: Rather than returning complete objects, return focused summaries:

```python
# Poor: Returns everything, wastes tokens
def get_user_activity(user_id: str) -> dict:
    return {
        'events': [...1000 events...],  # Massive token consumption
        'metadata': {...},
        'related': {...}
    }

# Better: Returns summary, supports drill-down  
def get_user_activity_summary(user_id: str) -> ActivitySummary:
    """
    Returns summary of user activity with references for detail retrieval.
    
    Use get_activity_details(event_id) to fetch specific events.
    """
    return ActivitySummary(
        total_events=1247,
        recent_events=[...10 most recent...],
        event_ids_by_type={'login': [...], 'purchase': [...]},
        time_range=(start, end)
    )
```

**Clear error messages with actionable guidance**: When operations fail, provide specific, actionable error messages rather than opaque error codes:

```python
# Poor: Opaque error
raise ValueError("Invalid input")

# Better: Actionable error with context
raise ValueError(
    "user_email must be a valid email format (received: '{user_email}'). "
    "Expected format: name@domain.com. "
    "Use validate_email_format() to check before calling this function."
)
```

These patterns reduce token waste while improving both human and AI agent experience.

## Leverage examples for complex patterns

Anthropic's research emphasizes that **"examples are the pictures worth a thousand words"** for LLMs. The same holds true for human developers encountering unfamiliar code patterns.

For complex APIs, design patterns, or intricate logic, provide **canonical examples** rather than exhaustive documentation:

```python
def execute_batch_operation(
    operations: list[Operation],
    batch_size: int = 50,
    error_handling: ErrorStrategy = ErrorStrategy.FAIL_FAST
) -> BatchResult:
    """
    Execute operations in batches with configurable error handling.
    
    <examples>
    # Example 1: Simple batch processing with default settings
    operations = [UpdateOperation(id=i, data=d) for i, d in enumerate(data)]
    result = execute_batch_operation(operations)
    
    # Example 2: Custom batch size with continued execution on errors
    result = execute_batch_operation(
        operations,
        batch_size=100,
        error_handling=ErrorStrategy.CONTINUE_ON_ERROR
    )
    # Check result.failed_operations for any failures
    
    # Example 3: Transaction-style all-or-nothing execution
    result = execute_batch_operation(
        operations,
        error_handling=ErrorStrategy.ROLLBACK_ON_ERROR
    )
    </examples>
    """
    pass
```

Choose diverse, canonical examples that effectively portray the expected behavior. **Avoid stuffing edge cases into examples**—those belong in dedicated tests or documentation.

## Architect for context isolation and reuse

For large systems, **context isolation** becomes critical. Design your architecture so that related functionality is grouped together, unrelated functionality is clearly separated, and context boundaries are explicit.

**Apply the sub-agent architecture pattern to code organization.** Just as Anthropic's research shows that sub-agents handle focused tasks with clean context windows, your modules should handle focused responsibilities with minimal cross-dependencies:

```
project/
├── authentication/        # Self-contained auth context
│   ├── __init__.py       # Clear public API
│   ├── credentials.py    # Credential validation
│   ├── sessions.py       # Session management  
│   └── README.md         # Architecture and usage
├── data_processing/      # Self-contained processing context
│   ├── __init__.py
│   ├── validators.py
│   ├── transformers.py
│   └── README.md
└── storage/              # Self-contained storage context
    ├── __init__.py
    ├── database.py
    ├── cache.py
    └── README.md
```

Each module maintains its own focused context. **An AI agent working on authentication doesn't need to load the entire data_processing context into its attention budget.** The public API at each `__init__.py` provides the minimal interface for cross-module communication.

Within modules, use the same principle:

```python
class UserAuthenticationService:
    """
    Self-contained authentication service.
    
    This service has no external dependencies beyond the database interface.
    All authentication logic is contained within this class and its helpers.
    """
    
    def __init__(self, database: Database):
        self._db = database
        self._credential_validator = CredentialValidator()
        self._session_manager = SessionManager()
    
    # All methods self-contained with explicit dependencies
```

## Create CLAUDE.md files for AI agent navigation

Anthropic specifically mentions that **Claude Code uses CLAUDE.md files** dropped into context up front to understand project structure. Adopt this pattern for any codebase intended for AI agent collaboration:

```markdown
# Project Architecture

## Overview
This is a data processing pipeline that ingests raw data from multiple sources,
validates and transforms it, then stores results to both database and cache.

## Key Entry Points
- `main.py`: Application entry point and CLI interface
- `api/server.py`: REST API server for programmatic access
- `processors/pipeline.py`: Core processing pipeline implementation

## Directory Structure
- `api/`: REST API and request handlers
- `processors/`: Data processing logic
  - `validators/`: Input validation
  - `transformers/`: Data transformation rules
  - `enrichers/`: Data enrichment services
- `storage/`: Database and cache interfaces
- `config/`: Configuration management
- `tests/`: Test suites organized by module

## Development Patterns
- All processors implement the `Processor` interface (processors/base.py)
- Configuration uses Pydantic models (config/models.py)
- Database queries use the query builder (storage/query_builder.py)
- All external API calls go through the `APIClient` (external/client.py)

## Common Tasks
- Add new data source: Implement `DataSource` in `api/sources/`
- Add new transformation: Implement `Transformer` in `processors/transformers/`
- Modify validation rules: Edit schemas in `config/validation_schemas.py`

## Testing
- Unit tests: `pytest tests/unit/`
- Integration tests: `pytest tests/integration/`
- Run with coverage: `pytest --cov=src tests/`
```

This file provides **high-signal context that enables AI agents to navigate your codebase efficiently**. It answers the questions an agent would need to ask anyway, front-loading essential information.

## Optimize for long-horizon development tasks

When working on large features or refactoring projects, apply Anthropic's **long-horizon task techniques**:

**Maintain structured notes**: Create and update task-tracking files that persist state across work sessions:

```markdown
# Feature: User Authentication Revamp

## Progress
- [x] Design new authentication flow
- [x] Implement credential validation  
- [ ] Implement session management (IN PROGRESS)
- [ ] Add OAuth integration
- [ ] Update API documentation

## Current Focus
Implementing SessionManager in authentication/sessions.py
- Token generation working
- Need to add token refresh logic
- Need to implement session cleanup

## Decisions Made
- Using JWT tokens instead of opaque tokens for stateless auth
- Session timeout: 24 hours (per security requirements)
- Refresh token lifetime: 30 days

## Open Questions  
- Should we support multiple concurrent sessions per user?
- What session cleanup strategy? Background job vs. lazy cleanup?

## Files Modified
- authentication/sessions.py (active work)
- authentication/credentials.py (completed)
- tests/test_sessions.py (needs updating)
```

This structured note-taking allows both humans and AI agents to maintain context across interruptions, enabling effective collaboration on complex tasks.

**Use compaction principles**: As codebases grow, regularly refactor to "compact" functionality—summarize and consolidate related code, remove dead code, simplify complex implementations:

```python
# Before: 200 lines of similar validation logic scattered across functions
def validate_user_email(email): ...  # 40 lines
def validate_user_phone(phone): ...  # 40 lines  
def validate_user_address(addr): ... # 50 lines
# etc.

# After: Compacted into unified validation with clear structure
class UserDataValidator:
    """Unified validation for all user data fields."""
    
    def validate_email(self, email: str) -> ValidationResult:
        """Validate email format and deliverability."""
        return self._validate_field(email, self._email_rules)
    
    def validate_phone(self, phone: str) -> ValidationResult:
        """Validate phone number format and region."""
        return self._validate_field(phone, self._phone_rules)
```

## Write tests as executable documentation

Tests serve dual purposes: they verify correctness and **document expected behavior**. Write tests that clearly communicate intent:

```python
def test_authentication_rejects_invalid_credentials():
    """
    Authentication should fail gracefully for invalid credentials,
    returning a clear error without exposing whether the username exists.
    This prevents username enumeration attacks.
    """
    authenticator = UserAuthenticator(database)
    
    # Invalid username
    result = authenticator.authenticate(
        username="nonexistent@example.com",
        password="password123"  
    )
    assert result.success is False
    assert result.error_code == "INVALID_CREDENTIALS"
    assert "username or password" in result.error_message.lower()
    
    # Invalid password  
    result = authenticator.authenticate(
        username="valid@example.com",
        password="wrong_password"
    )
    assert result.success is False
    assert result.error_code == "INVALID_CREDENTIALS"
    assert "username or password" in result.error_message.lower()
```

Test names and docstrings should explain the "why." Test implementations should be clear enough that they serve as usage examples. **An AI agent reading your tests should understand both how to use your code and what invariants it must preserve.**

## Balance specificity and flexibility in interfaces

Anthropic's guidance on finding the **"right altitude"** applies directly to API design. Avoid two extremes:

**Too specific (brittle)**: Hardcoded logic that breaks when requirements evolve:

```python
# Too brittle: Hardcodes specific business rules
def calculate_discount(user_type: str, order_total: float) -> float:
    if user_type == "premium" and order_total > 100:
        return order_total * 0.2
    elif user_type == "standard" and order_total > 50:
        return order_total * 0.1
    return 0.0
```

**Too vague (ambiguous)**: Generic interfaces that provide no guidance:

```python  
# Too vague: No clear contract or guidance
def process(input: Any) -> Any:
    """Process the input somehow."""
    pass
```

**Right altitude (clear heuristics)**: Specific enough to guide behavior, flexible enough to evolve:

```python
class DiscountCalculator:
    """
    Calculate discounts based on configurable rules.
    
    Discounts are applied hierarchically:
    1. User tier discounts (based on membership level)
    2. Order volume discounts (based on order total)  
    3. Promotional discounts (based on active promotions)
    """
    
    def __init__(self, discount_rules: DiscountRules):
        self._rules = discount_rules
    
    def calculate_discount(
        self,
        user: User,
        order: Order,
        active_promotions: list[Promotion]
    ) -> Discount:
        """Calculate total discount applying all applicable rules."""
        pass
```

This provides clear guidance while remaining flexible. **An AI agent can understand the conceptual model and apply it correctly** even to scenarios not explicitly coded.

## Conclusion: Write for understanding, optimize for attention

The synthesis of human-centric software engineering and AI-aware context engineering yields a single, powerful principle: **optimize every element of your code for maximal understanding within minimal attention budget**.

Whether the reader is human or AI, the goal remains constant—enable them to quickly grasp what your code does, why it exists, and how to work with it effectively. Practice aggressive minimalism. Structure code for progressive disclosure. Make implicit context explicit. Isolate concerns and create clean boundaries. Provide high-signal documentation that clarifies non-obvious decisions.

**The most maintainable codebases are those where every element serves a clear purpose, where structure mirrors intent, and where understanding compounds naturally as you navigate deeper.** These codebases serve human developers exceptionally well. They also happen to be exactly what AI agents need to be effective collaborators.

As AI capabilities continue advancing, the codebases that thrive will be those designed with **intentional context engineering**—treating every token of code, comment, and documentation as a precious resource in the finite attention budget of whoever is trying to understand and modify the system. Write code that respects that constraint, and you'll create systems that are a joy to work with, whether you're human or AI.

---

*This guide synthesizes principles from Anthropic's research on context engineering for AI agents with established software engineering practices. For AI-specific tooling and platform support, see [Anthropic's memory and context management documentation](https://github.com/anthropics/claude-cookbooks/blob/main/tool_use/memory_cookbook.ipynb).*
