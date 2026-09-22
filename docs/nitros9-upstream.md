# NitrOS-9 upstream relationship

TurbOS's Level 1 implementation is based on the canonical NitrOS-9 project's
`main` branch at the revision pinned in `upstream/nitros9.rev`. The current pin
is commit `9ca23cda27761de0ab1a6e21a138b67a2c2bdcef` from
`https://github.com/nitros9project/nitros9.git`.

Earlier TurbOS work was traced to the obsolete `n6il/nitros9` `f256-port`
branch. That repository and branch are historical provenance only; neither is
used by the build.

## Classification

`upstream/nitros9.sources` records every known source relationship:

- `exact-code`: generated directly from the pinned NitrOS-9 checkout without a
  TurbOS delta.
- `adapted`: generated from NitrOS-9 and transformed by the checked-in
  `upstream/nitros9-turbos.patch` containing meaningful TurbOS changes.
- `rewritten`: historical ancestry remains, but the implementation has
  substantially diverged.

All TurbOS kernel assembly is materialized from NitrOS-9. The TurbOS kernel
wrapper and FIRQ implementation both use NitrOS-9's `krn.asm` as their
provenance base and are transformed into separate generated files by the patch.

The following non-kernel files are TurbOS-owned and have no direct file
counterpart in the imported NitrOS-9 set:

- `source/commands/shell.asm`
- `source/commands/sleep.asm`
- `source/include/scf.d`
- `source/include/turbo9sim.d`
- `source/include/turbos.d`

## Reproducible workflow

Fetch the pinned source and audit the boundary:

```sh
python3 scripts/nitros9-upstream.py fetch
python3 scripts/nitros9-upstream.py check
python3 scripts/nitros9-upstream.py materialize
```

The checkout is stored under `.upstream/nitros9` and is intentionally ignored
by Git. The three port Makefiles consume 16 `exact-code` and 16 `adapted`
sources from the materialized `.upstream/generated/source` directory. Only two
mapped, non-kernel files remain locally rewritten. If an
imported file is missing, or the manifest or patch changes, `make` runs the
materialization step; it never performs an implicit network fetch.
Materialization also refuses to use a checkout whose `HEAD` is not the pinned
revision.

### Adaptations

Eleven previously identified files retain functional TurbOS adaptations:

- `fchain.asm`, `fexit.asm`, `ffork.asm`, and `fnproc.asm` assemble against the
  TurbOS kernel but produce intentional behavioral differences.
- `fvmodul.asm`, `fwait.asm`, and `iocall.asm` depend on TurbOS-local symbols or
  services (`CRCAlgo`, `SetupReturn`, and `LoadBoot`, among others).
- `mfree.asm`, `procs.asm`, `ioman.asm`, and `scf.asm` depend on TurbOS's module,
  command, and definitions interfaces and cannot be replaced by changing the
  include filename alone.

Five additional kernel files are now generated from NitrOS-9 bases even though
their TurbOS patches replace substantial portions of those bases:
`fcmpnam.asm`, `fprsnam.asm`, `fsleep.asm`, `kernel.asm`, and `firq.asm`.

For an existing checkout, avoid a second clone with:

```sh
python3 scripts/nitros9-upstream.py check --checkout /path/to/nitros9
python3 scripts/nitros9-upstream.py materialize --checkout /path/to/nitros9
```

Before advancing the pin, compare the old and new NitrOS-9 revisions for every
path in the manifest. Apply upstream changes first to `exact-code` files, then
manually reconcile `adapted` and `rewritten` files. A pin update should include
the resulting source changes in the same commit.

## Upstreaming policy

Changes that fix general OS-9 behavior should be proposed to NitrOS-9 first.
Turbo9 instructions, simulator integration, the TurbOS kernel wrapper, and
TurbOS-specific ABI or memory-layout changes remain local. This keeps NitrOS-9
authoritative for shared routines without pretending the two systems are still
source-identical everywhere.
