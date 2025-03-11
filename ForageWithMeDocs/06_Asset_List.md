# Asset List for Forage With Me

## Overview
This document provides a comprehensive list of assets required for the development of "Forage With Me." It serves as a reference for artists, developers, and project managers to track asset creation progress and ensure nothing is overlooked.

## Characters

### Player Character
- **Raccoon Model (3D)**
  - Base model with rigging
  - Idle animation
  - Walk/run animation
  - Foraging animation (reaching, picking, digging)
  - Cooking animation
  - Jump animation
  - Swimming animation
  - Tired state animation
  - Happy/satisfied animation
  - 3 clothing variations per season (12 total)
  - Tool usage animations (for each foraging tool)

### Villagers (10-12 NPCs)
- **Villager Models (3D)**
  - Unique character designs for each villager
  - Basic animations (idle, walk, talk)
  - Special animations for quest-givers
  - Seasonal clothing variations
  - Age variations (elders, adults, children)
  - Species variations (consider other woodland animals)

### Wildlife/Ambient Creatures
- Small forest animals (squirrels, birds, rabbits)
- Insects (butterflies, bees, dragonflies)
- Fish (for river/lake)
- Seasonal wildlife variations

## Environments

### Village
- **Central Village Buildings**
  - Town square
  - Market stalls
  - NPC houses (10-12)
  - Community hall/gathering place
  - Quest board
  - Trading post
  - Paths connecting buildings
  - Ambient decoration (wells, benches, gardens)
  - Seasonal decorations

### Player House (3 Upgrade Tiers)
#### Tier 1 (Basic)
- Basic exterior model
- Basic interior models
  - Simple cooking station
  - Basic furniture
  - Storage containers
  - Bed
  - Windows/door

#### Tier 2 (Improved)
- Enhanced exterior with additional details
- Expanded interior
  - Improved cooking station
  - Better quality furniture
  - Enhanced storage options
  - Decoration items
  - Improved windows/lighting

#### Tier 3 (Advanced)
- Premium exterior with garden/yard elements
- Luxury interior
  - Professional cooking station
  - High-quality furniture
  - Expanded storage system
  - Trophy/achievement display
  - Special seasonal decorations
  - Unique architectural elements

### Foraging Areas (4 Main Regions)
#### Plains
- Terrain model with grass textures
- Wildflowers and herbs
- Rock formations
- Small shrubs
- Seasonal variations

#### Forest
- Tree models (5-7 variations)
- Forest floor vegetation
- Mushroom varieties
- Berry bushes
- Fallen logs
- Clearings
- Seasonal variations

#### River/Riverside
- River water (animated)
- River banks
- Riverside plants
- Rocks and pebbles
- Fishing spots
- Small waterfalls
- Seasonal variations

#### Lake
- Lake water (animated)
- Shoreline
- Lake plants/lily pads
- Fishing spots
- Surrounding landscape features
- Seasonal variations

## Props and Collectibles

### Foraging Tools
- Basic basket
- Upgraded gathering basket
- Fishing rod
- Mushroom knife
- Herb scissors
- Digging trowel
- Berry picker
- Nut gatherer
- Specialty seasonal tools (4)

### Forageables (40-50 unique items)
#### By Season
- **Spring**
  - Early mushrooms
  - Spring greens
  - Flowers
  - Spring berries
  - Spring roots

- **Summer**
  - Summer berries
  - Herbs
  - Summer mushrooms
  - Nuts
  - Summer vegetables

- **Fall**
  - Fall mushrooms
  - Fall berries
  - Nuts
  - Fall herbs
  - Root vegetables

- **Winter**
  - Winter mushrooms
  - Evergreen elements
  - Winter berries
  - Preserved items
  - Special winter plants

#### By Region
- Plains-specific items
- Forest-specific items
- River-specific items
- Lake-specific items

### Cooking/Medicine Station Elements
- Cooking pot
- Mortar and pestle
- Drying rack
- Mixing bowls
- Fermenting jars
- Recipe book
- Ingredient storage
- Tools (knives, stirring implements)
- Fire/heat source

### Prepared Items (Foods/Medicines)
- Healing potions
- Energy foods
- Season-specific remedies
- Special dishes
- Tinctures
- Teas
- Preserves
- Specialized medicines

## UI Elements

### HUD Components
- Health indicator
- Energy/stamina meter
- Time/day display
- Season indicator
- Inventory UI
- Quest tracker
- Quota progress
- Tool selection interface
- Recipe book interface

### Menu Screens
- Main menu
- Settings menu
- Save/load screen
- Map screen
- Recipe collection
- Character/tool upgrades
- Achievement tracking
- House upgrade interface

### Tutorial Elements
- Tutorial pop-ups
- Instruction cards
- Hint overlays
- Interactive guides

## Visual Effects

### Environment Effects
- Weather systems (rain, snow, wind)
- Day/night cycle lighting
- Seasonal visual transitions
- Water reflections
- Ambient particles (pollen, leaves, snowflakes)

### Gameplay Effects
- Gathering particles
- Cooking effects
- Crafting effects
- Healing effects
- Time passage effects
- House upgrade transitions

## Audio Assets

### Music
- Main theme
- Village ambient music
- Foraging area themes (4 regions)
- Seasonal variations
- Cooking/crafting music
- Special event music

### Sound Effects
- Character movement
- Foraging sounds
- Tool usage
- Cooking processes
- UI interactions
- Environmental sounds
  - Wind
  - Water
  - Wildlife
  - Weather
- House upgrading
- Achievement sounds

### Voice Acting
- Player character reactions
- NPC dialogue snippets
- Tutorial narration (if applicable)

## Marketing Assets

### Promotional Art
- Key art (main poster image)
- Character portraits
- Environment showcases
- Logo designs
- Icon

### Trailer Assets
- Special animations for trailer
- Title cards
- Transition effects
- Lower thirds

## Asset Priority Tiers
This section helps the team focus on critical assets first.

### Tier 1 (MVP - Minimum Viable Product)
- Player character with basic animations
- Basic village
- First tier of player house
- Core foraging mechanics and items
- Basic cooking station
- UI essentials
- 3-4 key villagers
- 1 complete foraging area

### Tier 2 (Enhanced Experience)
- Complete animation sets
- All foraging areas
- Full set of seasonal items
- All tools
- House tier 2
- All villagers
- Complete UI

### Tier 3 (Complete Game)
- House tier 3
- All effects
- Marketing assets
- Full audio implementation
- Polish and refinement

## Asset Naming Convention
To maintain organization throughout development, all assets should follow this naming convention:

```
FWM_[Category]_[Subcategory]_[ItemName]_[Variant]_[Version]
```

Example: `FWM_CHAR_Player_Winter_v02`

### Categories:
- CHAR: Characters
- ENV: Environments
- PROP: Props
- TOOL: Tools
- UI: User Interface
- VFX: Visual Effects
- SFX: Sound Effects
- MUS: Music

## Asset Delivery Specifications

### 3D Models
- Format: FBX and glTF
- Poly count: Low-poly with normal maps for detail
- Textures: 2K for main character and important elements, 1K for secondary elements
- UV mapping: Optimized for texture atlasing where appropriate

### Textures
- Format: PNG or JPG
- Resolution: 2048x2048 max for hero assets, 1024x1024 for standard assets
- PBR workflow: Albedo, Normal, Roughness, Metallic

### Audio
- Format: WAV (for development), OGG (for final game build)
- Sample rate: 44.1kHz
- Bit depth: 16-bit

### UI
- Format: PNG with transparency
- Resolution: Designed for multiple resolutions with scaling in mind

## Review and Approval Process
1. Concept art/reference gathering
2. Asset blockout/grey boxing
3. Team review
4. Detailed asset creation
5. Integration testing
6. Polish and optimization

## Asset Tracking Sheet
A separate asset tracking spreadsheet will be maintained with the following columns:
- Asset ID
- Asset Name
- Category
- Priority
- Assigned Artist
- Status (Not Started, In Progress, Review, Complete)
- Dependencies
- Notes

This document should be reviewed and updated regularly during production meetings.
