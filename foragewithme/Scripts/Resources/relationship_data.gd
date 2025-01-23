@tool
extends Resource
class_name RelationshipData

@export var villager_id: String = ""
@export var friendship_level: int = 0
@export var max_friendship: int = 10

# Relationship milestones and their requirements
@export var milestones: Dictionary = {
	"acquaintance": 2,
	"friend": 5,
	"best_friend": 8,
	"family": 10
}

# History of interactions
@export var gift_history: Array[Dictionary] = []
@export var conversation_history: Array[Dictionary] = []
@export var quest_history: Array[Dictionary] = []

# Relationship modifiers
@export var daily_decay: float = -0.1
@export var gift_bonus: float = 1.0
@export var conversation_bonus: float = 0.5
@export var quest_bonus: float = 2.0

func get_current_milestone() -> String:
	var current_milestone = "stranger"
	for milestone in milestones:
		if friendship_level >= milestones[milestone]:
			current_milestone = milestone
	return current_milestone
