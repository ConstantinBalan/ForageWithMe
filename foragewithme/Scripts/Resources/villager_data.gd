@tool
extends Resource
class_name VillagerData

@export var name: String = ""
@export var portrait: Texture2D
@export_multiline var description: String = ""
@export var default_mood: String = "neutral"

# Visual representation
@export var mesh: Mesh  # For 3D representation
@export var scale: Vector3 = Vector3.ONE

# Schedule - Dictionary of time -> activity
@export var schedule: Dictionary = {
	"06:00": "wake_up",
	"07:00": "work",
	"12:00": "lunch",
	"13:00": "work",
	"18:00": "leisure",
	"22:00": "sleep"
}

# Locations for activities
@export var locations: Dictionary = {
	"home": Vector3.ZERO,
	"work": Vector3.ZERO,
	"leisure": Vector3.ZERO
}

# Personality traits (affects dialogue and reactions)
@export var traits: Array[String] = []

# Gift preferences
@export var liked_items: Array[String] = []
@export var disliked_items: Array[String] = []
