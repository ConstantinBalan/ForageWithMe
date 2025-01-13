extends Node

signal interaction_started(interactable)
signal interaction_ended(interactable)

var intercation_range := 2.0
var current_interactable = null

func _physics_process(delta):
	#Raycast or area check for interactable item or person
	var nearest = find_nearest_interactable()
	if nearest != current_interactable:
		if current_interactable:
			interaction_ended.emit(current_interactable)
		current_interactable = nearest
		if current_interactable:
			interaction_started.emit(current_interactable)
	

func find_nearest_interactable():
	#Get a list of items or people with the interactable method, and find the one with the closeest distance
	pass
	
func interact():
	if current_interactable and current_interactable.has_method("interact"):
		current_interactable.interact()
