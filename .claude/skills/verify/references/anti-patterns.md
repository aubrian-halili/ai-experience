# Anti-Pattern Detection Reference

## Search Patterns

Quick-reference grep patterns for detecting common anti-patterns during verification.

### Critical Severity

**Stub Returns:**
```
# Functions that return empty/null without logic
return null
return undefined
return {}
return []
return ''
return ""
return 0
pass  # Python
```

**Placeholder Throws:**
```
throw new Error('Not implemented')
throw new Error('TODO')
throw new Error('FIXME')
raise NotImplementedError
panic("not implemented")
```

### High Severity

**TODO/FIXME Comments:**
```
TODO
FIXME
HACK
XXX
TEMP
WORKAROUND
```

**Empty Catch Blocks:**
```
catch.*\{\s*\}
catch.*\{\s*//
catch.*\{\s*/\*
except:\s*pass
```

### Medium Severity

**Console-Only Error Handling:**
```
catch.*console\.(log|error|warn)
catch.*print\(
```

**Orphaned Code:**
```
// Removed
// Deprecated
// Old implementation
// No longer used
```

**Type Safety Bypasses:**
```
as any
: any
@ts-ignore
@ts-nocheck
eslint-disable
```

### Low Severity

**Hardcoded Values:**
```
localhost:
127.0.0.1
password.*=.*['"]
secret.*=.*['"]
```

## Verification Checklist

Use this checklist when running a full verification pass:

### Level 1: Existence
- [ ] All planned files exist
- [ ] All planned exports are present
- [ ] Test files exist for implementation files
- [ ] Configuration files are present
- [ ] Database migrations exist (if applicable)

### Level 2: Substance
- [ ] No stub returns in core logic
- [ ] No placeholder throws
- [ ] No empty catch blocks
- [ ] Test assertions are meaningful
- [ ] Configuration values are real (not placeholders)

### Level 3: Wiring
- [ ] All exports are consumed
- [ ] Routes are registered
- [ ] Middleware is applied
- [ ] Event handlers are subscribed
- [ ] Environment variables are loaded
- [ ] Tests are in test runner scope
