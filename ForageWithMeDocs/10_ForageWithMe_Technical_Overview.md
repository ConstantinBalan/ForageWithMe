# ForageWithMe Technical Overview

## Game Architecture

This document provides a detailed technical overview of the ForageWithMe game codebase, including the script structure, signal flow, resource management, and development patterns. This guide is intended to help developers understand how the game is built and how to extend its functionality.

## Core Architecture Diagram

```mermaid
graph TD
    subgraph Autoloaded Scripts
        GM[GameManager]
        PDM[PlayerDataManager]
        WM[WorldManager]
    end
    
    subgraph Player Systems
        Player[Player]
        CameraHolder[CameraHolder]
        Inventory[PlayerInventoryController]
    end
    
    subgraph Interaction Systems
        Forageable[Forageable]
        FM[ForagingManager]
        Interactable[GameObject/Interactable]
    end
    
    subgraph Resource Systems
        FItem[ForageableItem]
        Recipe[RecipeData]
        VData[VillagerData]
        DData[DialogueData]
        RData[RelationshipData]
    end
    
    subgraph Characters
        Character[Character Base Class]
        Player[Player]
        Villager[Villager]
    end
    
    PDM -- save/load --> Player
    Player -- has --> Inventory
    Player -- controls --> CameraHolder
    Player -- interacts with --> Forageable
    Forageable -- uses --> FM
    FM -- updates --> PDM
    Forageable -- uses resource --> FItem
    Interactable -- parent of --> Forageable
    Character -- parent of --> Player
    Character -- parent of --> Villager
```

## Class Hierarchy

```mermaid
classDiagram
    Node <|-- Node3D
    Node3D <|-- CharacterBody3D
    CharacterBody3D <|-- Character
    Character <|-- Player
    Character <|-- Villager
    Node3D <|-- GameObject
    GameObject <|-- Forageable
    Resource <|-- ForageableItem
    Resource <|-- RecipeData
    Resource <|-- VillagerData
    Resource <|-- DialogueData
    Resource <|-- RelationshipData
    
    class Character {
        +speed: float
        +sprint_speed: float
        +jump_velocity: float
        +inventory: Dictionary
        +relationships: Dictionary
        +add_item(item_id: String, amount: int): bool
        +remove_item(item_id: String, amount: int): bool
        +change_relationship(character_id: String, amount: float): void
    }
    
    class Player {
        +camera_holder: Node3D
        +camera: Camera3D
        +interaction_ray: RayCast3D
        +inventory_controller: PlayerInventoryController
        +is_sprinting: bool
        +current_interactable: GameObject
        +handle_movement_intent(delta: float): void
        +check_interaction(): void
    }
    
    class GameObject {
        +object_id: String
        +hover_label_text: String
        +show_hover_label(): void
        +hide_hover_label(): void
        +get_hover_text(): String
    }
    
    class Forageable {
        +forageable_data: ForageableItem
        +respawn_time: float
        +is_available: bool
        +mesh_instance: MeshInstance3D
        +collision_shape: CollisionShape3D
        +forage(player: Player): void
        +respawn(): void
    }
    
    class ForageableItem {
        +name: String
        +description: String
        +texture: Texture2D
        +mesh: Mesh
        +collected_mesh: Mesh
        +collision_shape: Shape3D
        +scale: Vector3
        +has_collision: bool
    }
```

## Signal Flow Diagram

```mermaid
sequenceDiagram
    participant Player
    participant Forageable
    participant ForagingManager
    participant PlayerDataManager
    
    Player->>Forageable: interact_with()
    Forageable->>Player: add_item_with_texture()
    Forageable->>Forageable: emit_signal("foraged")
    Player->>Player: emit_signal("inventory_changed")
    ForagingManager->>ForagingManager: start_foraging()
    ForagingManager->>PlayerDataManager: update_foraging_proficiency()
    ForagingManager->>ForagingManager: emit_signal("foraging_completed")
```

## Key Systems Breakdown

### 1. Player System

The player system is built around the `Player` class which extends from `Character`. It handles:

- Movement and controls (WASD + mouse look)
- Interaction with game objects via raycasting
- Inventory management through the `PlayerInventoryController`
- Camera control via the `CameraHolder` node

Key code paths:
- `Player.gd`: Main player logic
- `PlayerInventoryController.gd`: Handles inventory operations
- `camera_holder.gd`: Controls camera behavior, including orbit mode

```mermaid
flowchart TD
    A[Player Input] --> B{Input Type}
    B -->|Movement| C[Update Velocity]
    B -->|Interaction| D[Cast Ray]
    B -->|Sprint| E[Change Speed/FOV]
    D --> F{Hit Interactable?}
    F -->|Yes| G[Show Interaction UI]
    F -->|No| H[Hide Interaction UI]
    G --> I{Player Presses E}
    I -->|Yes| J[Call interact_with]
```

### 2. Foraging System

The foraging system allows players to collect resources from the environment:

- `Forageable.gd`: Represents collectible items in the world
- `ForageableItem.gd`: Resource definition for forageable objects
- `foraging_manager.gd`: Handles foraging logic and proficiency

```mermaid
graph TD
    A[Player] -->|Interacts| B[Forageable]
    B -->|If Available| C[Forage Method]
    C -->|Add to Inventory| D[Player Inventory]
    C -->|Emit Signal| E[foraged Signal]
    B -->|Update State| F[Set Not Available]
    B -->|Start Timer| G[Respawn Timer]
    G -->|When Complete| H[Respawn Method]
    H -->|Reset| B
```

### 3. Data Management

The game uses several data managers to handle persistence and game state:

- `player_data_manager.gd`: Manages player data including inventory, relationships, and proficiency
- `game_manager.gd`: Handles global game settings and state
- `world_manager.gd`: Manages the game world state

```mermaid
flowchart LR
    A[PlayerDataManager] --> B[Save Game Data]
    A --> C[Load Game Data]
    A --> D[Update Proficiency]
    A --> E[Get Proficiency]
    
    subgraph Player Data Structure
    F[player]
    F --> G[inventory]
    F --> H[recipes]
    F --> I[unlocked_tools]
    F --> J[relationships]
    F --> K[foraging_proficiency]
    K --> L[berries]
    K --> M[mushrooms]
    K --> N[herbs]
    K --> O[wood]
    end
```

## Resource System

The game uses Godot's Resource system extensively to define game data:

```mermaid
classDiagram
    Resource <|-- ForageableItem
    Resource <|-- RecipeData
    Resource <|-- VillagerData
    Resource <|-- DialogueData
    
    class ForageableItem {
        +name: String
        +description: String
        +texture: Texture2D
        +mesh: Mesh
        +collected_mesh: Mesh
    }
    
    class RecipeData {
        +name: String
        +description: String
        +ingredients: Dictionary
        +result_item: String
        +result_quantity: int
    }
    
    class VillagerData {
        +name: String
        +dialogue: Dictionary
        +schedule: Dictionary
        +preferences: Dictionary
    }
    
    class DialogueData {
        +character: String
        +dialogues: Dictionary
        +conditions: Dictionary
    }
```

## Development Workflow

When adding new features to ForageWithMe, follow these patterns:

### Adding a New Forageable Item

1. Create a new ForageableItem resource in the Resources directory
2. Set up the necessary meshes and collision shapes
3. Create a new scene by instantiating the Forageable scene
4. Assign the ForageableItem resource to the forageable_data property
5. Place the scene in the world

### Adding a New NPC

1. Create a new VillagerData resource
2. Set up dialogue and schedule data
3. Instantiate the Villager scene
4. Assign the VillagerData resource
5. Add to appropriate groups and scenes

### Creating New UI Elements

1. Design UI in Godot's scene editor
2. Create a script extending from appropriate base classes
3. Connect signals from data sources
4. Implement event handlers
5. Register with appropriate managers if needed

## Performance Considerations

- The game uses instancing for repeatable elements like forageables
- Raycast-based interaction system allows for efficient collision detection
- Proficiency system uses simple float values for calculations
- Respawn timers for forageables are used to limit the number of active objects

## Next Steps for Development

1. Implement crafting system using RecipeData resources
2. Create the village and villager AI using schedules
3. Design seasonal changes for forageables
4. Implement building and customization systems
5. Add quest system with progression

## Debug Tools and Tips

- Group nodes appropriately (player, forageables, villagers, etc.)
- Use print statements with descriptive prefixes for debugging
- Test forageable interactions in isolation
- Check proficiency values through PlayerDataManager
