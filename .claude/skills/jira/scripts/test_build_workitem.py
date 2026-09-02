#!/usr/bin/env python3
"""Tests for build-workitem.py.

Runs two ways, because this repo has no test runner installed:

    python3 .claude/skills/jira/scripts/test_build_workitem.py   # zero dependencies
    pytest .claude/skills/jira/scripts/test_build_workitem.py    # if pytest is present

Both collect the same `test_*` functions and the same plain asserts. The module under
test is loaded by path because its filename is hyphenated and so is not importable.
"""

import importlib.util
import io
import json
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Any, Callable

SCRIPT = Path(__file__).with_name("build-workitem.py")

_spec = importlib.util.spec_from_file_location("build_workitem", SCRIPT)
assert _spec and _spec.loader
build_workitem = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(build_workitem)

TEMPLATE = """\
## Summary
Users cannot reset their password from the login screen.

## Acceptance Criteria
- A `Forgot password` link appears on the login screen
- Submitting a known email sends a reset mail within 60s

## Technical Details
- Files: `src/auth/login.tsx`
- Verification: `npm test -- auth`
- Spec: [RFC 42](https://example.com/rfc42)

## Dependencies
- None

## Suggested Priority
High — blocks self-service recovery
"""


def parse(text: str) -> dict[str, Any]:
    return build_workitem.parse(text.splitlines(keepends=True))


def rejection_reason(text: str) -> str:
    """Run the parser expecting it to exit 1, and return the stderr reason."""
    stderr = _capture_stderr()
    try:
        parse(text)
    except SystemExit as exit_signal:
        assert exit_signal.code == 1, f"expected exit 1, got {exit_signal.code}"
        return stderr.value()
    raise AssertionError(f"expected a rejection, got a document for:\n{text}")


def run_cli(*args: str, stdin: str = "") -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [sys.executable, str(SCRIPT), *args],
        input=stdin,
        capture_output=True,
        text=True,
        check=False,
    )


class _capture_stderr:
    """Swap sys.stderr for a buffer so rejection messages stay out of test output."""

    def __init__(self) -> None:
        self._buffer = io.StringIO()
        self._saved = sys.stderr
        sys.stderr = self._buffer

    def value(self) -> str:
        sys.stderr = self._saved
        return self._buffer.getvalue()


# --- supported constructs ---------------------------------------------------------


def test_should_shift_headings_down_one_level_when_converting() -> None:
    doc = parse("## Summary\n")
    assert doc["content"][0]["type"] == "heading"
    assert doc["content"][0]["attrs"]["level"] == 3


def test_should_clamp_heading_level_when_markdown_uses_six_hashes() -> None:
    doc = parse("###### Deep\n")
    assert doc["content"][0]["attrs"]["level"] == build_workitem.MAX_HEADING_LEVEL


def test_should_group_consecutive_bullets_into_one_list_when_parsing() -> None:
    doc = parse("- one\n- two\n")
    assert [node["type"] for node in doc["content"]] == ["bulletList"]
    assert len(doc["content"][0]["content"]) == 2


def test_should_join_consecutive_lines_when_building_a_paragraph() -> None:
    doc = parse("line one\nline two\n")
    texts = [node["text"] for node in doc["content"][0]["content"]]
    assert texts == ["line one", " ", "line two"]


def test_should_split_paragraphs_when_separated_by_a_blank_line() -> None:
    doc = parse("first\n\nsecond\n")
    assert [node["type"] for node in doc["content"]] == ["paragraph", "paragraph"]


def test_should_apply_a_code_mark_when_text_is_backticked() -> None:
    doc = parse("- Files: `src/auth.ts`\n")
    nodes = doc["content"][0]["content"][0]["content"][0]["content"]
    assert nodes[1] == {
        "type": "text",
        "text": "src/auth.ts",
        "marks": [{"type": "code"}],
    }


def test_should_apply_a_link_mark_when_text_is_a_markdown_link() -> None:
    doc = parse("See [RFC 42](https://example.com/rfc42)\n")
    node = doc["content"][0]["content"][1]
    assert node["text"] == "RFC 42"
    href = {"href": "https://example.com/rfc42"}
    assert node["marks"] == [{"type": "link", "attrs": href}]


def test_should_exempt_backticked_globs_when_checking_inline_markdown() -> None:
    doc = parse("- Files: `src/**/*.ts`\n")
    nodes = doc["content"][0]["content"][0]["content"][0]["content"]
    assert nodes[1]["text"] == "src/**/*.ts"


def test_should_keep_snake_case_identifiers_when_checking_inline_markdown() -> None:
    doc = parse("Set customfield_10016 on the work item.\n")
    assert doc["content"][0]["content"][0]["text"].endswith("work item.")


def test_should_convert_every_section_when_given_the_full_template() -> None:
    doc = parse(TEMPLATE)
    kinds = [node["type"] for node in doc["content"]]
    assert kinds == [
        "heading",
        "paragraph",
        "heading",
        "bulletList",
        "heading",
        "bulletList",
        "heading",
        "bulletList",
        "heading",
        "paragraph",
    ]
    assert doc["version"] == 1 and doc["type"] == "doc"


# --- rejected block constructs ----------------------------------------------------


def test_should_reject_code_fences_when_present() -> None:
    assert "code fence" in rejection_reason("```bash\nnpm test\n```\n")


def test_should_reject_tables_when_present() -> None:
    assert "table" in rejection_reason("| a | b |\n")


def test_should_reject_blockquotes_when_present() -> None:
    assert "blockquote" in rejection_reason("> quoted\n")


def test_should_reject_ordered_lists_when_present() -> None:
    assert "ordered list" in rejection_reason("1. first\n")


def test_should_reject_star_bullets_when_present() -> None:
    assert "bullet" in rejection_reason("* item\n")


def test_should_reject_nested_bullets_when_indented() -> None:
    assert "indented line" in rejection_reason("- top\n  - nested\n")


def test_should_reject_malformed_headings_when_hash_has_no_space() -> None:
    assert "malformed heading" in rejection_reason("##Summary\n")


def test_should_reject_empty_input_when_document_has_no_content() -> None:
    assert "empty document" in rejection_reason("\n\n")


# --- rejected inline markdown -----------------------------------------------------


def test_should_reject_bold_when_plain_text_uses_double_stars() -> None:
    assert "bold" in rejection_reason("This is **bold** text.\n")


def test_should_reject_underscore_emphasis_when_doubled() -> None:
    assert "bold or italic" in rejection_reason("This is __loud__ text.\n")


def test_should_reject_strikethrough_when_present() -> None:
    assert "strikethrough" in rejection_reason("This is ~~gone~~.\n")


def test_should_reject_italic_when_plain_text_uses_single_stars() -> None:
    assert "italic" in rejection_reason("This is *soft* text.\n")


def test_should_reject_raw_html_when_present() -> None:
    assert "raw HTML" in rejection_reason("Line with <b>html</b>.\n")


def test_should_reject_inline_markdown_when_inside_a_link_label() -> None:
    assert "bold" in rejection_reason("See [**RFC**](https://example.com)\n")


def test_should_reject_unclosed_code_spans_when_a_backtick_is_orphaned() -> None:
    assert "unclosed inline code span" in rejection_reason("Run `npm test\n")


def test_should_report_the_offending_line_number_when_rejecting() -> None:
    assert "line 3" in rejection_reason("## A\n\nThis is **bold**.\n")


# --- custom field parsing ---------------------------------------------------------


def test_should_parse_a_number_when_the_field_value_is_numeric() -> None:
    parsed = build_workitem.custom_field("customfield_10016=5")
    assert parsed == ("customfield_10016", 5)


def test_should_keep_a_string_when_the_field_value_looks_boolean() -> None:
    assert build_workitem.custom_field("cf=true") == ("cf", "true")


def test_should_parse_json_when_the_field_value_is_an_object() -> None:
    assert build_workitem.custom_field('cf={"value": "A"}') == ("cf", {"value": "A"})


def test_should_raise_when_the_field_argument_has_no_equals_sign() -> None:
    import argparse

    try:
        build_workitem.custom_field("customfield_10016")
    except argparse.ArgumentTypeError:
        return
    raise AssertionError("expected ArgumentTypeError")


# --- CLI behaviour ----------------------------------------------------------------


def test_should_emit_acli_payload_keys_when_given_work_item_flags() -> None:
    result = run_cli(
        "--project", "UN", "--type", "Task", "--summary", "S",
        "--label", "a", "--parent", "UN-1", "--assignee", "me@x.com",
        "--reporter", "you@x.com", "--field", "customfield_10016=5",
        stdin="- x\n",
    )
    assert result.returncode == 0, result.stderr
    payload = json.loads(result.stdout)
    # Keys verified against `acli jira workitem create --generate-json` (acli 1.3.36).
    assert set(payload) == {
        "projectKey",
        "type",
        "summary",
        "description",
        "labels",
        "parentIssueId",
        "assignee",
        "reporter",
        "additionalAttributes",
    }
    assert payload["additionalAttributes"] == {"customfield_10016": 5}


def test_should_omit_optional_keys_when_they_are_not_supplied() -> None:
    result = run_cli(
        "--project", "UN", "--type", "Task", "--summary", "S", stdin="- x\n"
    )
    assert set(json.loads(result.stdout)) == {
        "projectKey",
        "type",
        "summary",
        "description",
    }


def test_should_emit_a_bare_document_when_adf_only_is_set() -> None:
    result = run_cli("--adf-only", stdin="- x\n")
    assert result.returncode == 0, result.stderr
    assert set(json.loads(result.stdout)) == {"version", "type", "content"}


def test_should_reject_adf_only_when_combined_with_work_item_flags() -> None:
    result = run_cli("--adf-only", "--project", "UN", stdin="- x\n")
    assert result.returncode != 0
    assert "--adf-only cannot be combined with: --project" in result.stderr


def test_should_reject_creation_when_required_flags_are_missing() -> None:
    result = run_cli(stdin="- x\n")
    assert result.returncode != 0
    assert "--project, --type, --summary" in result.stderr


def test_should_read_the_description_from_a_file_when_a_path_is_given() -> None:
    with tempfile.TemporaryDirectory() as directory:
        path = Path(directory) / "description.md"
        path.write_text(TEMPLATE, encoding="utf-8")
        result = run_cli(str(path), "--adf-only")
    assert result.returncode == 0, result.stderr
    assert json.loads(result.stdout)["content"][0]["type"] == "heading"


def test_should_exit_one_when_the_description_has_an_unsupported_construct() -> None:
    result = run_cli("--adf-only", stdin="| a | b |\n")
    assert result.returncode == 1
    assert "unsupported construct: table" in result.stderr


def main() -> int:
    tests: list[tuple[str, Callable[[], None]]] = [
        (name, value)
        for name, value in globals().items()
        if name.startswith("test_") and callable(value)
    ]
    failures: list[str] = []
    for name, test in tests:
        try:
            test()
        except Exception as error:  # noqa: BLE001 - a runner reports every failure
            failures.append(f"FAIL {name}: {type(error).__name__}: {error}")

    for line in failures:
        print(line)
    print(f"\n{len(tests) - len(failures)}/{len(tests)} passed")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
