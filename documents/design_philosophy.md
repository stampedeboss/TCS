# TCS Design Philosophy & Architecture

This document captures the core design principles and architectural patterns that define the Theater Control System (TCS). It is intended for developers and advanced mission designers who wish to understand *how* and *why* the system operates the way it does.

---

## 1. From Dynamic to Reactive

The primary goal of TCS is to move beyond a "dynamic" mission (where things are simply randomized) into a truly **reactive** one.

*   **Dynamic**: A system that spawns a random number of units in a random location.
*   **Reactive**: A system that spawns a force, observes the player's interaction with that force, and adapts its own strategy in response.

This is achieved through the **Director** pattern. The Director is not a single module, but a behavior implemented within the lifecycle of each task (e.g., the `timer.scheduleFunction` in a BAI task). It constantly monitors the state of its spawned units and makes tactical decisions.

### Director Playbook Examples:
*   **Retreat**: If a force's strength drops below a certain threshold (e.g., 65%), the Director will order all surviving units to break contact and retreat. This prevents AI from fighting to the last man and creates a more believable battlefield.
*   **Flank**: If a force is "stalled" (makes negligible progress over a set time), the Director assumes it is pinned down. It will calculate a flanking waypoint, issue a new move order to reposition the force, and then re-engage from a new axis.
*   **Reinforce**: If a force is routed, the Director can engage the Logistics system to request a Quick Reaction Force (QRF) from the nearest friendly airbase, creating an escalating engagement.

---

## 2. The Architect Pattern

TCS is built on a "Composite Architecture" model, where different "Architects" are responsible for designing specific types of scenarios.

*   **Mission Architect**: The central, generic architect responsible for executing standardized "work orders" (requisitions). It manages the core `Dispatcher -> Auditor -> Spawner -> Tracker` pipeline.
*   **Specialist Architects** (`AirDef`, `Range`, `DEAD`): These are subject matter experts. Their sole job is to understand the unique requirements of their domain and prepare a detailed blueprint. They do **not** perform any spawning themselves.

### The "Prepare Requisition" Pipeline

This is the universal language that allows the system to function.

1.  **The Request**: A trigger (e.g., `DeployAirDefenses`) is called.
2.  **The Specialist**: The `DEAD.Architect` is engaged. It knows that a DEAD mission requires a SAM site and a High-Value Target (HVT).
3.  **Architects Engaging Architects**: The `DEAD.Architect` calls the `AirDef.Architect` and requests a blueprint for a doctrinal SAM site.
4.  **Blueprint Augmentation**: The `DEAD.Architect` receives the SAM manifest and injects its own HVT component into the center of the layout.
5.  **Standardized Hand-off**: This final, composite blueprint (the "requisition manifest") is handed to the `Mission.Architect` for execution.

This pattern ensures that if the `AirDef.Architect` is improved (e.g., with better SAM layouts), all dependent systems like `DEAD` automatically benefit without any code changes.

---

## 3. Planners vs. The General (API Design)

The external API is split into two clear philosophical roles:

*   **The Planners (`DeployGroundForces`, `DeployAirPatrol`, etc.)**: These are high-level, "fire-and-forget" functions. They are designed for F10 menus and simple mission triggers. The mission designer tells the system *what* they want (e.g., a "COMPANY" level BAI), and the Architects handle the complex details of force composition, scaling, and placement.
*   **The General (`DeployCustom`)**: This is the low-level, "direct demand" backdoor. It is designed for mission designers who need absolute control. It bypasses all automated scaling and composition logic, allowing the designer to specify an exact bill of materials (e.g., `forceSize = { {"ARMOR", 4}, {"INFANTRY", 12} }`).

This dual-API approach provides both ease-of-use for common scenarios and granular control for bespoke, high-stakes encounters. The "General" API was born out of the need for a deterministic testing harness, proving its value in both development and mission design.

---

## 4. Map Agnosticism & Variability

The entire system is designed to be portable across any DCS map with zero changes.

*   **Relative Blueprints**: Architects only define relative offsets (e.g., `x=0, y=50`). They have no concept of absolute world coordinates.
*   **Mathematical Translation**: The core `Spawner` is the only module that performs translations. It takes a geographic anchor, applies the `minNm`/`maxNm` and `ingressHdg` constraints to find a center point, and then translates the relative blueprint offsets into absolute map coordinates.

Variability is achieved by injecting controlled randomness at each stage:

*   **Strategic**: A `DEAD` mission may use an SA-6 one time and an SA-11 the next.
*   **Tactical**: A `RANGE` layout changes based on the requesting aircraft (`HELO` vs. `FAST_JET`).
*   **Compositional**: The `ForceSpawner` uses weighted tables to vary the exact unit types within a category.
*   **Geometric**: The final spawn location is randomized within the `minNm`/`maxNm` and `ingressArc` constraints.

---

## 5. The Emergent, Cross-Domain Battlefield

Because all Architects produce a standardized `requisition` manifest, they can seamlessly "hire" each other to create complex, cross-domain scenarios.

-   **Ground to Air**: A large-scale BAI Architect can call the Air Architect to request a protective CAP for its advancing ground forces.
-   **Air to Ground**: An Air Sweep Architect can call the Ground Architect to request a SEAD mission along its ingress corridor.
-   **Logistics Web**: The Logistics Architect can orchestrate a full-scale operation by calling A2G for the convoy, AirDef for embedded point-defense, and Air for a protective escort.

This allows the battlefield to evolve organically. The air war can generate ground targets, and the ground war can generate air missions, all driven by the state of the theater rather than a pre-written script.

---

## 6. Zone-Based State

The legacy "Session" model, which tied tasks to a player's connection, has been deprecated in favor of a **Zone-based** model.

*   **Anchor**: All tasks are anchored to a geographic Zone, not a player.
*   **Persistence**: A battle over an objective continues even if the instigating player disconnects, RTBs, or is shot down.
*   **Frictionless Multiplayer**: A flight of four can naturally cooperate on an objective simply by flying into the same zone, with no need to manually "join a session" via an F10 menu.
*   **Event-Driven Lifecycle**: Zones and their associated tasks persist as long as combat events are occurring within them. If a zone is inactive (no events, no player presence) for a configurable duration, it is automatically cleaned up by the `ZoneManager` to maintain server performance.

This architecture is the foundation of the persistent, "living" world that TCS aims to create.

---

## 7. Training Fidelity (The "No Sub-Standard Environments" Rule)

A core tenet of TCS training ranges is avoiding "training scars." Learning in a sub-standard environment leads to overconfidence and failure in combat.
*   **Authentic Signatures**: If a pilot is practicing SEAD, they must train against a real, emitting radar system, not a generic static object.
*   **Architectural Delegation**: When a training range requires a complex, realistic threat (like a pop-up SAM), the Range Architect does not create a simplified fake. It outsources the request to the `AirDef` tower to spawn a full, doctrinally correct combat system with restricted Rules of Engagement (`WEAPON_HOLD`).

---

## 8. Domain Sovereignty & Intent-Based APIs

TCS operates on a strict microservices-style architecture where every domain (Air, Land, Logistics, AirDef, Signals) is a sovereign entity. They communicate via **Intent-Based Requests** rather than micro-managing each other's execution.

### No Unified Catalog
There is no central catalog shared across the entire framework. 
*   **Logistics** owns its internal list of transport vehicles and supply pools. 
*   **Air** owns its internal list of fighters, bombers, and rotary assets. 
*   **Signals** (the UI layer) has no catalog at all. It does not know what a "C-130J" or an "M978 HEMTT" is. It only knows that a player requested "Fuel."

### The "What, Not How" Rule
When a request is generated, it specifies the desired outcome (the "What"). The receiving tower interprets the theater conditions and decides the best way to accomplish it (the "How").

**Example: Inter-Domain Collaboration**
1.  **Signals** captures an F10 menu click to resupply a FARP. It fires an intent: `Logistics, RESUPPLY at [Coordinate]`.
2.  **Logistics** receives the request. It analyzes the map, sees the FARP is 150 NM away over water, and realizes ground trucks cannot make the journey.
3.  **Logistics** generates a new intent and hands it to the Air Tower: `Air, AIRLIFT from [Airbase] to [Coordinate]`.
4.  **Air** receives the intent. It selects a CH-47F from its private catalog, spawns it, and routes it to the destination.

Because of this strict boundary, a developer can completely rewrite the Air module or add new flyable cargo planes, and the Signals and Logistics domains will not require a single line of code to be updated.

### Shared Primitives
Since domains do not share catalogs, they rely on a strict, simplified set of primitives to communicate:
*   **Geography:** MOOSE Coordinates, DCS Zone Names, Map Pins.
*   **Factions:** `coalition.side.RED` / `BLUE`.
*   **Intent Tags:** Standardized vocabulary (e.g., `RESUPPLY`, `DENY_AIRSPACE`, `STRIKE`, `ESTABLISH_BASE`).
*   **Threat / Scale:** Basic scaling factors (e.g., "Threat Level G", "Company", "Extreme Threat").

---

## 9. The Two-Tiered API Standard

Every domain exposes its capabilities through two distinct, standardized gateways to separate human-driven chaos from precise mission scripting.

### Tier 1: The Planner (Simplified / Contextual)
*   **The Input:** High-level intent based heavily on geography and shared primitives. (e.g., "Build a FARP at this coordinate for Blue.")
*   **The Behavior:** The Domain takes this minimal input and does the heavy lifting. It queries its own catalogs, applies procedural generation, factors in the theater's era and Threat Level, and fills in all the blanks.
*   **The Use Case:** Dynamic F10 menus, chat commands, and organic gameplay where the player wants the system to react and build the scenario for them.

### Tier 2: The General (Architect / Low-Level)
*   **The Input:** Absolute, rigid specifications. (e.g., "Place exactly two M978 HEMTT Tankers and one M1025 HMMWV at these exact coordinates, heading 045, with Extreme Threat Level.")
*   **The Behavior:** Bypasses all procedural generation, randomizers, and catalogs. It executes the precise bill of materials exactly as commanded.
*   **The Use Case:** Mission Editor scripting, highly specific triggers, bespoke scenario design, or advanced admin interventions.

### Signals: The Translation Layer
The **Signals** domain is the exclusive owner of human-machine interaction. It is the only domain that understands F10 menus, Chat listeners, and F10 Map Markers.

*   **Context Gathering:** Signals intercepts a player's command, figures out *who* asked, their *coalition*, and their *location*.
*   **Translation & Routing:** Signals packages that raw context into the standardized Tier 1 data structure and routes it to the appropriate Domain's Planner API.
*   **Feedback Loop:** Signals receives the result (Success/Failure) from the Domain and translates it back into human feedback via text or Text-To-Speech (TTS).

---

## 10. The Active Zone Context (UI State)

To bridge the gap between the F10 Map and the F10 Radio Menu, the **Signals** domain maintains a stateful "Active Zone" for players and coalitions. The UI remembers the commander's focus.

*   **Pin to Zone:** When a player drops a command pin on the map, Signals executes the request and establishes that coordinate as the "Current Zone."
*   **Dynamic Menus:** F10 Radio menus are context-aware. If an Active Zone exists, menu actions will offer options to execute against the "Current Zone" or generate a "New Zone."
*   **Procedural Offsets:** If "New Zone" is selected via the radio menu (without a map pin), Signals generates a new coordinate procedurally based on the player's current location, heading, and standard domain distances (e.g., 15 NM off the nose). 

This allows a commander to drop a single pin, establish it as the "Current Zone," and then rapidly stack multiple cross-domain requests (e.g., Strike, SEAD, and Escort) onto that exact location using just the radio menu, drastically reducing map clutter and UI friction.