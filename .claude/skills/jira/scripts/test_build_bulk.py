#!/usr/bin/env python3
"""Tests for build-bulk.py.

Runs two ways, because this repo has no test runner installed:

    python3 .claude/skills/jira/scripts/test_build_bulk.py   # zero dependencies
    pytest .claude/skills/jira/scripts/test_build_bulk.py    # if pytest is present
"""

import json
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Any, Callable

SCRIPT = Path(__file__).with_name("build-bulk.py")

ADF = {
    "type": "doc",
    "version": 1,
    "content": [
        {"type": "paragraph", "content": [{"type": "text", "text": "body"}]}
    ],
}


def workitem(**overrides: Any) -> dict[str, Any]:
    """A payload in the shape `acli jira workitem create --from-json` accepts."""
    payload: dict[str, Any] = {
        "projectKey": "UN",
        "type": "Task",
        "summary": "Add password reset",
        "description": ADF,
    }
    payload.update(overrides)
    return payload


def run_cli(*payloads: dict[str, Any]) -> subprocess.CompletedProcess[str]:
    with tempfile.TemporaryDirectory() as directory:
        paths = []
        for index, payload in enumerate(payloads, start=1):
            path = Path(directory) / f"{index}.json"
            path.write_text(json.dumps(payload), encoding="utf-8")
            paths.append(str(path))
        return subprocess.run(
            [sys.executable, str(SCRIPT), *paths],
            capture_output=True,
            text=True,
            check=False,
        )


def test_should_wrap_the_items_in_an_issues_array_when_given_several_payloads() -> None:
    result = run_cli(workitem(summary="One"), workitem(summary="Two"))
    assert result.returncode == 0, result.stderr
    bulk = json.loads(result.stdout)
    assert list(bulk) == ["issues"]
    assert [issue["summary"] for issue in bulk["issues"]] == ["One", "Two"]


def test_should_rename_type_to_issuetype_when_translating_a_payload() -> None:
    result = run_cli(workitem(type="Story"))
    assert result.returncode == 0, result.stderr
    issue = json.loads(result.stdout)["issues"][0]
    assert issue["issueType"] == "Story"
    assert "type" not in issue


def test_should_rename_labels_to_label_when_the_payload_carries_labels() -> None:
    result = run_cli(workitem(labels=["a", "b"]))
    assert result.returncode == 0, result.stderr
    issue = json.loads(result.stdout)["issues"][0]
    assert issue["label"] == ["a", "b"]
    assert "labels" not in issue


def test_should_preserve_the_adf_description_when_translating_a_payload() -> None:
    result = run_cli(workitem())
    assert result.returncode == 0, result.stderr
    assert json.loads(result.stdout)["issues"][0]["description"] == ADF


def test_should_emit_only_bulk_supported_keys_when_given_a_full_payload() -> None:
    result = run_cli(
        workitem(labels=["a"], parentIssueId="UN-1", assignee="me@x.com")
    )
    assert result.returncode == 0, result.stderr
    issue = json.loads(result.stdout)["issues"][0]
    # Keys verified against `acli jira workitem create-bulk --generate-json`
    # and the --from-csv column list (acli 1.3.36).
    assert set(issue) == {
        "projectKey",
        "issueType",
        "summary",
        "description",
        "label",
        "parentIssueId",
        "assignee",
    }


def test_should_exit_one_when_a_payload_carries_custom_fields() -> None:
    result = run_cli(workitem(additionalAttributes={"customfield_10016": 5}))
    assert result.returncode == 1
    assert "additionalAttributes" in result.stderr
    assert "create --from-json" in result.stderr


def test_should_exit_one_when_a_payload_carries_a_reporter() -> None:
    result = run_cli(workitem(reporter="you@x.com"))
    assert result.returncode == 1
    assert "reporter" in result.stderr


def test_should_name_the_offending_file_when_a_payload_is_unsupported() -> None:
    result = run_cli(workitem(), workitem(reporter="you@x.com"))
    assert result.returncode == 1
    assert "2.json" in result.stderr


def test_should_exit_one_when_a_payload_is_missing_a_required_key() -> None:
    incomplete = workitem()
    del incomplete["summary"]
    result = run_cli(incomplete)
    assert result.returncode == 1
    assert "summary" in result.stderr


def test_should_exit_one_when_the_payloads_span_more_than_one_project() -> None:
    result = run_cli(workitem(), workitem(projectKey="OTHER"))
    assert result.returncode == 1
    assert "project" in result.stderr.lower()


def test_should_exit_one_when_a_file_is_not_valid_json() -> None:
    with tempfile.TemporaryDirectory() as directory:
        path = Path(directory) / "broken.json"
        path.write_text("{not json", encoding="utf-8")
        result = subprocess.run(
            [sys.executable, str(SCRIPT), str(path)],
            capture_output=True,
            text=True,
            check=False,
        )
    assert result.returncode == 1
    assert "broken.json" in result.stderr


def test_should_exit_two_when_given_no_payload_files() -> None:
    result = subprocess.run(
        [sys.executable, str(SCRIPT)], capture_output=True, text=True, check=False
    )
    assert result.returncode == 2


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
