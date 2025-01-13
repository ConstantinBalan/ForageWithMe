class_name Entity
extends Node

func add_component(component):
	add_child(component)

func get_component(component_name: String):
	if has_node(component_name):
		return get_node(component_name)
	return null
