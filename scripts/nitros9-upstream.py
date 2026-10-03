#!/usr/bin/env python3
"""Fetch the pinned NitrOS-9 source and audit TurbOS's derived files."""

from __future__ import annotations

import argparse
import tempfile
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
LOCK = ROOT / "upstream" / "nitros9.rev"
MANIFEST = ROOT / "upstream" / "nitros9.sources"
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


def mappings():
    for line in MANIFEST.read_text().splitlines():
        if line and not line.startswith("#"):
            relationship, local_name, upstream_name = line.split("|", 2)
            if relationship not in ("exact-code", "rewritten"):
                raise ValueError(f"Unsupported source relationship: {relationship}")
            yield relationship, local_name, upstream_name


def pinned_bytes(checkout: Path, upstream_name: str) -> bytes:
    return subprocess.check_output(
        ("git", "show", f"{read_lock()['NITROS9_REVISION']}:{upstream_name}"),
        cwd=checkout,
    )


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
    totals = {"exact-code": 0, "rewritten": 0}
    for relationship, local_name, upstream_name in mappings():
        local = ROOT / local_name
        generated = ROOT / ".upstream" / "generated" / local_name
        upstream = checkout / upstream_name
        comparison = generated if relationship == "exact-code" else local
        if not comparison.is_file() or not upstream.is_file():
            print(f"MISSING     {comparison.relative_to(ROOT)} <- {upstream_name}")
            failures += 1
            continue
        totals[relationship] += 1
        if relationship == "exact-code" and comparison.read_bytes() != pinned_bytes(checkout, upstream_name):
            print(f"DRIFT       {local_name} <- {upstream_name}")
            failures += 1

    print(
        "NitrOS-9 relationship: "
        f"{totals['exact-code']} exact-code, "
        f"{totals['rewritten']} TurbOS-owned"
    )
    return 1 if failures else 0


def populate(checkout: Path, destination: Path) -> int:
    """Copy shared sources verbatim; never apply local transformations."""
    destination.mkdir(parents=True, exist_ok=True)
    imported = {local for relationship, local, _ in mappings()
                if relationship == "exact-code"}
    # Prune old forks without removing current inputs used by other port builds.
    for stale in (destination / "source").rglob("*.asm"):
        if str(stale.relative_to(destination)) not in imported:
            stale.unlink(missing_ok=True)
    copied = 0
    for relationship, local_name, upstream_name in mappings():
        if relationship != "exact-code":
            continue
        output = destination / local_name
        output.parent.mkdir(parents=True, exist_ok=True)
        data = pinned_bytes(checkout, upstream_name)
        # Concurrent port builds must never see a partially written include.
        with tempfile.NamedTemporaryFile(dir=output.parent, delete=False) as temporary:
            temporary.write(data)
            temporary_path = Path(temporary.name)
        try:
            temporary_path.replace(output)
        finally:
            temporary_path.unlink(missing_ok=True)
        copied += 1
    return copied


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
    copied = populate(checkout, destination)
    print(f"Materialized unchanged {copied} NitrOS-9 sources in {destination}")
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
