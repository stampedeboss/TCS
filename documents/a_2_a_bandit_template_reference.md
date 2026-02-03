# A2A Bandit Template Reference

This document is the **authoritative reference** for building, naming, and injecting A2A bandit templates used by the Flying Wrecks training framework.

It is designed to be:
- Mission Editor friendly
- Injector-safe (ID remap, merge, validation)
- Script-discoverable via prefix filtering
- Future-proof for menu logic and difficulty scaling

---

## 1. Purpose

A2A bandit templates are **data-only mission elements** (aircraft groups) that are:
- Late Activated
- Discovered dynamically by Lua/MOOSE
- Spawned, respawned, and filtered by difficulty and role

No triggers, scripts, or mission options should live in bandit templates.

---

## 2. Locked Naming Convention

All A2A bandit groups **MUST** follow this exact format:

```
BANDIT_<ROLE>_<SKILL>_<TYPE>_<PKG>[_<VAR>]
```

### Field Definitions

- **ROLE** — tactical purpose
  - `WVR` : Within Visual Range / BFM / ACM
  - `BVR` : Beyond Visual Range / intercepts
  - `MIX` : Mixed-role packages
  - `BOMBER` : Bomber or heavy intercept targets

- **SKILL** — difficulty tier
  - `A` : Average (Beginner)
  - `G` : Good (Intermediate)
  - `H` : High (Advanced)
  - `X` : Excellent (Boss)

- **TYPE** — aircraft shorthand
  - `MIG21`, `MIG23`, `MIG29`, `MIG31`
  - `SU27`, `SU30`, `SU33`
  - `M2000` (Mirage)
  - `F5`, `F14`, `JF17`

- **PKG** — package size
  - `1S`, `2S`, `4S`

- **VAR (optional)** — behavior or loadout constraint
  - `GUNS`, `FOX2`, `FOX1`, `REAR`, `HIGHALT`, `LOWALT`

---

## 3. Aircraft Roster (Approved)

This reference assumes **stock DCS only (no mods)**. Paid/official modules are allowed if installed on the server.

### Official / Stock Aircraft (no mods)
- MiG-21bis (module)
- MiG-23MLA (module)
- MiG-29 (FC3)
- Su-27 (FC3)
- Su-33 (FC3)
- J-11A (FC3)
- Mirage 2000C (module)
- F-5E (module)
- F-14 (module)
- JF-17 (module)
- Su-25 / Su-25T (base/FC3)
- A-10A / A-10C (module/FC3)
- Tu-22M3 (AI asset)
- Tu-95 (AI asset)

### Excluded (mod-only)
- MiG-31 (commonly appears as a mod, not stock)
- Su-30 (commonly appears as a mod/AI mod, not stock)

---

## 4. Authoritative Bandit Manifest

### Tier 1 — Beginner / Fundamentals

```
BANDIT_WVR_A_MIG21_1S
BANDIT_WVR_A_F5_1S
BANDIT_WVR_A_L39_1S
BANDIT_WVR_A_YAK52_1S

BANDIT_BVR_A_MIG21_2S
BANDIT_BVR_A_MIG23_2S
```

---

### Tier 2 — Intermediate / Tactical Discipline

```
BANDIT_WVR_G_MIG21_2S
BANDIT_WVR_G_MIG19_1S
BANDIT_WVR_G_F5_2S
BANDIT_WVR_G_M2000_1S

BANDIT_BVR_G_MIG29_2S
BANDIT_BVR_G_SU27_2S
BANDIT_BVR_G_J11_2S

BANDIT_MIX_G_MIG21_MIG29_2S
```

---

### Tier 3 — Advanced / Operational

```
BANDIT_WVR_H_F14_1S
BANDIT_WVR_H_M2000_2S

BANDIT_BVR_H_MIG29_4S
BANDIT_BVR_H_SU27_4S
BANDIT_BVR_H_JF17_2S

BANDIT_MIX_H_MIG21_MIG29_4S
BANDIT_MIX_H_SU27_F14_4S

BANDIT_BVR_X_SU27_4S
BANDIT_BVR_X_J11_4S
BANDIT_BVR_X_F14_2S

BANDIT_BOMBER_A_TU22M_1S
BANDIT_BOMBER_G_TU95_2S

BANDIT_WVR_A_SU25_2S
BANDIT_WVR_A_A10_1S
```

---

## 5. Mission Editor Build Standards

### Late Activation
- **ALL bandit groups must be Late Activated**

### Coalition
- Red coalition unless scenario dictates otherwise

### Altitude & Speed (Initial Waypoint)

| Role | Altitude | Speed |
|----|----|----|
| WVR | 15–20k ft | 350–420 KCAS |
| BVR | 25–35k ft | Mach 0.8–0.9 |
| MiG-31 | 40–45k ft | Mach 1.2 |
| Bomber | 25–30k ft | 300–350 KTAS |

### ROE & AI Settings
- ROE: Weapons Free
- Reaction to Threat: Evade Fire
- RTB on Bingo: OFF
- ECM: ON for H/X tiers

---

## 6. Loadout Discipline

### Beginner
- Guns + short-range IR only
- No Fox-3

### Intermediate
- Fox-2 + limited Fox-1

### Advanced
- Full doctrinal loadouts

### Boss
- Maximum realistic threat
- Long-range missiles + ECM

---

## 7. Template File Layout

Bandit templates should be split across multiple `.miz` files:

```
tpl_a2a_bandits_wvr.miz
tpl_a2a_bandits_bvr.miz
tpl_a2a_bandits_mix.miz
```

---

## 8. Injector Validation Rules

Hard fail if:
- No group starts with `BANDIT`
- Duplicate bandit group names exist
- Any bandit group is not Late Activated
- Any bandit group is not airplane category

Summary report should include:
- Total bandits injected
- Breakdown by role (WVR/BVR/MIX)
- Breakdown by tier (A/G/H/X)

---

## 9. Design Philosophy

- Names are **data contracts**
- Templates are **atomic and reusable**
- Difficulty is **selected, not rebuilt**
- Expansion never requires renaming existing assets

This document is the single source of truth for A2A bandit template design.


---

# 10. Machine-Readable Bandit Manifest (Injector Spec)

This section defines the **canonical machine-readable manifest** your injector should validate against. This mirrors the human-readable manifest exactly.

```json
{
  "bandit_prefix": "BANDIT",
  "tiers": {
    "A": "Beginner",
    "G": "Intermediate",
    "H": "Advanced",
    "X": "Boss"
  },
  "roles": ["WVR","BVR","MIX","BOMBER"],
  "packages": ["1S","2S","4S"],
  "groups": [
    "BANDIT_WVR_A_MIG21_1S",
    "BANDIT_WVR_A_F5_1S",
    "BANDIT_WVR_A_L39_1S",
    "BANDIT_WVR_A_YAK52_1S",
    "BANDIT_BVR_A_MIG21_2S",
    "BANDIT_BVR_A_MIG23_2S",

    "BANDIT_WVR_G_F5_2S",
    "BANDIT_WVR_G_MIG19_1S",
    "BANDIT_WVR_G_MIG21_2S",
    "BANDIT_WVR_G_M2000_1S",
    "BANDIT_BVR_G_J11_2S",
    "BANDIT_BVR_G_MIG29_2S",
    "BANDIT_BVR_G_SU27_2S",

    "BANDIT_MIX_G_MIG21_MIG29_2S",

    "BANDIT_WVR_H_F14_1S",
    "BANDIT_WVR_H_M2000_2S",
    "BANDIT_BVR_H_MIG29_4S",
    "BANDIT_BVR_H_SU27_4S",
    "BANDIT_BVR_H_SU30_2S",
    "BANDIT_BVR_H_JF17_2S",

    "BANDIT_MIX_H_MIG21_MIG29_4S",
    "BANDIT_MIX_H_SU27_F14_4S",

    "BANDIT_BVR_X_SU27_4S",
    "BANDIT_BVR_X_SU30_4S",
    "BANDIT_BVR_X_MIG31_2S",

    "BANDIT_WVR_A_SU25_2S",
    "BANDIT_WVR_A_A10_1S"
    "BANDIT_BOMBER_A_TU22M_1S",
    "BANDIT_BOMBER_G_TU95_2S",
  ]
}
```

Injector expectations:
- At least **one** group must exist per selected tier
- All listed groups must be Late Activated
- No unknown prefixes are allowed in bandit templates

---

# 11. Mission Editor Build Recipe (Checklist)

Use this checklist when creating **each individual bandit group**.

## Group Setup
- Category: **Airplane**
- Coalition: **Red**
- Late Activation: **ON**
- Group Name: matches manifest exactly

## Waypoint 0 (Spawn State)
- Altitude:
  - WVR: 15–20k ft
  - BVR: 25–35k ft
  - MiG-31: 40–45k ft
- Speed:
  - WVR: 350–420 KCAS
  - BVR: Mach 0.8–0.9
  - MiG-31: Mach 1.2

## AI Options
- ROE: Weapons Free
- Reaction to Threat: Evade Fire
- RTB on Bingo: OFF
- ECM: ON for H/X tiers
- EPLRS: OFF

## Loadouts
- Beginner (A): Guns + Fox-2 only
- Intermediate (G): Fox-2 + limited Fox-1
- Advanced (H): Full doctrinal
- Boss (X): Maximum realistic threat

## Formation
- 1S: Line Abreast
- 2S: Line Abreast or Fluid Four
- 4S: Tactical Spread / Wall

# 12. Loadout Profiles (Role-Based) — Reference

This section provides **recommended loadout profiles** by aircraft and role for **stock DCS only**. Exact pylons vary by module; enforce *missile families, counts, and intent*.

---

## 12.1 Global Fox-3 Policy (Locked)

Fox-3 (active radar) missiles are **allowed only in Advanced and Boss tiers**. The **difference between Advanced and Boss is AI skill level and employment quality**, not weapon availability.

| Tier | Fox-3 Allowed | AI Skill | Employment Quality |
|---|---|---|---|
| Beginner (A) | ❌ No | Average | Poor timeline discipline, late shots |
| Intermediate (G) | ❌ No | Good | Conservative shots, limited tactics |
| Advanced (H) | ✅ Yes | High | Correct timelines, coordinated shots |
| Boss (X) | ✅ Yes | Excellent | Aggressive timelines, optimal employment |

Key rule:
- **Advanced and Boss may carry the same Fox-3 weapons**
- **Boss difficulty comes from AI skill and coordination**, not extra missiles

---

## 12.2 Global Loadout Rules

- Beginner (A): gun + short-range IR only
- Intermediate (G): IR + limited SARH (Fox-1)
- Advanced (H): doctrinal mix; Fox-3 allowed where aircraft supports it
- Boss (X): same weapons as Advanced; higher AI skill, better timing, ECM enabled

---

## 12.3 WVR Default Profiles

- Guns + 2–4 IR missiles
- Avoid Fox-3 in WVR roles even if aircraft supports it
- Optional: 1 centerline tank for endurance (avoid for pure BFM)

---

## 12.4 BVR Default Profiles

- 2–4 medium-range missiles
  - Fox-1 (Intermediate)
  - Fox-3 (Advanced/Boss only)
- 2 IR missiles
- 1 fuel tank recommended

---

## 12.5 Aircraft-Specific Recommendations (Stock-Only)

### MiG-21
- WVR (A/G): 2× R-60M + gun; optional tank
- BVR (A/G): 2× R-3R or R-13M1 + 2× R-60M

### MiG-23
- BVR (A/G): 2× R-23R/ML + 2× R-60M
- WVR (A): 2× R-60M + gun

### MiG-29
- WVR (G/H): 2× R-73 + 2× R-60M (or 4× R-73)
- BVR (G): 2× R-27R/ER + 2× R-73
- BVR (H/X): same weapons; higher skill drives difficulty

### Su-27 / Su-33
- WVR (G/H): 4× R-73
- BVR (G): 2× R-27ER + 2× R-27R/ET + 2× R-73
- BVR (H/X): same weapons; superior timelines and coordination

### J-11A (FC3, Fox-3 capable)
- BVR (H/X): 2× R-77 + 2× R-27ER + 2× R-73
- BVR (G): Fox-3 **not allowed**; use R-27 family only

### Mirage 2000C
- WVR (G/H): 2× Magic II + gun
- BVR (G/H): 2× Super 530D + 2× Magic II

### F-5E
- WVR (A/G/H): 2× AIM-9 + gun; optional tank

### F-14
- WVR (H/X): 2× AIM-9 + 2× AIM-7 (avoid Phoenix for WVR lessons)
- BVR (H/X): 2× AIM-54 + 2× AIM-7 + 2× AIM-9

### JF-17
- BVR (H/X): 2× SD-10 + 2× PL-5EII
- BVR (G): Fox-3 not allowed; restrict to IR only or SARH equivalent

### Su-25 / A-10 (Humility / VID)
- Minimal: gun + 2× IR missiles (or none)

### Tu-22M / Tu-95
- Defensive only; escorts carry the threat

---

# 13. Escort Package Design Reference

Escort packages are **exact-name contract groups** referenced directly by Lua.

## Required Groups (Exact Names)
```
PACKAGE_TANKER
PACKAGE_TRANSPORT
PACKAGE_STRIKE
```

## General Rules
- Category: Airplane
- Late Activated: ON
- No triggers
- Routes are placeholders (scripts retask them)

## Recommended Aircraft

### PACKAGE_TANKER
- IL-78 or KC-135 (Red-for stand-in)
- Altitude: 25–30k ft
- Speed: 280–320 KTAS

### PACKAGE_TRANSPORT
- An-26 / Il-76
- Altitude: 20–25k ft
- Speed: 260–300 KTAS

### PACKAGE_STRIKE
- Su-24 / Su-34 / Su-25
- Altitude: 20–25k ft
- Speed: 450–500 KCAS

## Purpose
- Teaches escort geometry
- Forces timeline discipline
- Enables package-defense training

---

# 14. Automation & Scaling Guidance

- Never enable all bandit templates at once
- Rotate injected `.miz` packs per server
- Keep templates **data-only**
- All behavior lives in Lua

This completes the full A2A bandit reference and automation specification.


---

# 15. A2G Template Reference (CAS / BAI / SAM / STRIKE / JTAC)

This section defines the A2G **naming contracts**, recommended template breakdown, and injection/validation rules.

## 15.1 Locked A2G Naming Contracts

### Required (hard contract)
- JTAC group name (exact):
  - `JTAC`

### CAS ground template prefixes (discovered by prefix)
- Red: `CAS RED-1`, `CAS RED-2`, ... (prefix `CAS RED-`)
- Blue: `CAS BLUE-1`, `CAS BLUE-2`, ... (prefix `CAS BLUE-`)

### Optional but recommended future-proof prefixes
- BAI targets: `BAI TARGET-1`, ... (prefix `BAI TARGET-`)
- SAM sites: `SAM SITE-1`, ... (prefix `SAM SITE-`)
- Strike targets: `STRIKE TARGET-1`, ... (prefix `STRIKE TARGET-`)
- Maritime: `MAR-1`, ... (prefix `MAR-`)
- Surface warfare: `SUW-1`, ... (prefix `SUW-`)

## 15.2 A2G Template File Layout

Recommended `.miz` packs:

```
tpl_a2g_jtac.miz
tpl_a2g_cas_red.miz
tpl_a2g_cas_blue.miz
tpl_a2g_bai_targets.miz
tpl_a2g_sam_sites.miz
tpl_a2g_strike_targets.miz
tpl_a2g_maritime.miz
```

## 15.3 A2G Threat Layering Doctrine

Build targets as layers so training can scale:

- Layer 0: Range-only (statics, no threats)
- Layer 1: Small arms / light AAA
- Layer 2: Radar AAA + MANPADS pockets
- Layer 3: Short-range SAM (IR)
- Layer 4: Medium SAM (radar) with decoys

All threat layers should be Late Activated if they are expected to be toggled.

---

# 16. Zones & Range Contract (A2A + A2G)

Even if Lua doesn’t hard-require zones yet, standardizing them now prevents future churn.

## 16.1 Canonical Zone Names

- A2A fight bubble: `Z_A2A_FIGHT`
- A2A AI containment: `Z_A2A_LIMIT`
- A2G range box: `Z_A2G_RANGE`
- Common safe zone: `Z_COMMON_SAFE`

## 16.2 Zone Guidelines
- Zones should be large enough to avoid accidental cleanup.
- If you implement out-of-bounds deletion, always log which unit/group was removed and why.

---

# 17. Injector Validation (Code-Level Checklist)

Your injector should validate mission integrity *after* ID remap and merge.

## 17.1 Hard Fail Rules

- Loader trigger exists exactly once (Mission Start -> dofile training/init.lua)
- At least one `BANDIT*` group exists
- Required exact-name groups exist when that template is selected:
  - `PACKAGE_TANKER`, `PACKAGE_TRANSPORT`, `PACKAGE_STRIKE`
  - `JTAC`
- Bandit groups are airplane category
- All bandit groups are Late Activated
- No duplicate group names after merge

## 17.2 Suggested Python-Style Pseudocode (Concept)

```python
# NOTE: keep Lua-safe access patterns in actual implementation

def validate_required_groups(mission, required_exact, required_prefixes):
    names = collect_all_group_names(mission)

    for n in required_exact:
        if n not in names:
            raise ValueError(f"Missing required group: {n}")

    for p in required_prefixes:
        if not any(name.startswith(p) for name in names):
            raise ValueError(f"Missing required prefix match: {p}*")


def validate_bandit_groups(mission):
    bandits = collect_groups_by_prefix(mission, "BANDIT")
    if not bandits:
        raise ValueError("No BANDIT* groups found")

    for g in bandits:
        if g.category != "airplane":
            raise ValueError(f"Bandit is not airplane: {g.name}")
        if not g.late_activation:
            raise ValueError(f"Bandit not late activated: {g.name}")
```

---

# 18. Menu Mapping Guidance (Filtering by Name)

Because names are structured, menus can filter without mission churn.

## 18.1 Filters
- Role:
  - WVR: contains `_WVR_`
  - BVR: contains `_BVR_`
  - MIX: contains `_MIX_`
  - BOMBER: contains `_BOMBER_`

- Tier:
  - Beginner: contains `_A_`
  - Intermediate: contains `_G_`
  - Advanced: contains `_H_`
  - Boss: contains `_X_`

- Package size:
  - 1 ship: contains `_1S`
  - 2 ship: contains `_2S`
  - 4 ship: contains `_4S`

---

# 19. A2G Loadout & Range Scoring (Planned)

A2G training relies on **threat layering**, JTAC, and scoring zones rather than AI aircraft loadouts. Define:
- Threat compositions by layer
- JTAC laser code standard
- Scoring logic and reset triggers


A2G does not primarily rely on aircraft loadouts inside templates (players choose). Instead, define:
- Threat layer compositions
- JTAC laser code standard
- Scoring zones & triggers

This can be expanded into a dedicated A2G SOP document if desired.

