# NitrOS-9 shared sources

TurbOS imports shared NitrOS-9 assembly unchanged, except for Shell, which is
generated from the pinned upstream source with conditional TurbOS adaptations.

`upstream/nitros9.rev` pins the canonical repository and commit. The current
pin is `25bdda10fa1d34bb0f58bddef4f8e3d9f96bf51f`, on
`codex/level1-turbos-feature-flags`, from
`https://github.com/nitros9project/nitros9.git`.

## Source ownership

`upstream/nitros9.sources` maps the source boundary:

- 33 `exact-code` files are imported byte for byte: the shared kernel routines
  and feature header, IOMan, SCF, Mfree, Mdir, Procs, and Sleep.
- One `conditional` file, Shell, is generated from the pinned NitrOS-9 source.
  At assembly time it selects TurbOS-specific behavior with `TURBOS`; without
  that define it uses NitrOS-9 behavior, including the `OS9:` prompt.
- Three `rewritten` files are TurbOS-owned: the kernel wrapper, kernel
  interrupt implementation, and Init. Their mappings document historical
  ancestry; they are not generated from or patched onto NitrOS-9.

Other local files implement TurbOS commands, definitions, platform hardware,
and test programs. The kernel wrapper lives in `source/kernel/kernel.asm` and
includes the unchanged routines from `.upstream/generated/source/kernel/`.
`source/kernel/firq.asm` supplies the local interrupt implementation. IOMan
also provides its own upstream interrupt services when enabled.

## Building and auditing

For a fresh checkout:

```sh
python3 scripts/nitros9-upstream.py fetch
python3 scripts/nitros9-upstream.py materialize
python3 scripts/nitros9-upstream.py check
make -C ports/coco
make -C ports/turbo9sim
make -C ports/wildbits
```

The ignored `.upstream/nitros9` checkout stores upstream history.
`.upstream/generated/source` contains copies derived from the pinned commit.
The importer reads Git objects at that commit, so working-tree edits cannot
silently enter a build. It refuses a checkout with the wrong HEAD,
removes obsolete generated sources, and audits every import byte for byte.

A shared stamp makes source generation run once per make invocation, including
forced parallel CoCo builds. Missing imported files trigger regeneration.
Builds never fetch from the network implicitly. Override `TURBOSDIR` to select
another TurbOS checkout; otherwise each port resolves its own repository root.

To use an existing upstream checkout:

```sh
python3 scripts/nitros9-upstream.py materialize --checkout /path/to/nitros9
python3 scripts/nitros9-upstream.py check --checkout /path/to/nitros9
```

## Definitions and feature switches

All ports include the unchanged upstream `features.d`. TurbOS profiles select
`_FF_MODCHECK`, `_FF_UNIFIED_IO`, `_FF_BOOTING`, `_FF_ID`, `_FF_SPRIOR`,
`_FF_SSWI`, and `_FF_IRQ_POLL`. Upstream defaults retain the complete kernel.
`_FF_WALLTIME` and `_FF_VIRQ_POLL` configure the local tick generators.

`source/include/defsfile` adapts the conventional upstream definitions entry
point to the port's `defs.d` and SCF definitions. `turbos.d` supplies aliases
for upstream character, Init, and VIRQ table names and the standard display
status codes. These definition aliases do not modify shared assembly files.

## Updating shared code

Fix shared routines in NitrOS-9. Advance the revision pin after those changes
are available there, then regenerate, audit, build, and run the affected ports.
Keep platform initialization, hardware support, and the TurbOS wrapper local.
Do not reintroduce a patch or a local copy of a shared routine.

The former `n6il/nitros9` `f256-port` source is historical provenance only.
It is not used by the build.

## Validation

The Lite, Core, Dev, and smoke simulator images, CoCo disk, and Wildbits loader
build with unchanged shared sources. Runtime checks use the Turbo9 RTL boot and
shell regressions and XRoar with a 64 KB CoCo. Physical hardware remains untested.
