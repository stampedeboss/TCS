# TCS Echelon & Scaling Reference

This document defines the Echelon system used by the Theater Control System (TCS) to determine force composition, unit counts, and AI difficulty.

---

## 1. The Echelon Table

Echelons represent the size and complexity of a spawned force. In most triggers, providing an echelon is optional; if omitted, the system defaults to the echelon mapped to the session's current **Difficulty Level**.

| Echelon | Category | Typical Unit Count (Ground) | Typical Sortie Size (Air) | Difficulty Mapping |
| :--- | :--- | :--- | :--- | :--- |
| **PLATOON** | Ground | 4–6 Units | N/A | Beginner (A) |
| **COMPANY** | Ground | 12–18 Units | N/A | Standard (G) |
| **BATTALION** | Ground | 30–50 Units | N/A | Advanced (H) |
| **BRIGADE** | Ground | 80+ Units | N/A | Expert (X) |
| **SECTION** | Air | N/A | 2 Aircraft | Beginner / Standard |
| **SQUADRON** | Air | N/A | 4–12 Aircraft | Advanced / Expert |

---

## 2. Ground Force Scaling (A2G)

For Ground operations (BAI, CAS, SEAD, Strike), scaling is determined by the **Base Composition** multiplied by the **Echelon Factor**.

### Scaling Logic
1.  **Catalog Lookup**: The system selects a composition template (e.g., `MECH_CORE`).
    *   **Unit Mixing**: If a category (e.g., `INFANTRY`) is used, the system automatically mixes available variants for that category.
2.  **Multiplier Application**: 
    *   `PLATOON`: 1.0x Base
    *   `COMPANY`: 3.0x Base
    *   `BATTALION`: 9.0x Base
    *   `BRIGADE`: 27.0x Base
3.  **Absolute Counts**: If using `DeployCustom` with a specific composition array, the multipliers are ignored and the exact unit counts provided are spawned.

---

## 3. Air Force Scaling (A2A)

A2A scaling is dynamic and primarily driven by the **number of players** in the active Session and the **Difficulty Ratio**.

### The Scaling Formula
`Desired Aircraft = ceil(Player Count * Difficulty Ratio)`

### Difficulty Ratios
| Tier | Label | Ratio | Logic |
| :--- | :--- | :--- | :--- |
| **A** | Beginner | **0.5** | 1 Bandit per 2 Players |
| **G** | Standard | **1.0** | 1v1 (Equal numbers) |
| **H** | Advanced | **1.0** | 1v1 (Higher quality/skill) |
| **X** | Expert | **1.0** | 1v1 (Elite skill/max loadout) |

*Note: A2A scaling focuses on maintaining a manageable "workload" per pilot rather than overwhelming numbers, with difficulty primarily increasing via aircraft type and AI skill.*

---

## 4. Difficulty Mapping

When a task is started without an explicit echelon (e.g., via the F10 menu), the `TCS.ResolveDifficulty` helper maps the Session's difficulty to a specific echelon name.

*   **Beginner (A)** → `PLATOON` / `1S` (Single Ship)
*   **Standard (G)** → `COMPANY` / `2S` (Section)
*   **Advanced (H)** → `BATTALION` / `4S` (Division)
*   **Expert (X)** → `BRIGADE` / `4S+`

---

## 5. The Deploy API & Smart Parameters

The TCS API uses `Deploy` functions (e.g., `DeployGroundForces`, `DeploySAM`, `DeployCustom`) that accept a flexible, human-readable parameters table.

### The `forceSize` Smart Parameter
Instead of memorizing separate keys for echelons, unit types, and exact counts, you can pass them all through the `forceSize` property:

*   **Standard Echelon (String)**: Scales the doctrinal blueprint.
```lua
DeployGroundForces({ anchor = "Point_Alpha", forceSize = "BRIGADE" })
```
*   **Specific System (String)**: Bypasses random selection and requests a specific unit.
```lua
DeploySAM({ anchor = "Target_Zone", forceSize = "SA-10" })
```
*   **System + Skill Tier (Tuple)**: Specifies both the system and the difficulty tier.
```lua
DeploySAM({ anchor = "Target_Zone", forceSize = {"SA-15", "X"} })
```
*   **Custom Platoon Layout (Array of Tuples)**: Used with `DeployCustom` to specify exact categories and counts.
```lua
DeployCustom({
    anchor = "Defense_Line",
    forceSize = { {"ARMOR", 4}, {"INFANTRY", 12} }
})
```

### Via Zone Properties
If the `anchor` is a Trigger Zone, setting a `maxnm` or specific composition attributes in the Mission Editor's **Zone Properties** can influence the density and placement of units, though the total count remains bound to the Echelon logic unless using `TriggerSystemSpawn`.

---

## 6. Performance Considerations
*   **Brigade** level spawns can exceed 100 units (including reinforcements). Use sparingly on servers with high player counts to maintain frame rates.
*   **A2A Intercepts** are hard-capped at 4 aircraft per wave by default to prevent AI pathfinding congestion.