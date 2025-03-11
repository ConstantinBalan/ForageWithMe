# Forage With Me - Trello Cards

## Phase 1: Core Systems Setup

### Card 1: Player Character Base Setup
**Title:** Player Character Base Setup
**Description:** Create the base character controller for the raccoon player character.
**Technical Details:**
- Create the player scene extending Character base class
- Setup collision shapes and physics body
- Add basic properties for movement speed, health, and stamina
- Create basic input mapping for character controls
**Required Skills:** Character setup, scene composition, GDScript basics
**Priority:** High
**Estimated Effort:** 3 points

### Card 2: Player Movement Implementation
**Title:** Player Movement Implementation
**Description:** Implement 3rd-person movement mechanics for the player character.
**Technical Details:**
- Code WASD/analog stick movement with appropriate acceleration/deceleration
- Implement running/walking toggle with stamina consumption
- Add jump mechanics with appropriate animation triggers
- Test movement on different terrain types
**Required Skills:** Character controller programming, physics, input handling
**Priority:** High
**Estimated Effort:** 3 points

### Card 3: Camera Controller Implementation
**Title:** Camera Controller Implementation
**Description:** Create a smooth third-person camera system that follows the player.
**Technical Details:**
- Implement 3rd-person camera with adjustable distance
- Add collision detection to prevent camera clipping through objects
- Implement smooth camera transitions during movement
- Add camera sensitivity settings
**Required Skills:** Camera programming, vector math, input handling
**Priority:** High
**Estimated Effort:** 3 points

### Card 4: Player Animation State Machine
**Title:** Player Animation State Machine
**Description:** Create the animation state machine for the raccoon character.
**Technical Details:**
- Set up AnimationTree with basic states (idle, walk, run, forage)
- Implement smooth transitions between animation states
- Connect input and movement variables to animation parameters
- Test animation blending for natural movement
**Required Skills:** Animation state machines, Godot's AnimationTree
**Priority:** Medium
**Estimated Effort:** 4 points

### Card 5: Interaction System
**Title:** Interaction System
**Description:** Implement the system for player interaction with objects in the world.
**Technical Details:**
- Create interaction raycast from player for detecting interactable objects
- Implement interaction prompts UI element
- Set up interaction signal system
- Create Interactable interface for objects that can be interacted with
**Required Skills:** Raycasting, UI, signal system
**Priority:** High
**Estimated Effort:** 3 points

### Card 6: Time System Core
**Title:** Time System Core
**Description:** Implement the core time tracking system for the game.
**Technical Details:**
- Create TimeManager singleton to track in-game minutes, hours, days
- Implement time scale (1 real-minute = 30 in-game minutes)
- Add day/night cycle timing (6:00 AM to 10:00 PM active)
- Set up time update signals for other systems
**Required Skills:** Singleton pattern, time management, signal system
**Priority:** High
**Estimated Effort:** 3 points

### Card 7: Season System
**Title:** Season System
**Description:** Implement the seasonal cycle that affects gameplay elements.
**Technical Details:**
- Extend TimeManager to track seasons (7 in-game days per season)
- Create seasonal transition events and signals
- Implement season effects on environment parameters
- Add calendar UI element for tracking time and seasons
**Required Skills:** Event system, signal management, UI implementation
**Priority:** Medium
**Estimated Effort:** 4 points

### Card 8: HUD Basic Elements
**Title:** HUD Basic Elements
**Description:** Create the foundational HUD elements for the game.
**Technical Details:**
- Design and implement time/date display
- Create player status indicators (health, stamina, etc.)
- Add interaction prompts display area
- Implement HUD visibility toggle
**Required Skills:** UI layout, Control nodes, theming
**Priority:** Medium
**Estimated Effort:** 2 points

### Card 9: Menu Framework
**Title:** Menu Framework
**Description:** Create the framework for various game menus.
**Technical Details:**
- Implement pause menu with resume/options/quit
- Create menu transition animations
- Set up options menu structure (audio, video, controls)
- Implement menu navigation with both keyboard/controller
**Required Skills:** UI/UX design, menu systems, input handling
**Priority:** Medium
**Estimated Effort:** 3 points

### Card 10: Simple Inventory UI
**Title:** Simple Inventory UI
**Description:** Create a basic inventory UI panel with item slots.
**Technical Details:**
- Design grid-based inventory layout
- Implement item slot system
- Create basic item representation (icon, name, count)
- Add inventory open/close functionality
**Required Skills:** UI implementation, resource handling
**Priority:** Medium
**Estimated Effort:** 3 points

## Phase 2: World & Environment

### Card 11: Village Scene Layout
**Title:** Village Scene Layout
**Description:** Create the base layout for the village hub area.
**Technical Details:**
- Set up village terrain with appropriate collision
- Place building placeholder models in proper layout
- Implement navigation mesh for NPC movement
- Add village boundaries and area transitions
**Required Skills:** 3D level design, navigation mesh, scene organization
**Priority:** High
**Estimated Effort:** 4 points

### Card 12: Player House Interior
**Title:** Player House Interior
**Description:** Create the interior of the player's starting house.
**Technical Details:**
- Design Tier 1 (starting) home interior
- Place basic crafting station placeholders
- Implement door transitions between exterior/interior
- Add basic interior lighting
**Required Skills:** Interior level design, lighting, scene transitions
**Priority:** Medium
**Estimated Effort:** 3 points

### Card 13: Village Building Exteriors
**Title:** Village Building Exteriors
**Description:** Implement exterior models for village buildings.
**Technical Details:**
- Place shops, community hall, and villager homes
- Add collision shapes for all buildings
- Implement door interaction points
- Create building LOD (Level of Detail) system
**Required Skills:** 3D asset placement, collision setup, LOD system
**Priority:** Medium
**Estimated Effort:** 3 points

### Card 14: Forest Area Base Layout
**Title:** Forest Area Base Layout
**Description:** Create the base forest biome area.
**Technical Details:**
- Extend WorldArea base class for forest implementation
- Set up forest terrain with proper navigation
- Add forest boundaries and transition points
- Implement forest-specific ambient settings
**Required Skills:** Terrain system, world area management
**Priority:** Medium
**Estimated Effort:** 4 points

### Card 15: Foraging Points System
**Title:** Foraging Points System
**Description:** Implement the system for placing and managing forageable items.
**Technical Details:**
- Create ForageablePoint class for spawn locations
- Implement spawn rules based on location, season, weather
- Add respawn timers for harvested points
- Create debug visualization for spawn points
**Required Skills:** Object placement, probability systems
**Priority:** High
**Estimated Effort:** 4 points

### Card 16: Forest Forageable Placement
**Title:** Forest Forageable Placement
**Description:** Implement forest-specific forageables and their placement.
**Technical Details:**
- Create forest mushroom, berry, and herb spawn points
- Implement forest-specific forageable items
- Balance rarity and placement density
- Test seasonal variations in spawning
**Required Skills:** Asset placement, balance tuning
**Priority:** Medium
**Estimated Effort:** 3 points

### Card 17: Basic Weather States
**Title:** Basic Weather States
**Description:** Implement the base weather state system.
**Technical Details:**
- Create WeatherSystem class with different weather states
- Implement weather state transitions
- Set up weather probabilities based on season
- Create weather signals for other systems
**Required Skills:** State machine design, probability systems
**Priority:** Medium
**Estimated Effort:** 3 points

### Card 18: Weather Visual Effects
**Title:** Weather Visual Effects
**Description:** Implement visual effects for different weather conditions.
**Technical Details:**
- Create particle systems for rain, snow, and fog
- Implement sky color changes for different weather
- Add cloud systems for various weather states
- Create weather transition effects
**Required Skills:** Particle systems, shader programming, visual effects
**Priority:** Medium
**Estimated Effort:** 4 points

## Phase 3: Gameplay Systems

### Card 19: Inventory Controller Core
**Title:** Inventory Controller Core
**Description:** Implement the core inventory management system.
**Technical Details:**
- Complete InventoryController class for item storage
- Implement add/remove/stack item functionality
- Create item category system
- Add inventory capacity limits
**Required Skills:** Data structures, resource management
**Priority:** High
**Estimated Effort:** 3 points

### Card 20: Item Resource System
**Title:** Item Resource System
**Description:** Create the resource system for all game items.
**Technical Details:**
- Design ForageableItem resource with properties
- Implement item quality system
- Create item categories (mushrooms, berries, herbs, etc.)
- Set up seasonal availability for items
**Required Skills:** Resource scripting, data management
**Priority:** High
**Estimated Effort:** 3 points

### Card 21: Foraging Interaction Mechanics
**Title:** Foraging Interaction Mechanics
**Description:** Implement the mechanics for gathering resources from the world.
**Technical Details:**
- Create ForagingController for player
- Implement foraging animations and timing
- Add success/failure chance based on player skill
- Create item collection effects and feedback
**Required Skills:** Interaction design, animation connection
**Priority:** High
**Estimated Effort:** 3 points

### Card 22: Crafting Station Interactables
**Title:** Crafting Station Interactables
**Description:** Create the interactable crafting stations.
**Technical Details:**
- Implement cooking station as interactable object
- Create medicine crafting station as interactable
- Set up crafting station UI activation on interaction
- Add visual feedback for stations (particle effects, animations)
**Required Skills:** Interactable objects, UI connections
**Priority:** Medium
**Estimated Effort:** 3 points

### Card 23: Recipe Resource System
**Title:** Recipe Resource System
**Description:** Create the data structure for crafting recipes.
**Technical Details:**
- Design Recipe resource with ingredients and results
- Implement recipe difficulty levels
- Create recipe categories (food, medicine)
- Set up recipe discovery system
**Required Skills:** Resource design, data structures
**Priority:** Medium
**Estimated Effort:** 3 points

### Card 24: Crafting UI Implementation
**Title:** Crafting UI Implementation
**Description:** Create the user interface for the crafting system.
**Technical Details:**
- Design crafting menu layout with recipe categories
- Implement ingredient selection interface
- Create crafting result preview
- Add crafting progress visualization
**Required Skills:** UI design, resource visualization
**Priority:** Medium
**Estimated Effort:** 4 points

### Card 25: Basic NPC Setup
**Title:** Basic NPC Setup
**Description:** Implement the foundation for village NPCs.
**Technical Details:**
- Create Villager class extending Character base class
- Implement basic appearance customization
- Add interaction trigger for dialogue
- Create NPC data resources for different characters
**Required Skills:** Character programming, resource management
**Priority:** Medium
**Estimated Effort:** 3 points

### Card 26: NPC AI Controller
**Title:** NPC AI Controller
**Description:** Implement AI behavior for village NPCs.
**Technical Details:**
- Create AIController with pathfinding
- Implement simple daily schedules
- Add idle behaviors and animations
- Create reactive behavior to player proximity
**Required Skills:** AI programming, pathfinding, state machines
**Priority:** High
**Estimated Effort:** 4 points

### Card 27: Simple Dialogue System
**Title:** Simple Dialogue System
**Description:** Create a basic dialogue system for NPC interactions.
**Technical Details:**
- Implement DialogueData resource format
- Create dialogue UI with character portraits
- Add simple dialogue trees with responses
- Implement dialogue triggers based on time of day/relationship
**Required Skills:** Dialogue systems, UI implementation
**Priority:** Medium
**Estimated Effort:** 4 points

## Phase 4: Progression Systems

### Card 28: Home Tier 1 Implementation
**Title:** Home Tier 1 Implementation
**Description:** Implement the player's starting home.
**Technical Details:**
- Finalize Tier 1 cottage model and interior
- Place functional crafting stations
- Add basic storage containers
- Implement bed for sleep/save function
**Required Skills:** Scene design, interactable placement
**Priority:** High
**Estimated Effort:** 3 points

### Card 29: Home Upgrade System
**Title:** Home Upgrade System
**Description:** Create the system for upgrading the player's home.
**Technical Details:**
- Implement upgrade requirements (materials, currency)
- Create scene swapping for different house tiers
- Add upgrade UI and trigger
- Test progression from Tier 1 to Tier 2
**Required Skills:** Scene management, progression systems
**Priority:** Medium
**Estimated Effort:** 3 points

### Card 30: Home Tier 2 Implementation
**Title:** Home Tier 2 Implementation
**Description:** Create the second tier of player home.
**Technical Details:**
- Design Tier 2 home model with expanded features
- Implement improved crafting stations
- Add expanded storage options
- Create garden area implementation
**Required Skills:** Scene design, upgraded systems
**Priority:** Medium
**Estimated Effort:** 3 points

### Card 31: Quota Manager System
**Title:** Quota Manager System
**Description:** Implement the system for tracking village quotas.
**Technical Details:**
- Create QuotaManager to track daily/weekly requirements
- Implement quota generation based on village needs
- Create difficulty scaling for quotas
- Add quota completion rewards
**Required Skills:** Management systems, balance design
**Priority:** High
**Estimated Effort:** 3 points

### Card 32: Quest System Core
**Title:** Quest System Core
**Description:** Implement the foundation for the quest system.
**Technical Details:**
- Complete QuestManager singleton for tracking quests
- Create QuestData resource type
- Implement quest states (active, completed, failed)
- Add quest reward system
**Required Skills:** Quest design, system implementation
**Priority:** High
**Estimated Effort:** 3 points

### Card 33: Quest UI Implementation
**Title:** Quest UI Implementation
**Description:** Create the user interface for the quest system.
**Technical Details:**
- Design quest log interface
- Implement active quest tracking
- Create notification system for new/completed quests
- Add quest details view
**Required Skills:** UI design, information architecture
**Priority:** Medium
**Estimated Effort:** 3 points

### Card 34: Player Skills Framework
**Title:** Player Skills Framework
**Description:** Implement the player skill progression system.
**Technical Details:**
- Create skill categories (foraging, cooking, medicine)
- Implement experience gain mechanics
- Design skill level thresholds
- Add skill effects on gameplay mechanics
**Required Skills:** Progression design, balance tuning
**Priority:** Medium
**Estimated Effort:** 3 points

### Card 35: Tool System Implementation
**Title:** Tool System Implementation
**Description:** Create the system for player tools and their upgrades.
**Technical Details:**
- Implement tools as inventory items with special properties
- Create tool durability and maintenance system
- Add tool proficiency bonuses based on player skill
- Implement tool upgrade paths
**Required Skills:** Item system extension, resource management
**Priority:** Medium
**Estimated Effort:** 3 points

## Phase 5: Polish & Integration

### Card 36: Save Data Structure
**Title:** Save Data Structure
**Description:** Design the structure for save game data.
**Technical Details:**
- Create serialization for player data (inventory, skills, relationships)
- Implement world state serialization
- Design quest and progression state saving
- Create JSON structure for save files
**Required Skills:** Data serialization, JSON formatting
**Priority:** High
**Estimated Effort:** 3 points

### Card 37: Save/Load Implementation
**Title:** Save/Load Implementation
**Description:** Implement the save and load functionality.
**Technical Details:**
- Create save file management 
- Implement auto-save at end of game day
- Add manual save option in pause menu
- Create load game menu with save file selection
**Required Skills:** File I/O, data persistence
**Priority:** High
**Estimated Effort:** 3 points

### Card 38: Audio Manager Implementation
**Title:** Audio Manager Implementation
**Description:** Create the audio management system.
**Technical Details:**
- Set up AudioManager singleton
- Implement sound effect categories and prioritization
- Create music playback system with transitions
- Add audio mixing and volume controls
**Required Skills:** Audio implementation, sound management
**Priority:** Medium
**Estimated Effort:** 3 points

### Card 39: Ambient Sound System
**Title:** Ambient Sound System
**Description:** Implement environment-specific ambient audio.
**Technical Details:**
- Create ambient sound layers for different areas
- Implement time-of-day audio variations
- Add weather-specific ambient sounds
- Create smooth transitions between sound environments
**Required Skills:** Spatial audio, ambient sound design
**Priority:** Medium
**Estimated Effort:** 3 points

### Card 40: Action Sounds Implementation
**Title:** Action Sounds Implementation
**Description:** Add sound effects for all player actions.
**Technical Details:**
- Implement movement sound effects
- Add interaction sound effects
- Create crafting and foraging sounds
- Implement NPC voice effects
**Required Skills:** Sound effect implementation, audio triggers
**Priority:** Low
**Estimated Effort:** 2 points

### Card 41: Object Pooling System
**Title:** Object Pooling System
**Description:** Implement object pooling for performance optimization.
**Technical Details:**
- Create object pool for frequently spawned items
- Implement forageables pooling system
- Add particle effect pooling
- Test performance improvements
**Required Skills:** Object pooling, performance optimization
**Priority:** Medium
**Estimated Effort:** 3 points

### Card 42: Level of Detail System
**Title:** Level of Detail System
**Description:** Implement LOD for distant objects.
**Technical Details:**
- Create LOD system for environment objects
- Implement distance-based model swapping
- Add culling for off-screen objects
- Test performance with various LOD settings
**Required Skills:** LOD implementation, optimization techniques
**Priority:** Medium
**Estimated Effort:** 3 points

### Card 43: Memory Optimization
**Title:** Memory Optimization
**Description:** Optimize memory usage throughout the game.
**Technical Details:**
- Implement texture compression settings
- Add asset streaming for large areas
- Optimize resource loading/unloading
- Profile memory usage and address leaks
**Required Skills:** Memory profiling, resource management
**Priority:** Medium
**Estimated Effort:** 4 points

### Card 44: Game Boot Sequence
**Title:** Game Boot Sequence
**Description:** Create a polished game start-up sequence.
**Technical Details:**
- Implement splash screens
- Create main menu with proper layout
- Add new game/continue/options flow
- Implement screen transitions
**Required Skills:** UI design, scene flow management
**Priority:** Low
**Estimated Effort:** 2 points

### Card 45: Tutorial Implementation
**Title:** Tutorial Implementation
**Description:** Create an in-game tutorial system.
**Technical Details:**
- Design contextual tutorial prompts
- Implement first-time action detection
- Create tutorial UI elements
- Add tutorial progression tracking
**Required Skills:** Tutorial design, contextual help systems
**Priority:** Medium
**Estimated Effort:** 3 points
