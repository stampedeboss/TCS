# TCS Range Reference

-- Mission builder wants a helo-specific bombing range at a specific coordinate
TriggerSystemBomb({
    anchor = myCoordinate,
    rangeClass = "HELO" -- This explicitly requests the helo layout and the FARP
})
if not equipmentType then return { class = "FAST_JET" } end -- Default for system calls
This document details the composition and behavior of the various training ranges available through the `TriggerSystem...` API.

---

## Core Concepts

*   **Adaptive Layouts**: The `Range.Architect` automatically selects the appropriate target layout based on the `equipmentType` of the requesting aircraft (e.g., `HELO`, `FAST_JET`, `DEFAULT`).
*   **FARP Support**: When a helicopter requests any range, a Forward Arming and Refueling Point (FARP) is automatically spawned 2 NM behind the target area, allowing for extended training sorties.
*   **Behavior Modes**: All range targets are spawned in `STATIC` mode by default, meaning they will not move or shoot back, providing a safe training environment.

---

## Range Types

### `TriggerSystemBomb`

**Purpose**: Provides static targets suitable for practicing the employment of unguided (dumb) bombs, laser-guided bombs (LGBs), and GPS-guided munitions (JDAMs).

**Layouts**:
*   **FAST_JET**: A cross pattern of five static `Container` objects, ideal for practicing pattern bombing and multi-target attacks.
*   **HELO**: A dispersed group of vehicle targets, including a `T-72B` and `BMP-2`, to simulate a light armored position suitable for attack with ATGMs or rockets.
*   **DEFAULT**: A single, high-contrast `Target_476_Circle` for basic accuracy practice.

---

### `TriggerSystemStrafe`

**Purpose**: Dedicated gunnery range for practicing strafing runs against soft and lightly armored point targets.

**Layouts**:
*   **FAST_JET**: A long, vertical line of five `Ural-375` trucks. Ideal for high-angle, high-speed strafing passes.
*   **HELO**: A tight cluster of dismounted infantry (`Soldier M4`, `Soldier RPG`). Designed to simulate troops in the open for close-in hovering fire and rocket pods.
*   **DEFAULT**: A single light armored vehicle (`M1126-Stryker-ICV` or equivalent).

---

### `TriggerSystemMixed`

**Purpose**: Creates a complex target environment for practicing sensor acquisition (TGP, Radar), target discrimination, and multi-role sorties involving different weapon types on a single pass.

**Layouts**:
*   **FAST_JET**: A wide, 300-meter footprint featuring a hardened `bunker` at the center, surrounded by a mix of armor (`T-72B`), soft targets (`Ural-375`), and a non-firing air defense unit (`Shilka`) to practice identifying and prioritizing threats.
*   **HELO**: A tighter, 100-meter footprint designed for close-in attacks. It features a central `outpost` building, a light armored vehicle (`BMP-2`), a soft truck, and dismounted infantry (`Soldier RPG`, `Soldier M4`) to simulate a fortified infantry position.
*   **DEFAULT**: A slightly smaller version of the FAST_JET layout, suitable for subsonic attackers like the A-10.

---

### `TriggerSystemConvoy`

**Purpose**: Creates a column of moving vehicles for practicing attacks against non-static targets. This is ideal for training with weapons like the Maverick, Vikhr, or for practicing high-angle strafing runs.

**Behavior**: Unlike other ranges, this uses a `MOVING` behavior mode. The spawned units will travel in a straight line along the `ingressHdg` for a default distance of 10 NM.

**Layouts**:
*   **FAST_JET**: A long, widely-spaced column of four `Ural-375` trucks, allowing for multiple high-speed passes.
*   **HELO**: A tighter, mixed convoy of `Ural-375` trucks and a `BMP-2`, providing a more resilient and varied target set for closer-range helicopter engagements.
*   **DEFAULT**: A moderately spaced column of four `Ural-375` trucks.

---

### `TriggerSystemMovingArmor`

**Purpose**: Creates a slower-moving column of heavy armor (MBTs and IFVs). Designed for practicing precision anti-armor weapons (Mavericks, Hellfires, Vikhrs, CBU-97/105, LGBs) against hardened, moving targets.

**Behavior**: Spawns in `MOVING` mode. Moves slower than a transport convoy (~25 kph).

**Layouts**:
*   **FAST_JET**: A column of heavy `T-90` or `T-72B` tanks.
*   **HELO**: A tactical, staggered formation of `T-72B`s and `BMP-2`s. The staggered layout forces the pilot to actively slew sensors laterally between engagements.
*   **DEFAULT**: A standard column of `T-72B`s and `BMP-2`s.

---

### `TriggerSystemRadarEmitter`

**Purpose**: Provides a live, emitting radar source for SEAD practice (HARM, Shrike, Sidearm) and RWR threat identification without the risk of being shot down. 

**Behavior**: Spawns in `STATIC` mode. Critically, it forces the AI's Alarm State to `RED` (radar active and spinning) but sets the ROE to `WEAPON_HOLD`. This provides a 100% authentic radar signature and lock-on warning, ensuring high training fidelity without violating the "no threats" rule of the Range environment.

**Layouts**:
*   **FAST_JET**: A powerful Search Radar (e.g., `p-19 s-125 sr`) ideal for practicing long-range, high-altitude HARM lofting.
*   **HELO**: A tactical AAA emitter (`shilka`) for practicing terrain masking, RWR monitoring, and close-range pop-up attacks.
*   **DEFAULT**: A `shilka`.

---

### `TriggerSystemPopupSam`

**Purpose**: Creates a reactive threat environment for practicing defensive reactions to unexpected SAM launches.

**Behavior**: This trigger acts as a specialized wrapper for the `AirDef` tower (DSAM). It requests a short-range air defense system (default: SA-9) and instructs it to hold fire and keep its radars silent until a target enters its `ambushRadiusNm` (default 5 NM). At that point, the system's ROE switches to `WEAPON_FREE`.

*Note: Because this relies on live, combat-capable SAMs, it is managed entirely by the `AirDef` tower, not the training `Range` architect. It perfectly demonstrates Architects engaging each other.*

---

*(This document will be expanded as new range types are added.)*