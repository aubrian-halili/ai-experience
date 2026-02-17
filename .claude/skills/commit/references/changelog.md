# Changelog Generation

Reference for generating changelog entries from commits.

## Format

```markdown
## [Version] - YYYY-MM-DD

### Added
- New feature description (#PR)

### Changed
- Modified behavior description (#PR)

### Fixed
- Bug fix description (#PR)

### Removed
- Removed feature description (#PR)
```

## Generate from Commits

```bash
# List commits since last tag
git log $(git describe --tags --abbrev=0)..HEAD --oneline

# Format for changelog
git log $(git describe --tags --abbrev=0)..HEAD --pretty=format:"- %s" --no-merges
```

## Mapping Commit Types to Sections

| Commit Type | Changelog Section |
|-------------|-------------------|
| `feat:` | Added |
| `fix:` | Fixed |
| `refactor:` | Changed |
| `docs:` | Changed (or Documentation section) |
| `chore:` | Usually omitted |
| `test:` | Usually omitted |

## Example

Given these commits:
```
UN-1234 feat(api): add user preferences endpoint
UN-1234 fix(auth): resolve token expiration issue
UN-1234 refactor(db): optimize query performance
```

Generate:
```markdown
## [1.2.0] - 2024-01-15

### Added
- Add user preferences endpoint (#123)

### Fixed
- Resolve token expiration issue (#123)

### Changed
- Optimize query performance (#123)
```
