# Development Guidelines for Forage With Me

## Overview
This document outlines the development standards, practices, and workflows for the "Forage With Me" project. Adhering to these guidelines ensures code quality, maintainability, and effective collaboration among team members.

## Project Structure

### Godot Project Organization
```
ForageWithMe/
├── .github/                # GitHub workflow configurations
├── .godot/                 # Godot-generated files (do not edit manually)
├── addons/                 # Third-party addons and plugins
├── assets/                 # All game assets
│   ├── audio/              # Music and sound effects
│   ├── fonts/              # Custom fonts
│   ├── materials/          # Shared materials
│   ├── meshes/             # 3D models
│   ├── textures/           # Texture files
│   │   ├── characters/     # Character textures
│   │   ├── environment/    # Environment textures
│   │   ├── items/          # Item textures
│   │   └── ui/             # UI textures
│   └── shaders/            # Custom shaders
├── scenes/                 # Scene files (.tscn)
│   ├── characters/         # Character scenes
│   ├── environment/        # Environment scenes
│   ├── levels/             # Game level scenes
│   ├── ui/                 # UI scenes
│   └── props/              # Props and items
├── scripts/                # GDScript files
│   ├── autoload/           # Autoloaded scripts (global)
│   ├── characters/         # Character scripts
│   ├── environment/        # Environment scripts
│   ├── items/              # Item scripts
│   ├── systems/            # Game systems (time, inventory, etc.)
│   └── ui/                 # UI scripts
├── tests/                  # Automated tests
├── export_presets.cfg      # Export configurations
├── project.godot           # Project settings
└── README.md               # Project description
```

## Coding Standards

### GDScript Style Guide

#### Naming Conventions
- **Classes/Nodes**: PascalCase (e.g., `PlayerCharacter`, `ForagingTool`)
- **Variables**: snake_case (e.g., `player_health`, `current_season`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `MAX_HEALTH`, `SPRING_DURATION`)
- **Functions**: snake_case (e.g., `pick_item()`, `calculate_daily_quota()`)
- **Signals**: snake_case, past tense for events (e.g., `item_collected`, `day_changed`)
- **Enum Values**: UPPER_SNAKE_CASE (e.g., `enum Season { SPRING, SUMMER, FALL, WINTER }`)

#### File Naming
- **Scene Files (.tscn)**: PascalCase (e.g., `PlayerCharacter.tscn`, `ForestEnvironment.tscn`)
- **Script Files (.gd)**: snake_case (e.g., `player_controller.gd`, `inventory_system.gd`)
- **Resource Files (.tres)**: snake_case (e.g., `mushroom_item.tres`, `cooking_recipe.tres`)

#### Code Formatting
- Use 4 spaces for indentation (not tabs)
- Keep lines under 100 characters when possible
- Leave one empty line between functions
- Leave two empty lines between classes
- Group code in logical sections with descriptive comments

#### Script Structure
Organize scripts in the following order:
1. Class/tool declarations
2. Enums and constants
3. Exported variables
4. Public variables
5. Private variables
6. Onready variables
7. Built-in virtual methods (e.g., `_ready()`, `_process()`)
8. Public methods
9. Private methods
10. Signal callbacks

Example:
```gdscript
class_name PlayerCharacter
extends CharacterBody3D

# Enums and Constants
enum ToolType { BASKET, KNIFE, ROD, TROWEL }
const MAX_ENERGY = 100

# Exported Variables
@export var movement_speed: float = 5.0
@export var jump_strength: float = 4.0

# Public Variables
var current_tool: int = ToolType.BASKET
var inventory = []

# Private Variables
var _energy: float = MAX_ENERGY
var _is_foraging: bool = false

# Onready Variables
@onready var animation_player = $AnimationPlayer
@onready var camera = $Camera3D

# Built-in Virtual Methods
func _ready():
    initialize_inventory()
    
func _process(delta):
    update_energy(delta)
    
func _physics_process(delta):
    handle_movement(delta)

# Public Methods
func use_tool():
    match current_tool:
        ToolType.BASKET:
            collect_item()
        ToolType.KNIFE:
            cut_item()
        # ...

func add_to_inventory(item):
    inventory.append(item)
    emit_signal("item_collected", item)

# Private Methods
func _handle_movement(delta):
    # Movement code here
    pass
    
func _update_energy(delta):
    # Energy update logic
    pass

# Signal Callbacks
func _on_area_entered(area):
    if area.is_in_group("collectible"):
        highlight_item(area)
```

### Best Practices

#### Performance
- Use object pooling for frequently instantiated objects
- Limit the use of `_process` and `_physics_process` to what's necessary
- Optimize draw calls by using texture atlases where appropriate
- Use LOD (Level of Detail) for distant objects
- Implement occlusion culling for complex scenes

#### Memory Management
- Free resources when no longer needed
- Use weak references for temporary relationships
- Avoid deep recursive functions
- Be mindful of memory leaks in signals (remember to disconnect)

#### Game Architecture
- Use the node system as intended (inheritance hierarchy)
- Prefer composition over inheritance where it makes sense
- Use signals for loose coupling between components
- Implement singletons (autoloads) for global systems, but use sparingly

## Version Control Guidelines

### Git Workflow
We follow a simplified GitFlow workflow:
- `main` branch: Production-ready code
- `develop` branch: Integration branch for features
- `feature/*` branches: New features
- `bugfix/*` branches: Bug fixes
- `release/*` branches: Release preparation

### Commit Messages
Structure commit messages as follows:
```
[Type]: Short description (50 chars max)

Detailed explanation if necessary. Wrap at 72 characters.
Include motivation for change and differences from previous behavior.
```

Types:
- `[Feat]`: New feature
- `[Fix]`: Bug fix
- `[Docs]`: Documentation changes
- `[Style]`: Formatting, missing semicolons, etc; no code change
- `[Refactor]`: Refactoring production code
- `[Test]`: Adding tests, refactoring tests; no production code change
- `[Chore]`: Updating build tasks, package manager configs, etc; no production code change

### Pull Request Process
1. Create a PR with a clear description of changes
2. Link relevant issues
3. Ensure all automated tests pass
4. Request review from at least one team member
5. Address review comments
6. Merge only when approved

## Testing Framework

### Manual Testing Checklist
- Verify player movement in all environments
- Test foraging mechanics with all tools
- Confirm cooking/crafting works for all recipes
- Check house upgrades function properly
- Validate NPC interactions and quests
- Test day/night and seasonal cycles
- Verify quota system calculations
- Test save/load functionality

### Automated Testing
Where possible, implement automated tests using Godot's testing framework:
- Unit tests for isolated functionality
- Integration tests for systems working together
- Performance tests for critical sections

## Asset Integration Process

### Adding New Assets
1. Place assets in the appropriate directory following the project structure
2. Use Godot's Import system with consistent import settings
3. Document any special requirements in asset metadata
4. Update the Asset List document if adding new asset types

### Optimization Guidelines
- Texture sizes: 2048px max for hero assets, 1024px for standard
- Polygon count: Aim for mobile-friendly counts (~10k polygons per major object)
- Audio: Use OGG format for final builds, 44.1kHz, 16-bit

## Bug Tracking and Resolution

### Bug Report Template
```
Title: [Brief description of the bug]

Environment:
- OS: [e.g., Windows 10, macOS, Linux]
- Godot Version: [e.g., 4.3]
- Build Version: [e.g., 0.2.3]

Steps to Reproduce:
1. [First step]
2. [Second step]
3. [...]

Expected Behavior:
[What should happen]

Actual Behavior:
[What actually happens]

Screenshots/Videos:
[If applicable]

Additional Notes:
[Any other context that might be helpful]
```

### Bug Priority Levels
- **Critical**: Game-breaking, blocks progress
- **High**: Major feature broken, but workarounds exist
- **Medium**: Feature works but has issues
- **Low**: Minor issues, visual glitches

## Build and Deployment

### Development Builds
- Create development builds weekly
- Name format: `ForageWithMe_Dev_YYYY-MM-DD`
- Distribute to internal team via private channel

### Testing Builds
- Create testing builds for milestone completions
- Name format: `ForageWithMe_Test_vX.Y.Z`
- Distribute to selected testers

### Release Builds
- Follow the Steam Release Checklist for final builds
- Name format: `ForageWithMe_Release_vX.Y.Z`
- Archive all release builds

## Team Communication

### Regular Meetings
- Daily standup (15 min): Quick progress updates
- Weekly planning (1 hour): Task allocation and priorities
- Milestone review (2 hours): End of milestone evaluation

### Tools
- **Project Management**: [Tool of choice, e.g., Trello, Jira]
- **Communication**: [Tool of choice, e.g., Discord, Slack]
- **File Sharing**: [Tool of choice, e.g., Google Drive, Dropbox]
- **Version Control**: GitHub

## Documentation Standards

### Code Documentation
- Add comments for complex logic
- Document all public functions with parameters and return values
- Include purpose and usage examples for classes

Example:
```gdscript
## Calculates the energy cost of foraging based on the tool used and time of day
## Parameters:
## - tool_type: The type of tool being used (ToolType enum)
## - current_time: The current in-game time (hours, 0-24)
## Returns: The energy cost as a float
func calculate_foraging_energy_cost(tool_type: int, current_time: float) -> float:
    # Implementation
    pass
```

### Design Documentation
- Keep the GDD, TDD, and asset list up to date
- Document system interactions with diagrams
- Record design decisions and their rationales

## Onboarding Process

### New Team Member Setup
1. Grant access to repositories and project management tools
2. Provide codebase tour and overview of architecture
3. Assign a mentor for the first two weeks
4. Start with small, well-defined tasks

### First Week Checklist
- Set up local development environment
- Complete a sample feature implementation
- Review all documentation
- Meet all team members
- Understand the project timeline and responsibilities

## Conclusion
These guidelines are living documents and should be updated as the project evolves. All team members are encouraged to suggest improvements to our processes and standards. The goal is to maintain a high-quality codebase while enabling efficient and enjoyable development.

## Appendix

### Useful Godot Resources
- [Godot Documentation](https://docs.godotengine.org/en/stable/)
- [GDScript Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- [Godot Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/index.html)

### Project-Specific Resources
- Game Design Document
- Technical Design Document
- Asset List
- Milestone Schedule
- Project Management Plan
