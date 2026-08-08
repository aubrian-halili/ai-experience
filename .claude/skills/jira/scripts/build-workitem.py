#!/usr/bin/env python3
"""Build an `acli jira workitem create --from-json` payload from a description file.

The description body is converted to Atlassian Document Format (ADF). This is
deliberately NOT a general markdown converter — it supports exactly the constructs
the /jira description template produces, and fails loudly on anything else rather
than emitting a document that renders wrongly in Jira:

  '## Heading'    -> heading, level = leading '#' count + 1 (clamped to 6)
  '- item'        -> bulletList > listItem > paragraph
  'plain text'    -> paragraph (consecutive lines join into one paragraph)
  '`code`'        -> inline text carrying a code mark
  '[label](url)'  -> inline text carrying a link mark

Rejection covers both block constructs (code fences, tables, ordered lists, nested
bullets, blockquotes) and inline markdown ADF has no mark for here ('**bold**',
'__x__', '~~strike~~', '*italic*', raw HTML). Inline checks skip anything already
inside a code span, so `src/**/*.ts` in backticks is fine. Single underscores are
NOT treated as italic — snake_case identifiers are far more common in ticket text.

Usage:
  build-workitem.py DESCRIPTION.md --project UN --type Task --summary "..." \
      [--label a --label b] [--parent UN-1] [--assignee me@x.com] \
      [--field customfield_10016=5] > workitem.json
  build-workitem.py DESCRIPTION.md --adf-only > description.json

Payload keys match `acli jira workitem create --generate-json`. Only keys that were
actually supplied are emitted. --adf-only emits the bare ADF document instead, for
use with --description-file (e.g. when updating an existing work item).

Exit codes:
  0  valid JSON on stdout
  1  unsupported construct, empty document, or bad arguments; reason on stderr
"""

import argparse
import json
import re
import sys
from typing import Any, NoReturn

Json = dict[str, Any]

MAX_HEADING_LEVEL = 6

HEADING = re.compile(r"^(#{1,6})\s+(.*)$")
BULLET = re.compile(r"^-\s+(.*)$")
INLINE = re.compile(r"`([^`]+)`|\[([^\]]+)\]\(([^)\s]+)\)")

# Block constructs the template never produces. Emitting a best-effort ADF node for
# these would quietly change what the ticket says, so they are refused instead.
UNSUPPORTED_BLOCK: list[tuple[re.Pattern[str], str]] = [
    (re.compile(r"^\s*(```|~~~)"), "code fence"),
    (re.compile(r"^\s*\|"), "table"),
    (re.compile(r"^\s*>"), "blockquote"),
    (re.compile(r"^\s*\d+[.)]\s"), "ordered list"),
    (re.compile(r"^\s*[*+]\s"), "'*' or '+' bullet (use '- ' instead)"),
    (re.compile(r"^\s+\S"), "indented line (nested lists are not supported)"),
]

# Inline markdown with no ADF mark in this converter. Checked only against plain
# segments — text already claimed by a code span is exempt — because without this
# the markers survive into the document and Jira renders them as literal characters,
# which is the exact failure this script exists to prevent.
UNSUPPORTED_INLINE: list[tuple[re.Pattern[str], str]] = [
    (re.compile(r"\*\*"), "bold ('**')"),
    (re.compile(r"__"), "bold or italic ('__')"),
    (re.compile(r"~~"), "strikethrough ('~~')"),
    (re.compile(r"\*\S[^*]*\*"), "italic ('*') — wrap globs in backticks"),
    (re.compile(r"</?[a-zA-Z][^>]*>"), "raw HTML tag"),
]


def fail(lineno: int, message: str) -> NoReturn:
    sys.stderr.write(f"build-workitem: line {lineno}: {message}\n")
    sys.exit(1)


def text_node(text: str, marks: list[Json], lineno: int) -> Json:
    """Build an ADF text node verbatim, for content that is literal by definition."""
    if not text:
        fail(lineno, "empty text node is invalid ADF")
    node: Json = {"type": "text", "text": text}
    if marks:
        node["marks"] = marks
    return node


def checked_text_node(text: str, marks: list[Json], lineno: int) -> Json:
    """Build a text node from prose, refusing markdown that would render literally."""
    if "`" in text:
        fail(lineno, "unclosed inline code span")
    for pattern, label in UNSUPPORTED_INLINE:
        if pattern.search(text):
            fail(lineno, f"unsupported inline markdown: {label}")
    return text_node(text, marks, lineno)


def inline_nodes(text: str, lineno: int) -> list[Json]:
    """Split a line into ADF text nodes, applying code and link marks."""
    nodes: list[Json] = []
    cursor = 0
    for match in INLINE.finditer(text):
        plain = text[cursor : match.start()]
        if plain:
            nodes.append(checked_text_node(plain, [], lineno))
        code, label, href = match.groups()
        if code is not None:
            nodes.append(text_node(code, [{"type": "code"}], lineno))
        else:
            link = {"type": "link", "attrs": {"href": href}}
            nodes.append(checked_text_node(label, [link], lineno))
        cursor = match.end()

    tail = text[cursor:]
    if tail:
        nodes.append(checked_text_node(tail, [], lineno))

    if not nodes:
        fail(lineno, "no text content")
    return nodes


def parse(lines: list[str]) -> Json:
    content: list[Json] = []
    paragraph: list[tuple[str, int]] = []  # buffered plain lines, joined into one
    bullets: list[tuple[str, int]] = []  # buffered '- ' items as (text, lineno)

    def flush() -> None:
        nonlocal paragraph, bullets
        if paragraph:
            nodes: list[Json] = []
            for text, lineno in paragraph:
                if nodes:
                    nodes.append({"type": "text", "text": " "})
                nodes.extend(inline_nodes(text, lineno))
            content.append({"type": "paragraph", "content": nodes})
            paragraph = []
        if bullets:
            content.append(
                {
                    "type": "bulletList",
                    "content": [
                        {
                            "type": "listItem",
                            "content": [
                                {
                                    "type": "paragraph",
                                    "content": inline_nodes(text, lineno),
                                }
                            ],
                        }
                        for text, lineno in bullets
                    ],
                }
            )
            bullets = []

    for index, raw in enumerate(lines, start=1):
        line = raw.rstrip("\n").rstrip()

        if not line.strip():
            flush()
            continue

        for pattern, label in UNSUPPORTED_BLOCK:
            if pattern.match(line):
                fail(index, f"unsupported construct: {label}")

        heading = HEADING.match(line)
        if heading:
            flush()
            # Jira renders the work item title as the document's top-level heading, so
            # every description heading shifts down one level: the template's '##'
            # becomes ADF level 3 and stays subordinate to the title instead of
            # competing with it.
            level = min(len(heading.group(1)) + 1, MAX_HEADING_LEVEL)
            text = heading.group(2).strip()
            if not text:
                fail(index, "heading has no text")
            content.append(
                {
                    "type": "heading",
                    "attrs": {"level": level},
                    "content": inline_nodes(text, index),
                }
            )
            continue

        if line.startswith("#"):
            fail(index, "malformed heading: expected '#' markers, a space, then text")

        bullet = BULLET.match(line)
        if bullet:
            if paragraph:
                flush()
            text = bullet.group(1).strip()
            if not text:
                fail(index, "bullet has no text")
            bullets.append((text, index))
            continue

        if bullets:
            flush()
        paragraph.append((line, index))

    flush()

    if not content:
        sys.stderr.write("build-workitem: input produced an empty document\n")
        sys.exit(1)

    return {"version": 1, "type": "doc", "content": content}


def custom_field(raw: str) -> tuple[str, Any]:
    """Parse a `--field customfield_10016=5` argument.

    Values opening with '{' or '[' are parsed as JSON, because some Jira custom fields
    take structured values — acli's own --generate-json template shows the
    `{"value": "..."}` shape. Anything else becomes a number when it parses as one and
    a plain string otherwise, so a field whose legitimate value is the word "true" is
    not silently coerced into a boolean.
    """
    key, sep, value = raw.partition("=")
    key = key.strip()
    if not sep or not key:
        raise argparse.ArgumentTypeError(f"expected KEY=VALUE, got {raw!r}")

    value = value.strip()
    if value[:1] in ("{", "["):
        try:
            return key, json.loads(value)
        except json.JSONDecodeError as error:
            raise argparse.ArgumentTypeError(
                f"invalid JSON value for {key}: {error}"
            ) from error

    for cast in (int, float):
        try:
            return key, cast(value)
        except ValueError:
            continue
    return key, value


def build_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        prog="build-workitem.py", description=__doc__, allow_abbrev=False
    )
    parser.add_argument(
        "description", nargs="?", help="description markdown file (default: stdin)"
    )
    parser.add_argument(
        "--adf-only", action="store_true", help="emit the bare ADF document"
    )
    parser.add_argument("--project", help="project key, e.g. UN")
    parser.add_argument("--type", help="work item type, case sensitive, e.g. Task")
    parser.add_argument("--summary", help="work item summary/title")
    parser.add_argument("--label", action="append", default=[], help="repeatable")
    parser.add_argument("--parent", help="parent work item ID")
    parser.add_argument("--assignee", help="assignee email or account ID")
    parser.add_argument("--reporter", help="reporter email or account ID")
    parser.add_argument(
        "--field",
        action="append",
        default=[],
        type=custom_field,
        metavar="KEY=VALUE",
        help="custom field, e.g. customfield_10016=5 (repeatable)",
    )

    args = parser.parse_args()

    exclusive = (
        "project",
        "type",
        "summary",
        "parent",
        "assignee",
        "reporter",
        "label",
        "field",
    )
    if args.adf_only:
        conflicts = [f"--{name}" for name in exclusive if getattr(args, name)]
        if conflicts:
            parser.error(f"--adf-only cannot be combined with: {', '.join(conflicts)}")
    else:
        required = ("project", "type", "summary")
        missing = [f"--{name}" for name in required if not getattr(args, name)]
        if missing:
            parser.error(
                f"missing required argument(s): {', '.join(missing)} "
                "(or pass --adf-only)"
            )

    return args


def main() -> None:
    args = build_args()

    if args.description:
        with open(args.description, encoding="utf-8") as handle:
            lines = handle.readlines()
    else:
        lines = sys.stdin.readlines()

    adf = parse(lines)

    if args.adf_only:
        payload: Json = adf
    else:
        payload = {
            "projectKey": args.project,
            "type": args.type,
            "summary": args.summary,
            "description": adf,
        }
        if args.label:
            payload["labels"] = args.label
        if args.parent:
            payload["parentIssueId"] = args.parent
        if args.assignee:
            payload["assignee"] = args.assignee
        if args.reporter:
            payload["reporter"] = args.reporter
        if args.field:
            payload["additionalAttributes"] = dict(args.field)

    json.dump(payload, sys.stdout, indent=2, ensure_ascii=False)
    sys.stdout.write("\n")


if __name__ == "__main__":
    main()
