#!/usr/bin/env python3
"""Merge single work item payloads into an `acli jira workitem create-bulk` payload.

Input is one or more files in the shape `build-workitem.py` emits — the shape
`acli jira workitem create --from-json` accepts. Output is the create-bulk shape,
which is NOT the same schema:

  type        -> issueType
  labels      -> label
  (wrapper)   -> {"issues": [...]}

create-bulk supports a strict subset of the single-create fields. Its
`--generate-json` example plus its `--from-csv` column list document exactly
seven: summary, projectKey, issueType, description, label, parentIssueId,
assignee. Anything else a payload carries — `additionalAttributes` (story points)
or `reporter` — would be dropped in transit, so this script refuses the batch and
names the file instead of creating tickets that silently lose fields.

Usage:
  build-bulk.py TICKET.json [TICKET.json ...] > bulk.json

Exit codes:
  0  valid JSON on stdout
  1  unreadable file, unsupported field, missing required field, or mixed projects
  2  bad arguments
"""

import argparse
import json
import sys
from pathlib import Path
from typing import Any, NoReturn

Json = dict[str, Any]

# Single-create key -> create-bulk key. Keys absent from this map are unsupported.
BULK_KEYS = {
    "projectKey": "projectKey",
    "type": "issueType",
    "summary": "summary",
    "description": "description",
    "labels": "label",
    "parentIssueId": "parentIssueId",
    "assignee": "assignee",
}

REQUIRED_KEYS = ("projectKey", "type", "summary")

# Why each unsupported field matters, so the error tells the user what to do about it.
UNSUPPORTED_REASON = {
    "additionalAttributes": "custom fields (e.g. story points) are not part of the "
    "create-bulk schema",
    "reporter": "reporter is not part of the create-bulk schema",
}


def fail(path: Path, message: str) -> NoReturn:
    sys.stderr.write(f"build-bulk: {path.name}: {message}\n")
    sys.exit(1)


def load(path: Path) -> Json:
    try:
        raw = path.read_text(encoding="utf-8")
    except OSError as error:
        fail(path, f"cannot read file: {error.strerror}")
    try:
        payload = json.loads(raw)
    except json.JSONDecodeError as error:
        fail(path, f"not valid JSON: {error.msg} at line {error.lineno}")
    if not isinstance(payload, dict):
        fail(path, "expected a single work item object")
    return payload


def translate(payload: Json, path: Path) -> Json:
    """Map one single-create payload onto the create-bulk schema, or refuse it."""
    missing = [key for key in REQUIRED_KEYS if not payload.get(key)]
    if missing:
        fail(path, f"missing required field(s): {', '.join(missing)}")

    for key in payload:
        if key not in BULK_KEYS:
            reason = UNSUPPORTED_REASON.get(key, "not part of the create-bulk schema")
            fail(
                path,
                f"'{key}' cannot be bulk-created — {reason}. Create this ticket on "
                "its own with `acli jira workitem create --from-json` instead.",
            )

    return {BULK_KEYS[key]: value for key, value in payload.items()}


def build_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        prog="build-bulk.py", description=__doc__, allow_abbrev=False
    )
    parser.add_argument(
        "tickets",
        nargs="+",
        metavar="TICKET.json",
        help="work item payload file, as emitted by build-workitem.py",
    )
    return parser.parse_args()


def main() -> None:
    args = build_args()

    issues: list[Json] = []
    for name in args.tickets:
        path = Path(name)
        issues.append(translate(load(path), path))

    # A single create-bulk call cannot span projects; catching it here beats a
    # partial batch where the first few tickets landed and the rest errored.
    projects = {issue["projectKey"] for issue in issues}
    if len(projects) > 1:
        sys.stderr.write(
            "build-bulk: tickets span more than one project "
            f"({', '.join(sorted(projects))}); bulk-create one project at a time\n"
        )
        sys.exit(1)

    json.dump({"issues": issues}, sys.stdout, indent=2, ensure_ascii=False)
    sys.stdout.write("\n")


if __name__ == "__main__":
    main()
