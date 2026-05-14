---
description: Audit a scientific computing project — does it do what it claims, is the math sound, can it be reproduced. Writes results to AUDIT.md.
---

Audit the current project (or the path given as argument). Write findings
to `AUDIT.md` in the project root. Don't change any other files unless I
confirm.

This is tuned for **scientific / numerical / data-pipeline projects** — the
kind where physics, units, conservation laws, and reproducibility matter
more than auth and i18n. Eight sections, in priority order. Don't pad.

---

## 1. Goal & implementation
The most important section. Skipping it makes the rest moot.

- One sentence describing what this project is supposed to do, in your own
  words. If you can't write it from the docs, the docs are insufficient.
- Trace the main entry point end-to-end. Write the data flow as prose:
  input → step 1 (file:line) → step 2 → ... → output.
- Does the implementation actually match the README's claims? Flag any
  feature claimed but not present, or behavior present but not documented.
- Dead claims: README mentions a script / option / dir that no longer exists.

## 2. Inventory & stale items
- One-line description per top-level directory and key file.
- Flag: multiple versions of the same artifact (which is current?), files
  unreferenced by any active code, empty dirs, `*.bak` / `_old` / `_TEMP`,
  uncommitted working files.
- Recommend **keep / archive / delete** with one-line reason.
- **Don't** recommend deleting anything modified within the last 7 days,
  referenced from another active file, or holding unique unreproducible
  data.

## 3. Reproducibility
For the most recent significant artifact: from a clean checkout, can
someone reproduce it?

- Concrete setup commands (not "install deps" — actual `pip install ...`)?
- Sample inputs committed?
- Hardcoded paths or hostnames? `~/path/to/my/data` will break for the
  next person.
- Random seeds set everywhere randomness matters (numpy, torch, dataloaders,
  CUDA ops)?
- Pinned dependency versions, or "it worked on my laptop"?
- For multi-process / multi-host runs: file-locking on shared FS? Atomic
  writes (`tmp + rename`)? Cleanup on Ctrl-C?

## 4. Physics & numerics
The meat for scientific code.

- **Units**: walk every numeric variable through every file it appears in.
  Flag implicit conversions (Pa↔MPa, °C↔K, s↔yr).
- **Sign conventions**: depth-positive-down, elevation-positive-up,
  pressure-vs-atmosphere — explicit?
- **Magic numbers**: list hardcoded literals in physics code. Flag
  duplicates with different values across files. Flag anything that should
  be a named constant.
- **Physical bounds**: saturations in [0,1], T above 0 K, mole fractions
  in [0,1]. Enforced or assumed?
- **Conservation laws**: list invariants that should hold (mass, energy,
  momentum). Tested? At minimum, "total at end ≈ total at start" check.
- **NaN / Inf risk**: `1/x` where `x` could be 0? `log(x≤0)`? `sqrt(x<0)`?
  Any one bad value poisons stats?
- **Constants provenance**: from CODATA / NIST / paper-cited, or made up?

## 5. Implementation consistency
- **Duplicate constants**: same physical constant defined in multiple
  places — different values? (We had `1028.0` Python vs `1028.1` MATLAB.)
- **Configured vs actual**: `config.json` says X, the trained/built thing
  is Y. Mismatches lie to readers.
- **Default-resolution order**: defaults in code, config file, AND wrapper
  script — document who wins.
- **Port equivalence**: same logic in two languages (e.g. MATLAB ↔ Python)
  — equivalent on a sample of inputs?
- **Stats files vs reality**: `metadata.json` claims `state_min[0]=0.1` —
  does the actual data clip to that? Spot-check.
- **Data pipeline integrity** (if applicable): train/val/test leakage in
  normalization stats? Time/index alignment of multi-source inputs?
  Filtering applied consistently across prep / train / eval?

## 6. Logging & error handling
Can you reconstruct what happened from logs alone?

- Are key decisions logged with enough context (timestep, case id, host,
  GPU)?
- Are validation/diagnostic numbers averaged over enough samples to be
  trustworthy, or is each "validation step" a single noisy sample?
- Is what was *actually* used at runtime captured: config snapshot, env
  vars, git SHA, hostname, GPU id?
- Default failure mode: **fail loudly** (raise) or **fail silently**
  (return zeros, log warning, continue)? Silent failure is the worst bug
  class.
- After a per-item failure (one case errors), does the batch continue
  cleanly or cascade?

## 7. Performance & scaling
- Bottleneck patterns: `for case in cases: heavy_io_per_case`. Could IO
  be batched or cached? (We had a 100× speedup from one big file vs
  thousands of small ones.)
- Runtime scales linearly with N (cases, timesteps, nodes)? Should it?
- Memory: any array that grows with N — does it fit at full N?

## 8. Top-N priorities
Triage list, ranked by (impact × ease). Every item must be actionable in
<1 day. No wishlists.

---

## How to write AUDIT.md
- 5-line executive summary at the top: top-3 wins, top-3 risks.
- Section findings in tables when possible — easier to scan.
- Cite file paths and line numbers for every concrete finding.
- Distinguish **observed** (you saw it) from **suspected** (you'd need to
  test).

## Cardinal rules
- Don't recommend deleting anything that has signal of being recently used.
- Don't write a wishlist.
- If a check requires running code (NaN scan, conservation check, port
  equivalence), say so — don't pretend you ran it without running it.
