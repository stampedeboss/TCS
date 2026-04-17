# Theater Control System (TCS) API Reference

This document provides the authoritative documentation for the global functions available within the TCS framework. These functions are exposed via `core/theater_api.lua` and are designed to be called from the DCS Mission Editor (via **DO SCRIPT** actions) or from external Lua scripts to manage a dynamic, persistent theater.

**Usage Pattern**: All global trigger functions now accept a single table of parameters. This allows you to specify only the values you need, with the system providing sensible defaults for others.

---

## 1. Ground Entity Triggers
These functions populate the theater by deploying ground entities. The API uses "Entity Nomenclature" rather than "Mission Nomenclature". You ask the system to deploy forces, and the Architect determines how and what to build based on the supplied mission details.

### `DeployGroundForces`
Deploys a mobile ground force to support a BAI or CAS mission. Passing a `friendlyCoalition` parameter provides context to the Architect, instructing it to build an opposing friendly force for a Troops in Contact (CAS) scenario.
**Parameters Table Keys**:
*   `anchor` (string|table): Target trigger zone name or MOOSE `COORDINATE`.
*   `echelon` (string): Force size (e.g., `"PLATOON"`, `"COMPANY"`, `"BATTALION"`, `"BRIGADE"`). Default: `"COMPANY"`.
*   `minNm` (number, optional): Minimum distance in NM from the objective to spawn.
*   `maxNm` (number, optional): Maximum distance in NM from the objective to spawn.
*   `coalition` (number, optional): `coalition.side.RED` (default) or `BLUE`.
*   `respawn` (boolean, optional): If `true`, the task recreates itself when cleared or timed out.
*   `duration` (number, optional): Lifetime of the task in seconds.
*   `respawnDelay` (number, optional): Delay in seconds before recreation (default 300).
*   `reinforce` (boolean, optional): If `true`, allows AI reinforcements from the nearest base when routed.
*   `skill` (string, optional): Difficulty Tier override (`"A"`, `"G"`, `"H"`, `"X"`).
*   `friendlyCoalition` (number, optional): If provided, spawns an opposing friendly force engaged in combat with the enemy.
*   `ingressHdg` (number, optional): The bearing from the objective to the spawn location (e.g., 0 spawns units to the North).
*   `ingressArc` (number, optional): Total width of the arc in degrees. Defaults to 180 if `ingressHdg` is provided.

### `DeployFacility`
Deploys fixed infrastructure and defending units for a Strike mission.
**Parameters Table Keys**: (Same as `DeployGroundForces` except `reinforce` is not supported). Supports `skill`.

### `DeployAirDefenses`
Deploys a Short Range Air Defense (SHORAD) network (AAA/IR/Mobile Radar) to support SEAD/DEAD. For Strategic/Heavy SAMs, use `DeploySAM`.
**Parameters Table Keys**: (Same as `DeployGroundForces`). Default Echelon: `"PLATOON"`. Supports `skill`.

---

## 2. Air System Triggers
Creates persistent air entities relative to geographical zones. Bandits will automatically ingress from the direction of their nearest friendly airbase.

### `DeployAirPatrol`
Deploys a Combat Air Patrol over a zone.
**Parameters Table Keys**: `anchor`, `echelon` (Default: `"SQUADRON"`), `coalition`, `respawn`, `duration`, `respawnDelay`, `skill`.

### `DeployAirSweep`
Deploys an offensive air sweep through a zone.
**Parameters Table Keys**: (Same as `DeployAirPatrol`). Supports `skill`.

---

## 3. Dynamic SAM (DSAM) Triggers
Creates doctrinal SAM sites with specific compositions based on the selected type and difficulty.

### `DeploySAM`
Spawns a specialized SAM site (e.g., SA-2, SA-6, Patriot) using directional spawning.
**Parameters Table Keys**:
*   `samType` (string): The SAM key (e.g., `"SA2"`, `"SA6"`, `"SA11"`).
*   `anchor` (string|table): Objective zone or coordinate.
*   `echelon` (string): Defaults to `"PLATOON"`.
*   `minNm` / `maxNm` (numbers): Spawn radius constraints.
*   `coalition` (number): Side to spawn on.
*   `skill` (string): Difficulty Tier override (`"A"`, `"G"`, `"H"`, `"X"`).
*   `silent` (number, optional): Distance in NM to activate radar. If -1 or not provided, radar is active on spawn.
*   `ingressHdg` (number, optional): Overrides the tactical arrival direction.
*   `ingressArc` (number, optional): Breadth of the spawn randomization arc (default 180).

#### Mobile vs. Fixed Behavior
The system distinguishes between **Strategic (Fixed)** and **Tactical (Mobile)** sites:
*   **Fixed Sites**: (SA-2, SA-3, SA-5, SA-10, Patriot) remain at their spawn location until destroyed.
*   **Mobile Sites**: (SA-6, SA-11, SA-8, SA-15, SA-19, SA-22) possess the **Leapfrog** capability. 

If a mobile SAM is active during a mission victory (e.g., a BAI task in the same session is completed), the mobile SAM will automatically re-deploy to the objective center to establish a new defensive perimeter.

#### Directional Spawning Logic
For SAM sites, the system calculates a tactical placement to simulate a defensive screen:
1.  **Vector Calculation**: Finds the nearest friendly airbase (relative to the SAM's coalition) to the objective `anchor`.
2.  **Placement**: Translates the site center from the `anchor` towards that airbase by a distance between `minNm` and `maxNm`. If distances are not provided, it defaults to the SAM's maximum engagement range plus a tactical buffer.
3.  **Orientation**: The entire SAM site is rotated to face back towards the objective/ingress path (180° opposite the arrival vector), ensuring radars and launchers are properly oriented toward the expected threat.
4.  **Manual Override**: Using `ingressHdg` forces the site to spawn at a specific bearing from the objective (e.g., `ingressHdg = 180` spawns the SAM South of the objective, regardless of airbase locations).

#### Skill & AI Behavior Impact
The `skill` parameter (Tier A, G, H, X) directly influences how SAMs and SEAD threats operate:
*   **Reaction Time**: Higher tiers have larger `maxDist` engagement values in their radar tasks, causing them to lock and fire much sooner.
*   **ROE (Rules of Engagement)**: Tier A units use "Open Fire" logic (hesitation), while Tiers G-X use "Weapon Free".
*   **Evasion**: Tier A units use "Passive Defense". Tier X units use "Bypass and Escape", making them much harder to hit with anti-radiation missiles or cluster bombs as they will actively maneuver to survive.
*   **AI Skill**: Maps to DCS internal levels: Average (A), Good (G), High (H), and Excellent (X).

---

## 4. Maritime & Naval Triggers
Creates maritime scenarios ranging from pure combatants to ambient civilian traffic.

### `DeployBattleGroup`
Spawns a Naval Battle Group / Surface Action Group (SAG) of warships in tactical formations (Diamond/Line Ahead) that advance on an objective.
**Parameters Table Keys**: `anchor`, `echelon`, `minNm`, `maxNm`, `coalition`, `skill`, `ingressHdg`, `ingressArc`.

### `DeployConvoy`
Spawns a linear convoy of civilian cargo and transport ships **led by a Naval combatant**. 
**Parameters Table Keys**: `anchor`, `count` (Default: 4), `minNm`, `maxNm`, `coalition`, `skill`, `ingressHdg`, `ingressArc`.

### `DeployTraffic`
Scatters ambient civilian ships over a large radius, **interspersed with Naval combatants** hiding among the traffic. Excellent for visual identification and ROE training.
**Parameters Table Keys**: `anchor`, `count` (Default: 8), `minNm`, `maxNm`, `coalition`, `skill`, `ingressHdg`, `ingressArc`.

### `DeployCivilian`
Scatters purely neutral, unarmed civilian traffic. Their ROE is forced to `WEAPON_HOLD` and they belong to `coalition.side.NEUTRAL`.
**Parameters Table Keys**: `anchor`, `count` (Default: 5), `minNm`, `maxNm`, `ingressHdg`, `ingressArc`.

---

## 5. Advanced Custom Spawning
This API bypasses the standard `Forces` weights, allowing for exact unit counts while retaining the advanced BAI movement and reinforcement logic.

### `DeployCustomSpawn`
**Parameters Table Keys**:
*   `composition` (table): A key-value table of catalog categories and counts. *Example*: `{ MECH_CORE = 10, INFANTRY = 20, SAM = 2 }`
*   `anchor` (string|table): Objective zone or coordinate.
*   `skill` (number|table): Maps 1–4 to Tiers (A, G, H, X). Can be a single number or a table of tiers (e.g., `{"A", "G"}`).
*   `minNm` / `maxNm` (numbers): Spawn radius constraints.
*   `coalition` (number): Side to spawn on.
*   `ingressHdg` (number, optional): The bearing from the objective to the spawn location.
*   `ingressArc` (number, optional): Total width of the arc in degrees.
*   `respawn`, `duration`, `respawnDelay`, `reinforce`: Standard behavior.

> **Note**: This API automatically enables `absoluteCount`, meaning the numbers provided in the composition table are used exactly, ignoring echelon scaling multipliers.

---

## 6. Supported Zone Attributes
If the `anchor` provided to any function is a **Trigger Zone**, you can set these properties in the Mission Editor's **Zone Properties** panel to override global or function-level settings:

| Property Key | Type | Description |
| :--- | :--- | :--- |
| `minnm` | Number | Overrides minimum spawn distance (NM). |
| `maxnm` | Number | Overrides maximum spawn distance (NM). |
| `reinforce` | Boolean | `true`/`false` to enable/disable QRF reinforcements. |
| `ingresshdg` | Number | Bearing from objective to spawn location. |
| `ingressarc` | Number | Total width of the spawn arrival arc. Defaults to 180 if `ingresshdg` is set. |
| `skill` | String | Sets the Difficulty Tier for the zone (`A`, `G`, `H`, `X`). |

---

## 7. Global Utilities

### `TCS.MsgToGroup`
Sends a standardized MOOSE message to a specific group.
*   **`group`** (Group|string): The MOOSE group object or the exact name string.
*   **`text`** (string): The message to display.
*   **`duration`** (number, optional): Display time in seconds (default 10).

---

## 8. System Configurations

### Era Filtering
TCS uses a global mission year to filter the catalog.
*   **Configuration**: `MISSION_YEAR_FLAG` (Default: `285999`).
*   **Behavior**: Any unit with a `first_service_year` greater than the value of this flag will be excluded from spawning.

### Menu Control
*   **Flag**: `285000`.
*   **Behavior**: If this flag is greater than `9`, the F10 menu system will not load, regardless of the `config.lua` setting.

---

## 9. Code Examples

#### Creating a Persistent Frontline (BAI)
```lua
-- Spawns RED units 10-15 NM from "Objective_Bravo"
-- Recreates the task 5 minutes after the units are destroyed
DeployGroundForces({
    anchor = "Objective_Bravo",
    echelon = "COMPANY",
    minNm = 10,
    maxNm = 15,
    respawn = true,
    respawnDelay = 300
})
```

#### Custom Ambush Spawn
```lua
-- Spawns exactly 12 Infantry and 4 Armor units
-- Randomly picks from Beginner (A) and Standard (G) equipment tiers
DeployCustomSpawn({
    composition = { INFANTRY = 12, MECH_CORE = 4 },
    anchor = "AmbushZone",
    skill = { "A", "G" },
    minNm = 2,
    maxNm = 5
})
```

#### Establishing a Persistent CAP
```lua
-- Establishes a SQUADRON level CAP over "CombatZone_North"
-- Bandits will ingress from their nearest airbase
DeployAirPatrol("CombatZone_North", "SQUADRON", coalition.side.RED, true)
```