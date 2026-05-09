# TCS Unified Catalog Design Specification

## Purpose
The TCS Catalog defines **map-agnostic, late-activation capable combat objects** that can be dynamically spawned and controlled by TCS modules (A2A, A2G, MAR, SUW, etc.).  
It is **foundational** and not tied to any single mission, map, or scenario.

The catalog is:
- **Consumed by runtime systems**
- **Shared across all maps**

---

## Design Principles

1. **Map Agnostic**
   - No coordinates stored
   - No preplanned routes
   - No reliance on terrain-specific names

2. **Late Activation Only**
   - All catalog entries must support late activation
   - Waypoints, routes, and behavior are injected post-spawn

3. **Domain Independent**
   - Same schema supports:
     - AIR
     - LAND
     - SEA

4. **Behavior is Configurable Post-Spawn**
   - Direction
   - Speed
   - Alert state
   - ROE
   - Tasking
   - Waypoints

---

## Core Object Schema (Conceptual)

Each catalog entry represents a **group template**, not a single unit.

### Required Fields

| Field | Description |
|------|-------------|
| `id` | Unique catalog identifier |
| `name` | Human-readable name |
| `domain` | AIR / LAND / SEA |
| `mobile` | true / false |
| `group_size` | Min / Max units |
| `late_activation` | Always true |
| `unit_types` | One or more unit type names |
| `threat` | Threat classification |
| `skill_profile` | Skill scaling category |
| `spacing_class` | Formation spacing category |
| `speed_class` | Movement speed category |
| `range_class` | Engagement / intercept range |
| `fire_width_class` | Width of fire / engagement |
| `altitude_class` | Ground / Low / Medium / High |
| `adjustable` | Post-spawn adjustable flags |

---

## Domain Definitions

### LAND
- Tanks
- IFVs
- APCs
- Infantry
- SAM / AAA

### SEA
- Patrol boats
- Frigates
- Destroyers
- Carriers (non-player controlled)

### AIR
- Fighters
- Bombers
- Transports
- Helicopters
- AWACS / Tankers

---

## Mobility Categories

| Category | Description |
|--------|-------------|
| `STATIC` | Does not move |
| `WALKING` | Infantry movement |
| `TRACKED` | Armor |
| `WHEELED` | Trucks / APCs |
| `NAVAL_SLOW` | Ships |
| `AIR_FAST` | Fighters |
| `AIR_SLOW` | Transports / helos |

---

## Threat Classification

Threat types describe **what this object threatens**, not what threatens it.

Examples:
- `INF`
- `ARMOR`
- `SAM_SHORT`
- `SAM_MEDIUM`
- `SAM_LONG`
- `AAA`
- `NAVAL_SURFACE`
- `AIR_FIGHTER`
- `AIR_SUPPORT`

Threat attributes:
- Directional or omni
- Max engagement range
- Engagement altitude envelope

---

## Skill Levels

Skill is **relative**, not DCS AI skill names.

| Level | Meaning |
|------|--------|
| 1 | Poor / conscript |
| 2 | Basic |
| 3 | Trained |
| 4 | Veteran |

Used by:
- A2A spawn sizing
- A2G force density
- Reaction time
- ROE aggressiveness

---

## Spacing & Pattern Classes

### Spacing Classes
- `TIGHT`
- `PLATOON`
- `COMPANY`
- `COLUMN`
- `DISPERSED`

### Pattern Classes
- `ROW`
- `GRID`
- `STAR`
- `BOX`
- `CROSS`
- `COLUMN`
- `RANDOM`

Patterns are **applied at spawn time**, not stored as coordinates.

---

## Speed Classes

Speed is categorical, resolved at runtime.

Examples:
- `STATIC`
- `WALK`
- `SLOW`
- `CRUISE`
- `FAST`

Actual speed values are defined in runtime configuration.

---

## Adjustable Flags

Each catalog entry defines what can be changed after spawn:

```lua
adjustable = {
  speed = true,
  direction = true,
  route = true,
  alert_state = true,
  roe = true,
  tasking = true
}
```

---

## Versioning

- Catalogs are versioned (e.g. `catalog_v1.lua`)
- Runtime systems choose compatible versions

---

## Consumers

The catalog feeds:
- A2A Dynamic Spawn
- A2G Range / BAI / CAS
- MAR / SUW
- Campaign / Session logic
- Future logistics & resupply

---

## Non-Goals (Explicit)

- No mission scoring
- No map-specific logic
- No hard-coded waypoints
- No editor-time placement

---

## Status

Schema **LOCKED**  
Enhancements allowed only if backward compatible.
