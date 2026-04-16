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
