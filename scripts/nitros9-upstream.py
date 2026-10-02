#!/usr/bin/env python3
"""Fetch the pinned NitrOS-9 source and audit TurbOS's derived files."""

from __future__ import annotations

import argparse
import re
import shutil
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
LOCK = ROOT / "upstream" / "nitros9.rev"
MANIFEST = ROOT / "upstream" / "nitros9.sources"
PATCH = ROOT / "upstream" / "nitros9-turbos.patch"
DEFAULT_CHECKOUT = ROOT / ".upstream" / "nitros9"


def read_lock() -> dict[str, str]:
    values: dict[str, str] = {}
    for line in LOCK.read_text().splitlines():
        if line and not line.startswith("#"):
            key, value = line.split("=", 1)
            values[key] = value
    return values


def run(*args: str, cwd: Path | None = None) -> None:
    subprocess.run(args, cwd=cwd, check=True)


def fetch(checkout: Path) -> None:
    lock = read_lock()
    if not (checkout / ".git").is_dir():
        checkout.parent.mkdir(parents=True, exist_ok=True)
        run(
            "git", "clone", "--branch", lock["NITROS9_BRANCH"],
            "--single-branch", lock["NITROS9_REPOSITORY"], str(checkout),
        )
    run("git", "fetch", "origin", lock["NITROS9_BRANCH"], cwd=checkout)
    run("git", "checkout", "--detach", lock["NITROS9_REVISION"], cwd=checkout)


def semantic_lines(path: Path) -> list[str]:
    lines: list[str] = []
    for raw in path.read_text(errors="replace").splitlines():
        stripped = raw.lstrip()
        if not stripped or stripped.startswith("*") or stripped.startswith(";"):
            continue
        lines.append(re.sub(r"\s+", " ", stripped).lower())
    return lines


def mappings():
    for line in MANIFEST.read_text().splitlines():
        if line and not line.startswith("#"):
            yield line.split("|", 2)


def check(checkout: Path) -> int:
    lock = read_lock()
    if not checkout.is_dir():
        print(f"NitrOS-9 checkout not found: {checkout}", file=sys.stderr)
        print("Run this command with 'fetch' first.", file=sys.stderr)
        return 2

    revision = subprocess.check_output(
        ("git", "rev-parse", "HEAD"), cwd=checkout, text=True
    ).strip()
    if revision != lock["NITROS9_REVISION"]:
        print(f"Expected {lock['NITROS9_REVISION']}, found {revision}", file=sys.stderr)
        return 2

    failures = 0
    totals = {"exact-code": 0, "adapted": 0, "rewritten": 0}
    for relationship, local_name, upstream_name in mappings():
        local = ROOT / local_name
        generated = ROOT / ".upstream" / "generated" / local_name
        upstream = checkout / upstream_name
        comparison = generated if relationship in ("exact-code", "adapted") else local
        if not comparison.is_file() or not upstream.is_file():
            print(f"MISSING     {comparison.relative_to(ROOT)} <- {upstream_name}")
            failures += 1
            continue
        same = semantic_lines(comparison) == semantic_lines(upstream)
        actual = "exact-code" if same else relationship
        totals[actual] += 1
        if relationship == "exact-code" and comparison.read_bytes() != upstream.read_bytes():
            print(f"DRIFT       {local_name} <- {upstream_name}")
            failures += 1

    print(
        "NitrOS-9 relationship: "
        f"{totals['exact-code']} exact-code, "
        f"{totals['adapted']} adapted, {totals['rewritten']} rewritten"
    )
    return 1 if failures else 0


def materialize(checkout: Path) -> int:
    if not checkout.is_dir():
        print(f"NitrOS-9 checkout not found: {checkout}", file=sys.stderr)
        print("Run this command with 'fetch' first.", file=sys.stderr)
        return 2

    expected = read_lock()["NITROS9_REVISION"]
    revision = subprocess.check_output(
        ("git", "rev-parse", "HEAD"), cwd=checkout, text=True
    ).strip()
    if revision != expected:
        print(
            f"Refusing to materialize unpinned NitrOS-9 revision {revision}; "
            f"expected {expected}.",
            file=sys.stderr,
        )
        return 2

    destination = ROOT / ".upstream" / "generated"
    destination.mkdir(parents=True, exist_ok=True)
    copied = 0
    for relationship, local_name, upstream_name in mappings():
        if relationship not in ("exact-code", "adapted"):
            continue
        upstream = checkout / upstream_name
        if not upstream.is_file():
            print(f"Upstream source not found: {upstream}", file=sys.stderr)
            return 2
        output = destination / local_name
        output.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(upstream, output)
        copied += 1
    run(
        "git", "apply", "--whitespace=nowarn",
        "--directory=.upstream/generated", str(PATCH), cwd=ROOT,
    )
    print(f"Materialized and patched {copied} NitrOS-9 sources in {destination}")
    return check(checkout)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("command", choices=("fetch", "check", "materialize"))
    parser.add_argument("--checkout", type=Path, default=DEFAULT_CHECKOUT)
    args = parser.parse_args()
    checkout = args.checkout.resolve()
    if args.command == "fetch":
        fetch(checkout)
        return 0
    if args.command == "materialize":
        return materialize(checkout)
    return check(checkout)


if __name__ == "__main__":
    sys.exit(main())
