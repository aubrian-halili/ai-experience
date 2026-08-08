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

MAX_HEADING_LEVEL = 6

INLINE = re.compile(r"`([^`]+)`|\[([^\]]+)\]\(([^)\s]+)\)")

UNSUPPORTED = [
    (re.compile(r"^\s*(```|~~~)"), "code fence"),
    (re.compile(r"^\s*\|"), "table"),
    (re.compile(r"^\s*>"), "blockquote"),
    (re.compile(r"^\s*\d+[.)]\s"), "ordered list"),
    (re.compile(r"^\s*[*+]\s"), "'*' or '+' bullet (use '- ' instead)"),
    (re.compile(r"^\s+\S"), "indented line (nested lists are not supported)"),
]


def fail(lineno, message):
    sys.stderr.write(f"build-workitem: line {lineno}: {message}\n")
    sys.exit(1)


def inline_nodes(text, lineno):
    """Split a line into ADF text nodes, applying code and link marks."""
    nodes = []
    cursor = 0
    for match in INLINE.finditer(text):
        plain = text[cursor : match.start()]
        if plain:
            nodes.append(text_node(plain, [], lineno))
        code, label, href = match.groups()
        if code is not None:
            nodes.append(text_node(code, [{"type": "code"}], lineno))
        else:
            nodes.append(text_node(label, [{"type": "link", "attrs": {"href": href}}], lineno))
        cursor = match.end()

    tail = text[cursor:]
    if tail:
        nodes.append(text_node(tail, [], lineno))

    for node in nodes:
        if "`" in node["text"] and not node.get("marks"):
            fail(lineno, "unclosed inline code span")

    if not nodes:
        fail(lineno, "no text content")
    return nodes


def text_node(text, marks, lineno):
    if not text:
        fail(lineno, "empty text node is invalid ADF")
    node = {"type": "text", "text": text}
    if marks:
        node["marks"] = marks
    return node


def parse(lines):
    content = []
    paragraph = []  # buffered plain-text lines, joined into one paragraph
    bullets = []  # buffered '- ' items as (text, lineno)

    def flush():
        nonlocal paragraph, bullets
        if paragraph:
            nodes = []
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
                                {"type": "paragraph", "content": inline_nodes(text, lineno)}
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

        for pattern, label in UNSUPPORTED:
            if pattern.match(line):
                fail(index, f"unsupported construct: {label}")

        heading = re.match(r"^(#{1,6})\s+(.*)$", line)
        if heading:
            flush()
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

        bullet = re.match(r"^-\s+(.*)$", line)
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


def custom_field(raw):
    """Parse a --field customfield_10016=5 argument. Numbers stay numbers."""
    key, sep, value = raw.partition("=")
    if not sep or not key.strip():
        raise argparse.ArgumentTypeError(f"expected KEY=VALUE, got {raw!r}")
    value = value.strip()
    try:
        return key.strip(), json.loads(value)
    except json.JSONDecodeError:
        return key.strip(), value


def build_args():
    parser = argparse.ArgumentParser(
        prog="build-workitem.py", description=__doc__, allow_abbrev=False
    )
    parser.add_argument("description", nargs="?", help="description markdown file (default: stdin)")
    parser.add_argument("--adf-only", action="store_true", help="emit the bare ADF document")
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

    if args.adf_only:
        conflicts = [
            name
            for name in ("project", "type", "summary", "parent", "assignee", "reporter")
            if getattr(args, name)
        ] + (["label"] if args.label else []) + (["field"] if args.field else [])
        if conflicts:
            parser.error(f"--adf-only cannot be combined with: {', '.join('--' + c for c in conflicts)}")
    else:
        missing = [f"--{n}" for n in ("project", "type", "summary") if not getattr(args, n)]
        if missing:
            parser.error(f"missing required argument(s): {', '.join(missing)} (or pass --adf-only)")

    return args


def main():
    args = build_args()

    if args.description:
        with open(args.description, encoding="utf-8") as handle:
            lines = handle.readlines()
    else:
        lines = sys.stdin.readlines()

    adf = parse(lines)

    if args.adf_only:
        payload = adf
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
