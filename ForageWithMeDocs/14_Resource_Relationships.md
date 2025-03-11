# ForageWithMe Resource Relationships

This document provides a visual overview of the relationships between different resources in the ForageWithMe game. These diagrams are designed specifically for Obsidian's Mermaid support and help illustrate how the various game systems are interconnected.

## Core Resource Types

```mermaid
classDiagram
    Resource <|-- ForageableItem
    Resource <|-- RecipeData
    Resource <|-- VillagerData
    Resource <|-- DialogueData
    Resource <|-- RelationshipData
    
    class Resource {
        <<GodotBase>>
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
    
    class RecipeData {
        +name: String
        +description: String
        +ingredients: Dictionary
        +result_item: String
        +result_quantity: int
        +crafting_time: float
    }
    
    class VillagerData {
        +name: String
        +dialogue: Dictionary
        +schedule: Dictionary
        +preferences: Dictionary
        +default_mood: String
        +portrait: Texture2D
    }
    
    class DialogueData {
        +character: String
        +dialogues: Dictionary
        +conditions: Dictionary
        +responses: Dictionary
    }
    
    class RelationshipData {
        +base_value: float
        +max_value: float
        +decay_rate: float
        +gift_impact: Dictionary
        +interaction_impact: Dictionary
    }
```

## Resource Usage in Game Systems

```mermaid
graph TD
    subgraph Resources
        FItem[ForageableItem]
        RData[RecipeData]
        VData[VillagerData]
        DData[DialogueData]
    end
    
    subgraph Game Objects
        Forageable[Forageable]
        Villager[Villager]
        CraftingStation[CraftingStation]
        DialogueSystem[DialogueSystem]
    end
    
    FItem --> Forageable
    RData --> CraftingStation
    VData --> Villager
    DData --> DialogueSystem
    VData --> DialogueSystem
```

## Player Data Relationships

```mermaid
graph TD
    subgraph PlayerData
        Inventory[Inventory]
        Recipes[Known Recipes]
        Tools[Unlocked Tools]
        Relationships[Relationships]
        Proficiency[Foraging Proficiency]
    end
    
    subgraph Game Systems
        InventoryUI[Inventory UI]
        CraftingSystem[Crafting System]
        ToolSystem[Tool System]
        VillagerInteraction[Villager Interaction]
        ForagingSystem[Foraging System]
    end
    
    Inventory <--> InventoryUI
    Recipes <--> CraftingSystem
    Tools <--> ToolSystem
    Relationships <--> VillagerInteraction
    Proficiency <--> ForagingSystem
```

## Foraging System Details

```mermaid
graph TD
    subgraph ForageableItems
        Berries[Wild Berries]
        Mushrooms[Mushrooms]
        Wood[Oak Log]
    end
    
    subgraph ProficiencyCategories
        BerryProf[Berry Proficiency]
        MushroomProf[Mushroom Proficiency]
        WoodProf[Wood Proficiency]
        HerbProf[Herb Proficiency]
    end
    
    subgraph Quality
        BaseQuality[Base Quality]
        ProficiencyBonus[Proficiency Bonus]
        RandomFactor[Random Factor]
        FinalQuality[Final Quality]
    end
    
    Berries --> BerryProf
    Mushrooms --> MushroomProf
    Wood --> WoodProf
    
    BaseQuality --> FinalQuality
    ProficiencyBonus --> FinalQuality
    RandomFactor --> FinalQuality
    
    BerryProf --> ProficiencyBonus
    MushroomProf --> ProficiencyBonus
    WoodProf --> ProficiencyBonus
    HerbProf --> ProficiencyBonus
```

## Data Flow in ForageWithMe

```mermaid
flowchart TD
    subgraph Input
        PlayerInput[Player Input]
        GameEvents[Game Events]
        TimeSystem[Time System]
    end
    
    subgraph Processing
        PlayerController[Player Controller]
        ForagingManager[Foraging Manager]
        InventorySystem[Inventory System]
        RelationshipSystem[Relationship System]
    end
    
    subgraph Storage
        PlayerData[Player Data]
        WorldState[World State]
        SaveSystem[Save System]
    end
    
    subgraph Output
        GraphicsRenderer[Graphics Renderer]
        SoundSystem[Sound System]
        UISystem[UI System]
    end
    
    PlayerInput --> PlayerController
    GameEvents --> ForagingManager
    GameEvents --> RelationshipSystem
    TimeSystem --> WorldState
    
    PlayerController --> InventorySystem
    PlayerController --> ForagingManager
    ForagingManager --> InventorySystem
    ForagingManager --> RelationshipSystem
    
    InventorySystem --> PlayerData
    RelationshipSystem --> PlayerData
    PlayerData --> SaveSystem
    WorldState --> SaveSystem
    
    PlayerController --> GraphicsRenderer
    ForagingManager --> GraphicsRenderer
    InventorySystem --> UISystem
    RelationshipSystem --> UISystem
    ForagingManager --> SoundSystem
```

## Scene Architecture

```mermaid
graph TD
    subgraph Main
        GameRoot[Game Root]
    end
    
    subgraph World
        WorldRoot[World Root]
        ForestZone[Forest Zone]
        VillageZone[Village Zone]
        CabinZone[Cabin Zone]
    end
    
    subgraph UI
        UIRoot[UI Root]
        HUD[HUD]
        InventoryUI[Inventory UI]
        DialogueUI[Dialogue UI]
        MenuUI[Menu UI]
    end
    
    subgraph Characters
        Player[Player]
        Villagers[Villagers]
    end
    
    subgraph Interactables
        Forageables[Forageables]
        Crafting[Crafting Stations]
        Buildings[Buildings]
    end
    
    GameRoot --> WorldRoot
    GameRoot --> UIRoot
    GameRoot --> Player
    
    WorldRoot --> ForestZone
    WorldRoot --> VillageZone
    WorldRoot --> CabinZone
    
    ForestZone --> Forageables
    VillageZone --> Villagers
    VillageZone --> Buildings
    CabinZone --> Crafting
    
    UIRoot --> HUD
    UIRoot --> InventoryUI
    UIRoot --> DialogueUI
    UIRoot --> MenuUI
```

## Resource Loading Flow

```mermaid
sequenceDiagram
    participant Game
    participant ResourceLoader
    participant FileSystem
    participant Cache
    
    Game->>ResourceLoader: Request Resource
    ResourceLoader->>Cache: Check Cache
    
    alt Resource in Cache
        Cache-->>ResourceLoader: Return Cached Resource
        ResourceLoader-->>Game: Return Resource
    else Resource Not in Cache
        ResourceLoader->>FileSystem: Load Resource
        FileSystem-->>ResourceLoader: Return Resource Data
        ResourceLoader->>Cache: Store in Cache
        ResourceLoader-->>Game: Return Resource
    end
```

## Creating New Resources

When creating new resources for ForageWithMe, follow this workflow:

```mermaid
flowchart LR
    A[Identify Resource Need] --> B[Choose Resource Type]
    B --> C[Create Resource File]
    C --> D[Define Properties]
    D --> E[Create Reference in Code]
    E --> F[Test Resource]
    F --> G{Issues?}
    G -- Yes --> D
    G -- No --> H[Integrate with Systems]
```

## Resource Templates

Here are examples of properly configured resources for reference:

### ForageableItem Example

```gdscript
# Wild Berries (ForageableItem)
name = "Wild Berries"
description = "Sweet, wild berries that grow in forested areas."
texture = [Texture2D: berries.png]
mesh = [Mesh: berries.mesh]
collected_mesh = [Mesh: berries_collected.mesh]
collision_shape = [SphereShape3D: r=0.5]
scale = Vector3(1.0, 1.0, 1.0)
has_collision = false
```

### RecipeData Example

```gdscript
# Berry Jam (RecipeData)
name = "Berry Jam"
description = "A sweet jam made from wild berries."
ingredients = {
    "Wild Berries": 3,
    "Sugar": 1
}
result_item = "Berry Jam"
result_quantity = 1
crafting_time = 5.0
```

### VillagerData Example

```gdscript
# Emma (VillagerData)
name = "Emma"
dialogue = {
    "greeting": [
        "Hello there! Lovely day, isn't it?",
        "Oh, hello! Nice to see you today."
    ],
    "farewell": [
        "Take care now!",
        "See you around!"
    ]
}
schedule = {
    "morning": {"location": "farm", "activity": "working"},
    "afternoon": {"location": "village", "activity": "shopping"},
    "evening": {"location": "home", "activity": "relaxing"}
}
preferences = {
    "liked_items": ["Wild Berries", "Berry Jam"],
    "disliked_items": ["Oak Log"]
}
default_mood = "happy"
portrait = [Texture2D: emma_portrait.png]
```

## Resource Saving and Loading

The diagram below illustrates how resources are saved and loaded in ForageWithMe:

```mermaid
graph TD
    subgraph Saving
        A[Game State]
        B[Serialize Resources]
        C[Convert to JSON]
        D[Write to Disk]
    end
    
    subgraph Loading
        E[Read from Disk]
        F[Parse JSON]
        G[Deserialize Resources]
        H[Restore Game State]
    end
    
    A --> B
    B --> C
    C --> D
    
    E --> F
    F --> G
    G --> H
```

## Resource Instances

This diagram shows how resource instances are used in the game world:

```mermaid
flowchart LR
    subgraph Resources
        FR[ForageableItem Resource]
        VR[VillagerData Resource]
    end
    
    subgraph Instances
        F1[Forageable Instance 1]
        F2[Forageable Instance 2]
        F3[Forageable Instance 3]
        V1[Villager Instance 1]
    end
    
    FR --> F1
    FR --> F2
    FR --> F3
    VR --> V1
```
