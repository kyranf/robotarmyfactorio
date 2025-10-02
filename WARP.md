# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

This is the **Robot Army** mod for Factorio 2.0+, a game modification that adds automated robot soldiers and supporting infrastructure. The mod allows players to manufacture and deploy combat robots that can attack enemies and defend factories autonomously.

### Key Features
- Combat robot units (defenders, distractors, destroyers, flame droids, etc.)
- Automated squad-based AI system with intelligent formation and targeting
- Manufacturing buildings (Droid Assemblers, Guard Stations)
- Support for Unit Control mod integration
- Advanced squad management with retreat, hunt, and guard behaviors

## Architecture Overview

### Core System Design

The mod is built around a **hierarchical squad-based architecture** with the following key components:

#### 1. Squad Management System (`robolib/Squad.lua`)
- Central entity managing groups of robot units
- Each squad has unique ID, command state, and unit group
- Handles formation, movement, and combat coordination
- Supports merging/splitting of squads based on proximity and size

#### 2. AI Control System (`robolib/SquadControl.lua`)
- **Battle AI**: Manages hunting, retreating, and combat decisions
- **Guard AI**: Handles defensive positioning around key structures
- State machine with commands: `assemble`, `move`, `follow`, `guard`, `patrol`, `hunt`
- Tick-based processing with configurable update rates

#### 3. Event-Driven Architecture (`robolib/eventhandlers.lua`)
- Handles entity spawning, building placement, and destruction
- Player interaction events (selection tools, commands)
- AI command completion and distraction handling
- Force-based separation for multiplayer compatibility

#### 4. Configuration-Driven Behavior (`config/config.lua`)
- All AI parameters are externally configurable
- Squad size thresholds, update rates, range limits
- Scalable damage and health multipliers
- Performance tuning options

### Data Structure Patterns

#### Global Storage Organization
```lua
storage.Squads[force_name][squad_id] = Squad
storage.DroidAssemblers[entity_id] = Assembler
storage.droidGuardStations[entity_id] = GuardStation  
storage.updateTable[force_name][tick] = [squad_ids]
storage.units[unit_number] = LuaEntity
```

#### Squad State Machine
- **Commands**: Enum-based command system with state tracking
- **Position Management**: Home base, patrol points, target positions
- **Member Tracking**: Dynamic unit group management with failure handling
- **Tick Scheduling**: Distributed AI processing across game ticks

### Entity Lifecycle

#### Robot Unit Creation
1. **Manufacturing**: Droid Assemblers craft robot items
2. **Deployment**: Items converted to active units via event handlers
3. **Squad Assignment**: New units join nearby squads or create new ones
4. **AI Integration**: Units added to tick-based update scheduling

#### Squad Behavior States
- **Assemble**: Initial state, gathering at home base
- **Hunt**: Active combat mode, seeking and engaging enemies
- **Guard**: Defensive positioning around structures
- **Retreat**: Return to assemblers when squad size drops below threshold

## Development Workflow

### File Organization

- **`control.lua`**: Main mod entry point, event registration
- **`data.lua`**: Prototype definitions (items, entities, recipes)
- **`data-updates.lua`**: Post-processing modifications
- **`info.json`**: Mod metadata and dependencies
- **`prototypes/`**: Entity definitions (buildings, units, items)
- **`robolib/`**: Core logic systems
- **`stdlib/`**: Utility library functions
- **`config/`**: Configuration parameters
- **`migrations/`**: Save game compatibility updates

### Testing and Debugging

#### In-Game Testing
```lua
-- Enable debug logging
LOGGER = Logger.new("robotarmy", "robot_army_logs", true)

-- Check squad states
/c game.print(serpent.block(storage.Squads))

-- Monitor AI performance
/c game.print("Squads: " .. ses_statistics.squadsCreated)
```

#### Key Configuration Tweaks
- `TICK_UPDATE_SQUAD_AI = 60`: AI update frequency (performance vs responsiveness)
- `SQUAD_SIZE_MIN_BEFORE_HUNT = 10`: Combat engagement threshold
- `SANITY_CHECK_PERIOD_SECONDS = 10`: Command timeout for stuck squads

### Common Development Tasks

#### Adding New Robot Types
1. Create unit prototype in `prototypes/[unit-name].lua`
2. Add to spawnable list in `prototypes/DroidUnitList.lua`
3. Define recipes and technology requirements
4. Update graphics and sound references

#### Modifying AI Behavior  
1. Adjust parameters in `config/config.lua`
2. Modify decision logic in `robolib/SquadControl.lua`
3. Update targeting algorithms in `robolib/targeting.lua`
4. Test with various squad sizes and scenarios

#### Performance Optimization
1. Monitor `storage.updateTable` distribution across ticks
2. Adjust tick processing rates based on squad count
3. Profile unit group command efficiency
4. Optimize entity lookup patterns

### Mod Integration

#### Unit Control Compatibility
- Detects Unit_Controll mod presence via `script.active_mods`
- Disables internal AI when Unit Control is active
- Raises appropriate events for external control systems

#### Multiplayer Considerations
- Force-based data separation in global storage
- Event handling for cross-force interactions
- Network-efficient state synchronization

### Dependencies and Compatibility

- **Required**: Factorio 2.0.0+
- **Optional**: Unit_Controll >= 2.0.3 (enhanced control)
- **Conflicts**: CombatRobotsOverhaul (mod conflicts)

### Migration and Save Compatibility

Migration files handle version updates and ensure save game compatibility when mod updates change data structures. Located in `migrations/` directory with version-specific update scripts.

## Key Constants and Thresholds

- `SQUAD_SIZE_MIN_BEFORE_HUNT = 10`: Minimum squad size for offensive operations
- `SQUAD_SIZE_MIN_BEFORE_RETREAT = 2`: Squad size triggering retreat to assembler
- `SQUAD_CHECK_RANGE = 20`: Range for squad membership proximity checks
- `SQUAD_HUNT_RADIUS = 5000`: Maximum engagement range from home base
- `ASSEMBLER_UPDATE_TICKRATE = 120`: Tick rate for manufacturing checks
- `BOT_COUNTERS_UPDATE_TICKRATE = 60`: Signal update frequency for combinators