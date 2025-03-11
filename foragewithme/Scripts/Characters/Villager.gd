class_name Villager
extends Character

signal dialogue_started(villager)
signal dialogue_ended(villager)

@export var villager_data: VillagerData
@export var current_dialogue: DialogueData

var relationship_data: RelationshipData
var current_activity: String = "idle"
var current_dialogue_options: Array[DialogueData] = []

func _ready():
	super._ready()
	add_to_group("villagers")

	if villager_data:
		# Set up visual appearance
		var mesh_instance = $MeshInstance3D
		if mesh_instance and villager_data.mesh:
			mesh_instance.mesh = villager_data.mesh
			mesh_instance.scale = villager_data.scale

		# Initialize relationship data
		relationship_data = RelationshipData.new()
		relationship_data.villager_id = villager_data.name

	update_activity(Time.get_time_string_from_system())

func _physics_process(_delta: float) -> void:
	if not villager_data:
		return

	match current_activity:
		"idle":
			# Simple idle behavior - slight random movement
			if randf() < 0.01: # 1% chance per physics frame
				var random_direction = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
				global_position += random_direction * speed * _delta
		"work":
			# Move towards work location
			var work_pos = villager_data.locations.get("work", global_position)
			global_position = global_position.move_toward(work_pos, speed * _delta)
		"leisure":
			# Move towards leisure location
			var leisure_pos = villager_data.locations.get("leisure", global_position)
			global_position = global_position.move_toward(leisure_pos, speed * _delta)
		"sleep":
			# Move towards home and disable interaction
			var home_pos = villager_data.locations.get("home", global_position)
			global_position = global_position.move_toward(home_pos, speed * _delta)

func update_activity(time_of_day: String) -> void:
	if not villager_data:
		return

	for schedule_time in villager_data.schedule.keys():
		if time_of_day >= schedule_time:
			current_activity = villager_data.schedule[schedule_time]

func interact_with(interactor: Node3D) -> void:
	if not interactor is Player or not villager_data:
		return

	var player = interactor as Player
	start_dialogue(player)

func start_dialogue(player: Player) -> void:
	if current_activity == "sleep":
		# Show sleeping prompt
		return

	emit_signal("dialogue_started", self)

	# Get available dialogue options based on relationship level
	current_dialogue_options.clear()
	for dialogue in get_available_dialogues():
		if meets_dialogue_requirements(dialogue, player):
			current_dialogue_options.append(dialogue)

	if current_dialogue_options.is_empty():
		# Use fallback dialogue
		current_dialogue = create_fallback_dialogue()
	else:
		# Pick random appropriate dialogue
		current_dialogue = current_dialogue_options.pick_random()

	# Apply dialogue effects
	if current_dialogue:
		# Change relationship
		if current_dialogue.relationship_change != 0:
			relationship_data.friendship_level += current_dialogue.relationship_change

		# Give items
		if current_dialogue.gives_item != "":
			player.add_item(current_dialogue.gives_item)

		# Play animations and sounds
		if current_dialogue.animation != "":
			$AnimationPlayer.play(current_dialogue.animation)

		if current_dialogue.voice_clip:
			$AudioStreamPlayer3D.stream = current_dialogue.voice_clip
			$AudioStreamPlayer3D.play()

func end_dialogue() -> void:
	emit_signal("dialogue_ended", self)
	current_dialogue = null
	current_dialogue_options.clear()

func meets_dialogue_requirements(dialogue: DialogueData, player: Player) -> bool:
	if not dialogue:
		return false

	# Check relationship level
	if relationship_data.friendship_level < dialogue.required_relationship_level:
		return false

	# Check time of day
	if dialogue.required_time_of_day and current_activity != dialogue.required_time_of_day:
		return false

	# Check required items
	for item in dialogue.required_items:
		if not player.has_item(item):
			return false

	# Check required quests
	for quest in dialogue.required_quests_completed:
		if not player.has_completed_quest(quest):
			return false

	return true

func create_fallback_dialogue() -> DialogueData:
	var fallback = DialogueData.new()
	fallback.dialogue_id = "fallback"
	fallback.speaker = villager_data.name
	fallback.text = "Hello there! Nice weather we're having."
	fallback.speaker_emotion = "neutral"
	return fallback

func get_available_dialogues() -> Array[DialogueData]:
	if not villager_data:
		return []
	var resource_loader = get_node("/root/GameResourceLoader")
	return resource_loader.get_dialogues_for_villager(villager_data.id)

func receive_gift(item_id: String) -> void:
	if not villager_data:
		return

	var relationship_change = 0.0
	if item_id in villager_data.liked_items:
		relationship_change = 2.0
	elif item_id in villager_data.disliked_items:
		relationship_change = -1.0
	else:
		relationship_change = 0.5

	relationship_data.friendship_level += relationship_change

	# Add to gift history
	relationship_data.gift_history.append({
		"item": item_id,
		"time": Time.get_unix_time_from_system(),
		"relationship_change": relationship_change
	})