@tool
extends Resource
class_name DialogueData

@export var dialogue_id: String = ""
@export var speaker: String = ""
@export_multiline var text: String = ""

# Dialogue conditions
@export var required_relationship_level: int = 0
@export var required_time_of_day: String = ""
@export var required_items: Array[String] = []
@export var required_quests_completed: Array[String] = []

# Dialogue options and responses
@export var options: Array[Dictionary] = []  # Array of {text: String, next_dialogue: String, requirements: Dictionary}
@export var responses: Dictionary = {}  # Mapping of option -> response dialogue

# Dialogue effects
@export var relationship_change: float = 0.0
@export var gives_item: String = ""
@export var starts_quest: String = ""

# Visual and audio feedback
@export var speaker_emotion: String = "neutral"
@export var voice_clip: AudioStream
@export var animation: String = "talk"
