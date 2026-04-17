# TCS A2G Catalog Reference

This document serves as a reference for mission designers using the Theater Control System (TCS). It details the force compositions, unit categories, and the specific unit catalog entries available for Air-to-Ground (A2G) operations.

---

## 1. Force Compositions
Forces define the "recipe" used by the spawning system. When a specific force is requested (e.g., via `TriggerSystemBAI`), the system uses these weights to determine the ratio of units spawned from each catalog category.

| Force Key | Composition Weights |
| :--- | :--- |
| **MECH_INF** | MECH_CORE: 6.0, INFANTRY: 1.0, AIRDEF: 0.1, ARMOR: 0.3, TRANSPORT: 0.5, JTAC: 0.1 |
| **MECH_INF_NJTAC** | MECH_CORE: 6.0, INFANTRY: 1.0, AIRDEF: 0.1, ARMOR: 0.3, TRANSPORT: 0.5 |
| **SEAD** | SAM: 1.5, AIRDEF: 0.5, MIXED: 1.0, STATIC_AIRDEF: 0.5 |
| **DEAD** | SAM: 0.5, AIRDEF: 0.5, ARMOR: 1.0, MECH_CORE: 1.0, STATIC_AIRDEF: 0.5 |
| **STRIKE** | ARMOR: 2.0, TRANSPORT: 1.0, AIRDEF: 0.2, SAM: 0.3, STATIC_AIRDEF: 0.8, STRUCTURE: 1.0 |
| **MAR_CONVOY** | SHIP_CARGO: 4, SHIP_CORVETTE: 1, SHIP_FRIGATE: 1, SHIP_DESTROYER: 0.5, SHIP_CRUISER: 0.2 |
| **MAR_HARBOR** | SHIP_DOCKED: 2, AIRDEF: 0.2, STRUCTURE: 1.0 |
| **SUW_SAG** | SHIP_CORVETTE: 0.7, SHIP_FRIGATE: 0.5, SHIP_DESTROYER: 0.4, SHIP_CRUISER: 0.3, SHIP_CARRIER: 0.3 |
| **LOGISTICS** | TRANSPORT: 3, AIRDEF: 0.5 |
| **HELO_QRF** | HELO: 1.0 |
| **CAS_QRF** | CAS: 1.0 |
| **CV_CAS_QRF** | CV_CAS: 1.0 |

---

## 2. Catalog Categories
Categories are logical groupings of units. The spawning system filters these by the current mission year (defined by the `MISSION_YEAR_FLAG`) to ensure era-appropriate units are selected.

| Category | Description | Primary Domain |
| :--- | :--- | :--- |
| **MECH_CORE** | Mechanized infantry combat vehicles (IFVs), APCs, and organic transports. | Land |
| **INFANTRY** | Dismounted soldiers including riflemen, AT, and MANPADS. | Land |
| **AIRDEF** | Mobile Anti-Aircraft Artillery (AAA) systems. | Land |
| **SAM** | Mobile Surface-to-Air Missile systems (SHORAD/MRAD). | Land |
| **STATIC_AIRDEF** | Fixed AAA emplacements and early warning/search radars. | Land |
| **ARMOR** | Main Battle Tanks (MBTs) and heavy armored combat vehicles. | Land |
| **TRANSPORT** | Unarmed or lightly armed utility vehicles and logistics trucks. | Land |
| **JTAC** | Reconnaissance and scout vehicles used for terminal attack control. | Land |
| **STRUCTURE** | Static targets including bunkers, outposts, and cargo containers. | Land |
| **RANGE_476** | Specialized training targets based on the 476th vFG target objects. | Land |
| **SHIP_*** | Various naval classes (Cargo, Corvette, Frigate, Destroyer, Cruiser, Carrier). | Sea |
| **HELO** | Attack and utility helicopters for air-to-ground reinforcement. | Air |
| **CAS** | Land-based Close Air Support fixed-wing aircraft. | Air |
| **CV_CAS** | Carrier-based Close Air Support fixed-wing aircraft. | Air |

---

## 3. Unit Catalog Details

### Land Units
| ID | Unit Type | Role | Era | Threat | Coalition |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **bmp2** | BMP-2 | IFV | 1980 | LOW | RED |
| **btr80** | BTR-80 | APC | 1984 | LOW | RED |
| **shilka** | ZSU-23-4 Shilka | AAA | 1962 | LOW | RED |
| **t72b** | T-72B | MBT | 1985 | MED | RED |
| **t90** | T-90 | MBT | 1992 | HIGH | RED |
| **osa** | Osa 9A33 bm | SHORAD | 1971 | MED | RED |
| **tor** | Tor 9A331 | SHORAD | 1986 | HIGH | RED |
| **tunguska** | 2S6 Tunguska | SHORAD | 1982 | HIGH | RED |
| **abrams** | M-1 Abrams | MBT | 1980 | HIGH | BLUE |
| **bradley** | M-2 Bradley | IFV | 1981 | HIGH | BLUE |
| **avenger** | M1097 | SHORAD | 1989 | LOW | BLUE |
| **gepard** | Gepard | AAA | 1976 | HIGH | BLUE |
| **inf_ak** | Infantry AK | RIFLEMAN | 1947 | LOW | RED |
| **inf_stinger**| Stinger manpad | RIFLEMAN_AA | 1981 | LOW | BLUE |

### Structures & Range Targets
| ID | Unit Type | Role | Threat |
| :--- | :--- | :--- | :--- |
| **bunker** | Bunker | FORTIFICATION | NONE |
| **outpost** | Outpost | FORTIFICATION | NONE |
| **476_circ_75** | 476_Target_Circle_75 | RANGE_TARGET | NONE |
| **476_hard_1** | 476_Target_Hard_1 | RANGE_TARGET | NONE |

### Sea Units
| ID | Unit Type | Role | Era | Threat | Coalition |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **molniya** | Molniya | CORVETTE | 1979 | MED | RED |
| **rezky** | Rezky | FRIGATE | 1970 | HIGH | RED |
| **moskva** | Moskva | CRUISER | 1982 | HIGH | RED |
| **type052c** | Type_052C | DESTROYER | 2004 | HIGH | RED |
| **perry** | PERRY | FRIGATE | 1977 | MED | BLUE |
| **ticonderoga** | TICONDEROG | CRUISER | 1983 | HIGH | BLUE |
| **arleigh_burke**| USS_Arleigh_Burke_IIa | DESTROYER | 2000 | HIGH | BLUE |
| **drycargo1** | Dry-cargo ship-1 | CARGO | 1960 | NONE | RED |

### Air QRF Units
| ID | Unit Type | Role | Era | Threat | Coalition |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **ka50** | Ka-50 | ATTACK_HELO | 1995 | HIGH | RED |
| **mi24v** | Mi-24V | ATTACK_HELO | 1976 | MED | RED |
| **ah64d** | AH-64D_BLK_II | ATTACK_HELO | 2003 | HIGH | BLUE |
| **su25** | Su-25 | CAS | 1981 | MED | RED |
| **su33** | Su-33 | CAS | 1998 | HIGH | RED |
| **a10c** | A-10C_2 | CAS | 2005 | HIGH | BLUE |
| **fa18c** | FA-18C_hornet | CAS | 1987 | HIGH | BLUE |

---

## 4. SAM Site Compositions (Pre-defined)
For `TriggerSystemSEAD` and `TriggerSystemDEAD`, the system uses specialized compositions for complex SAM sites. These bypass the weight-based logic and use fixed relative positions.

*   **SA-2 (Fan Song)**: Heavy strategic SAM. Requires Search Radar, Tracking Radar, and multiple Launchers.
*   **SA-3 (Low Blow)**: Medium-range tactical SAM.
*   **SA-5 (Gammon)**: Extremely long-range strategic SAM. Usually includes point defense (AAA).
*   **SA-6 (Kub)**: Mobile tracked medium-range SAM.
*   **SA-10 (S-300)**: Modern long-range strategic SAM. High threat.
*   **SA-11 (Buk)**: Mobile tracked medium-range SAM with high lethality.

Each SAM site supports multiple layouts based on **Difficulty**:
*   **G (Standard)**: Standard doctrinal layout.
*   **H (Advanced)**: Increased launcher count and basic point defense.
*   **X (Expert)**: Maximum launchers and integrated SHORAD (e.g., SA-15 Tor or SA-19 Tunguska) for self-defense.