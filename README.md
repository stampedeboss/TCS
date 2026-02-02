# Theater Control System (TCS)
## Operations & Concepts Guide (Authoritative)

# Theater Control System (TCS)

## Purpose
The **Theater Control System (TCS)** exists to eliminate the cycle of *create → train → discard → recreate → retrain* by providing a **persistent, capability-driven operational environment** inside DCS.  

TCS is not a mission pack, scenario set, or campaign in the traditional sense. It is a **system of rules, state, and player agency** that allows missions to *emerge* rather than be scripted.

---

## Core Definition
**Theater Control System (TCS)** is a persistent, session-driven operational environment where control, denial, and restoration of capabilities determine outcomes. Combat removes capabilities, logistics restores them, and both sides continuously adapt based on the evolving state of the theater.

---

## Fundamental Principles

### 1. Capability-Based Warfare
- Missions are not objectives; **capabilities are the objective**.
- Examples of capabilities:
  - Airspace control
  - Logistics throughput
  - ISR / JTAC availability
  - Ground maneuver freedom
  - Sustainment and basing

A mission reduces to a simple statement:
> **“I want to take this away from the other side.”**

---

### 2. Persistent State
- The world does not reset between missions.
- Losses persist.
- Gains persist.
- Outcomes reshape future possibilities.

Failure is not erased; it becomes **context**.

---

### 3. Irreversibility with Agency
- Combat can only **remove** capabilities.
- **Logistics is the only mechanism that can restore capabilities**.
- If a logistics source is destroyed:
  - That line of recovery ends.

> **Lose it, you are done.**

This applies locally and temporally, not globally or permanently.

---

### 4. Both Sides Must Be Able to Win
- No side is ever permanently locked out.
- If an approach fails, players must:
  - change strategy
  - shift axis
  - adapt tactics

There are no forced resets, but there are **always alternatives**.

---

## Sessions (The Mission Brain)

### Definition
A **Session** is a map-agnostic, location-independent container for shared intent and experience.

Sessions:
- are not tied to geography
- do not own zones or coordinates
- define *who is operating together*, not *where*

---

### Session Properties
- Owner (creator)
- Members (groups)
- Shared communications
- Shared controllers (JTAC, AWACS – future)

If the owner ceases to exist for **any reason**, the Session collapses.

---

### Why Sessions Exist
Sessions provide:
- shared situational awareness
- shared communications
- shared consequences
- accountability

They replace the need for scripted missions.

---

## Training & Combat Doctrine

TCS is structured around **three progressive goals**, not modes.

### 1. Build Skills
> *Can I do the thing?*

- No threats
- No pressure
- No consequences

Examples:
- A2A BFM / BVR / H2H
- A2G RANGE
- Procedural JTAC

---

### 2. Put Skills Under Stress
> *Can I still do the thing when it matters?*

- Threats exist
- Survival matters
- Errors have cost

Examples:
- A2A sweeps / intercepts
- A2G BAI
- Armed reconnaissance

---

### 3. Achieve a Defined Objective
> *Did we accomplish the mission?*

- Binary success/failure
- Consequences propagate
- Coordination matters

Examples:
- CAS with overrun logic
- Escort
- Protection of logistics

---

## A2A and A2G as Competency Tracks

TCS treats A2A and A2G as **parallel competency tracks** that can exist independently or together within a Session.

---

## A2A Spawning & Geometry (Authoritative)

### Core Principle
> **A2A opponents are spawned dynamically based on the Session owner (or invoking group) position, course, intent, and geometry — not fixed templates or map-specific zones.**

A2A spawning follows the **same solver pattern as A2G**, replacing terrain constraints with airspace constraints.

---

### Anchor Selection
- If a Session exists, the **Session owner** aircraft is the anchor.
- Otherwise, the invoking group lead is used.

All geometry is resolved relative to this anchor.

---

### Direction Logic
- Spawn bearing is calculated relative to the anchor’s **current ground track**.
- Bearing arcs are **intent-dependent** and may range up to **±135°** forward of course.
- For **Build** activities, rear-quarter spawns (180°) are allowed intentionally to train defensive skills.

There are **no surprise spawns**; all geometry preserves reaction time appropriate to intent.

---

### Distance Bands
Distance controls reaction time and perceived difficulty.

| Intent | Typical Distance (NM) |
|------|-----------------------|
| Build Skills | 5–15 |
| CAP | 20–40 |
| Escort | 30–60 |
| Intercept | 40–80 |
| Sweep | 60–100 |

Distance is biased **forward and outward** on retries to maintain believability.

---

### Bearing Arcs by Intent

| Intent | Bearing Arc |
|------|-------------|
| Build Skills | Inline, offset, or rear-quarter |
| CAP | ±90° |
| Escort | ±60° (forward-biased) |
| Intercept | ±90° to ±135° |
| Sweep | ±135° |

---

### Altitude Bands

| Band | Altitude |
|----|----------|
| LOW | 10–18k ft |
| MEDIUM | 18–28k ft |
| HIGH | 28–38k ft |

Altitude selection is driven by intent, threat level, and aircraft type.

---

### Spawn Solver Behavior
- Validates map bounds
- Biases distance outward on retries
- Widens bearing slightly if needed
- Returns a single believable spawn point or fails cleanly

This solver is **map-agnostic** and requires no Mission Editor setup.

---

### Behavior Assignment
Spawn geometry does **not** define behavior.

Behavior is assigned **after spawn** based on intent:
- Sweep
- Intercept
- Escort
- CAP

This preserves a single unified A2A capability with multiple expressions.

---

### Lifecycle Rules
- One active A2A package per Session (initially)
- Despawn when:
  - anchor is destroyed
  - session ends
  - time expires
- Respawn only via new intent declaration

---

### Design Outcome
This model ensures:
- consistent behavior across maps
- no template dependency
- realistic reaction timelines
- unified A2A/A2G architecture

---

### A2G

- **Build**: RANGE
- **Control Ground Effects**: BAI, SEAD / DEAD, MAR / SUW
- **Exploit Effects**: CAS, Strike (Fixed / Mobile)

Eventually, Sessions may exercise **both tracks simultaneously**.

---

## Maritime Operations (MAR / SUW)

### Definition
**MAR / SUW (Maritime / Surface Warfare)** is the control and denial of surface maneuver, sustainment, and access via sea lines of communication.

Within TCS, MAR / SUW is treated as a **control capability**, not a standalone mission type.

---

### Role in TCS
MAR / SUW exists to:
- deny or protect sea-based logistics
- control maritime maneuver space
- enable or prevent power projection ashore

It is functionally parallel to:
- **A2A Control** (airspace)
- **SEAD / DEAD** (threat environment)

---

### Capability Placement
MAR / SUW is a first-class capability under **Air-to-Ground**, as it directly shapes ground and logistics outcomes.

```
TCS
 └─ Capabilities
     └─ Air-to-Ground
         ├─ Build
         │   └─ Range
         │
         ├─ Control Ground Effects
         │   ├─ BAI           (maneuver control)
         │   ├─ SEAD / DEAD   (threat control)
         │   └─ MAR / SUW     (maritime control)
         │
         └─ Exploit Effects
             ├─ CAS
             └─ Enable Strike / Logistics
```

---

### MAR vs SUW
MAR and SUW are expressions of the same capability:

- **MAR** → deny or protect maritime access and sustainment
- **SUW** → destroy or degrade surface combatants

They differ only by **persistence of effect**, not mechanics.

---

### Chess Model Alignment
- Surface groups are **high-value pieces**
- Sea lanes are **critical files**
- Ports and choke points are **control squares**

Loss of maritime control directly impacts:
- logistics throughput
- ground sustainment
- operational tempo

---

### Objective Integration
MAR / SUW naturally supports objectives such as:
- Interdict logistics
- Protect maritime sustainment
- Enable amphibious or coastal operations

---

## Strike (Projection of Control)

### Definition
**Strike** is the proactive projection of control intended to reduce enemy capability before it can be brought to bear.

Strike is **not** defined by weapon or platform, but by **target characteristics and intent**.

---

### Land Strike Categories

All land strike targets fall into one of two categories:

#### Fixed Strike
- Targets: infrastructure, bases, depots, factories, hardened sites
- Characteristics: known location, persistent until destroyed
- Effect: long-term or permanent capability reduction

#### Mobile Strike
- Targets: maneuver units, relocatable systems, transient assets
- Characteristics: time-sensitive, intelligence-dependent
- Effect: short-to-medium term capability reduction

The distinction is **target mobility**, not weapon, aircraft, or delivery method.

---

### Intent Alignment

- **Fixed Strike** reduces enduring enemy capability
- **Mobile Strike** reduces emerging or maneuvering enemy capability

Both are expressions of **Strike as projection of control** and are distinct from:
- BAI / MAR (maneuver denial)
- CAS / SUW (force protection)

---

## Logistics (Long-Term Pillar)



### Restoration Rules
- Nothing is restored by script.
- Everything restored is moved by logistics.
- Restoration is delayed, vulnerable, and contestable.

---

### Kill Zones
- Each side has map-appropriate logistics source areas.
- These areas are:
  - geographically credible
  - heavily defended
  - always dangerous

If a kill zone is lost, restoration through that zone ends.

---

## The Chess Model

TCS turns DCS into a **chess game with pilots and actors as pieces**.

- Pieces have roles and value
- Position matters
- Sacrifice is intentional
- Mistakes are irreversible
- Strategy outweighs kill counts

The map becomes the board. Sessions become players. Capabilities become material.

---

## Design Guardrails

The following rules must never be violated:

- No silent resets
- No scripted restoration
- No infinite safety
- No forced objectives
- Loss must matter
- Recovery must be vulnerable

If a feature violates these, it does not belong in TCS.

---

## End State Vision

TCS is an evolving battlespace where:
- missions emerge from player intent
- outcomes persist
- both sides adapt
- logistics governs recovery
- strategy replaces scripting

> **We do not fly missions. We play a war.**

---

## Living Document
This document is authoritative but **intentionally incomplete**.

As TCS evolves:
- definitions may refine
- systems may expand
- mechanics may deepen

The core principles must remain unchanged.


