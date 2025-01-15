extends Node

signal interaction_possible(interactable)
signal interaction_ended(interactable)

var interaction_range := 2.0
var current_interactable = null

@onready var character_body = get_parent().owner # The CharacterBody3D

func _ready():
	if not character_body or not character_body is Node3D:
		push_error("PlayerInteractionComponent: Parent's owner must be a Node3D (like CharacterBody3D)")
		return

func _physics_process(_delta):
	if not character_body:
		return
		
	var nearest = find_nearest_interactable()
	if nearest != current_interactable:
		if current_interactable:
			interaction_ended.emit(current_interactable)
		current_interactable = nearest
		if current_interactable:
			interaction_possible.emit(current_interactable)

func find_nearest_interactable():
	if not character_body:
		return null
		
	var closest_distance = interaction_range
	var closest_interactable = null
	
	# Get all nodes with InteractableComponent
	var interactables = get_tree().get_nodes_in_group("interactable")
	
	for interactable in interactables:
		if not (interactable is Node3D):
			continue
			
		var distance = character_body.global_position.distance_to(interactable.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_interactable = interactable
	
	return closest_interactable

func interact():
	if current_interactable:
		var interactable_component = current_interactable.get_node_or_null("InteractableComponent")
		if interactable_component:
			interactable_component.interact()
