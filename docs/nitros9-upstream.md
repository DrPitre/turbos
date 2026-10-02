# NitrOS-9 upstream relationship

TurbOS's Level 1 implementation is based on the canonical NitrOS-9 project's
feature-flag branch at the revision pinned in `upstream/nitros9.rev`. The current pin
is commit `25bdda10fa1d34bb0f58bddef4f8e3d9f96bf51f` on
`codex/level1-turbos-feature-flags` (NitrOS-9 PR #442), from
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
by Git. The three port Makefiles consume 21 `exact-code` and 12 `adapted`
sources from the materialized `.upstream/generated/source` directory. Only two
mapped, non-kernel files remain locally rewritten. If an
imported file is missing, or the manifest or patch changes, `make` runs the
materialization step; it never performs an implicit network fetch.
Materialization also refuses to use a checkout whose `HEAD` is not the pinned
revision.

### Shared kernel feature switches

All three ports include the unmodified NitrOS-9 `features.d` before defining
layout-dependent TurbOS structures. The shared switches are `_FF_MODCHECK`,
`_FF_UNIFIED_IO`, `_FF_BOOTING`, `_FF_ID`, `_FF_SPRIOR`, `_FF_SSWI`, and
`_FF_IRQ_POLL`. They default to enabled upstream; TurbOS selects its profile
before including them. The simulator profiles now use `_FF_SSWI` consistently;
`_FF_SWI` remains an upstream compatibility alias.

`ffork.asm`, `fexit.asm`, `fvmodul.asm`, and `iocall.asm` are imported unchanged.
Their feature conditionals live solely in NitrOS-9. TurbOS supplies the OS-9
spelling aliases `C$SPAC` and `BootStr` in its definitions rather than patching
these routines. The importer checks every `exact-code` file byte for byte and
rejects the wrong pinned revision. All layout-dependent build targets depend on
`features.d`, the port definitions, and the profile Makefile. The simulator
also builds a separate Init module for each profile, with optional fields
matching that kernel's layout.

`_FF_WALLTIME` and `_FF_VIRQ_POLL` still belong to TurbOS's tick generators;
they are not implemented by the upstream kernel feature header yet.

### Remaining adaptations

The shared routines above no longer have a TurbOS patch. These adaptations remain:

- `fchain.asm`, `fnproc.asm`, and `fwait.asm` retain TurbOS execution and
  scheduler differences.
- `mfree.asm`, `procs.asm`, `ioman.asm`, and `scf.asm` retain TurbOS module,
  command, and definitions interfaces.

Five additional kernel files are now generated from NitrOS-9 bases even though
their TurbOS patches replace substantial portions of those bases:
`fcmpnam.asm`, `fprsnam.asm`, `fsleep.asm`, `kernel.asm`, and `firq.asm`.

For an existing checkout, avoid a second clone with:

```sh
python3 scripts/nitros9-upstream.py check --checkout /path/to/nitros9
python3 scripts/nitros9-upstream.py materialize --checkout /path/to/nitros9
```

After PR #442 merges, the branch may be changed back to `main` with an
appropriate pin. The current pin is already available remotely.

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

## Validation for the feature-flag migration

The Lite, Core, Dev, and smoke simulator images assemble, the CoCo disk image
builds, and the Wildbits loader builds. Materialization and the exact-source
audit pass against the pinned feature-flag commit. These are build checks;
runtime boot and disabled-feature behavior still need emulator/hardware testing.
