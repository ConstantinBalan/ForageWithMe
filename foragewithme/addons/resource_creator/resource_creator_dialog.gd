@tool
extends ConfirmationDialog

var resource_type: OptionButton
var resource_name: LineEdit
var properties_container: VBoxContainer
var current_properties: Dictionary = {}
var scroll_container: ScrollContainer

const RESOURCE_TYPES = {
	"Forageable": {
		"script": "res://Scripts/Resources/forageable_item.gd",
		"properties": {
			"name": {"type": "string", "default": ""},
			"description": {"type": "text", "default": ""},
			"texture": {"type": "texture2d", "default": null},
			"mesh": {"type": "mesh", "default": null},
			"collected_mesh": {"type": "mesh", "default": null, "depends_on": "has_collision"},
			"collision_shape": {"type": "shape3d", "default": null},
			"scale": {"type": "vector3", "default": Vector3.ONE},
			"has_collision": {"type": "bool", "default": false}
		}
	},
	"Villager": {
		"script": "res://Scripts/Resources/villager_data.gd",
		"properties": {
			"name": {"type": "string", "default": ""},
			"description": {"type": "text", "default": ""},
			"default_mood": {"type": "string", "default": "neutral"},
			"traits": {"type": "string_array", "default": []},
			"liked_items": {"type": "string_array", "default": []},
			"disliked_items": {"type": "string_array", "default": []}
		}
	},
	"Recipe": {
		"script": "res://Scripts/Resources/recipe_data.gd",
		"properties": {
			"name": {"type": "string", "default": ""},
			"description": {"type": "text", "default": ""},
			"category": {"type": "enum", "options": ["Food", "Tool", "Crafting Material"], "default": "Food"},
			"difficulty": {"type": "range", "min": 1, "max": 5, "default": 1},
			"crafting_time": {"type": "float", "default": 1.0},
			"ingredients": {"type": "dictionary", "default": {}}
		}
	},
	"Dialogue": {
		"script": "res://Scripts/Resources/dialogue_data.gd",
		"properties": {
			"dialogue_id": {"type": "string", "default": ""},
			"speaker": {"type": "string", "default": ""},
			"text": {"type": "text", "default": ""},
			"speaker_emotion": {"type": "string", "default": "neutral"},
			"relationship_change": {"type": "float", "default": 0.0}
		}
	}
}

func _init() -> void:
	title = "Create Game Resource"
	size = Vector2(600, 800)
	
	var main_vbox = VBoxContainer.new()
	main_vbox.custom_minimum_size = Vector2(500, 700)
	add_child(main_vbox)
	
	# Resource Type
	var type_hbox = HBoxContainer.new()
	type_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(type_hbox)
	
	var type_label = Label.new()
	type_label.text = "Resource Type:"
	type_hbox.add_child(type_label)
	
	resource_type = OptionButton.new()
	resource_type.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	type_hbox.add_child(resource_type)
	for type in RESOURCE_TYPES:
		resource_type.add_item(type)
	resource_type.item_selected.connect(_on_type_selected)
	
	# Resource Name
	var name_hbox = HBoxContainer.new()
	name_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(name_hbox)
	
	var name_label = Label.new()
	name_label.text = "Resource Name:"
	name_hbox.add_child(name_label)
	
	resource_name = LineEdit.new()
	resource_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_hbox.add_child(resource_name)
	
	# Scroll Container for Properties
	scroll_container = ScrollContainer.new()
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(scroll_container)
	
	# Properties Container
	properties_container = VBoxContainer.new()
	properties_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	properties_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.add_child(properties_container)
	
	# Connect signals
	confirmed.connect(_on_confirmed)
	
	# Initial setup
	_on_type_selected(0)

func _on_type_selected(index: int) -> void:
	var type = resource_type.get_item_text(index)
	_setup_properties(RESOURCE_TYPES[type].properties)

func _setup_properties(properties: Dictionary, preserve_values: bool = false) -> void:
	# Store current values if we need to preserve them
	var stored_values = {}
	if preserve_values:
		for prop_name in current_properties:
			var control = current_properties[prop_name]
			match properties[prop_name].type:
				"string", "text":
					stored_values[prop_name] = control.text
				"float", "range":
					stored_values[prop_name] = control.value
				"bool":
					stored_values[prop_name] = control.button_pressed
				"enum":
					stored_values[prop_name] = control.selected
				"string_array":
					stored_values[prop_name] = control.text
				"dictionary":
					stored_values[prop_name] = control.text
				"mesh", "texture2d", "shape3d":
					stored_values[prop_name] = control.edited_resource
				"vector3":
					var x = control.get_child(0).value
					var y = control.get_child(1).value
					var z = control.get_child(2).value
					stored_values[prop_name] = Vector3(x, y, z)
	
	# Clear existing properties
	for child in properties_container.get_children():
		child.queue_free()
	current_properties.clear()
	
	# Add new properties
	for prop_name in properties:
		var prop = properties[prop_name]
		
		# Skip properties that depend on unchecked boolean properties
		if prop.has("depends_on"):
			var dependency = properties[prop.depends_on]
			if dependency.type == "bool":
				var checkbox = current_properties.get(prop.depends_on)
				# If the checkbox doesn't exist yet (because it comes later in order),
				# use the stored value or default value
				var is_checked = false
				if checkbox:
					is_checked = checkbox.button_pressed
				elif preserve_values and stored_values.has(prop.depends_on):
					is_checked = stored_values[prop.depends_on]
				else:
					is_checked = dependency.default
					
				if not is_checked:
					continue
		
		var hbox = HBoxContainer.new()
		hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		properties_container.add_child(hbox)
		
		var label = Label.new()
		label.text = prop_name.capitalize() + ":"
		label.custom_minimum_size.x = 120
		hbox.add_child(label)
		
		var control
		match prop.type:
			"string":
				control = LineEdit.new()
				control.text = stored_values.get(prop_name, prop.default) if preserve_values else prop.default
				control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			"text":
				control = TextEdit.new()
				control.text = stored_values.get(prop_name, prop.default) if preserve_values else prop.default
				control.custom_minimum_size = Vector2(0, 100)
				control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			"float":
				control = SpinBox.new()
				control.value = stored_values.get(prop_name, prop.default) if preserve_values else prop.default
				control.step = 0.1
				control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			"bool":
				control = CheckBox.new()
				control.button_pressed = stored_values.get(prop_name, prop.default) if preserve_values else prop.default
				control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				# Connect signal to update dependent properties
				if properties.values().any(func(p): return p.get("depends_on") == prop_name):
					control.toggled.connect(_on_bool_property_toggled.bind(properties, prop_name))
			
			"enum":
				control = OptionButton.new()
				for opt in prop.options:
					control.add_item(opt)
				control.selected = stored_values.get(prop_name, prop.options.find(prop.default)) if preserve_values else prop.options.find(prop.default)
				control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			"range":
				control = HSlider.new()
				control.min_value = prop.min
				control.max_value = prop.max
				control.value = stored_values.get(prop_name, prop.default) if preserve_values else prop.default
				control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			"string_array":
				control = LineEdit.new()
				control.text = stored_values.get(prop_name, ",".join(prop.default)) if preserve_values else ",".join(prop.default)
				control.placeholder_text = "comma,separated,values"
				control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			"dictionary":
				control = TextEdit.new()
				control.text = stored_values.get(prop_name, str(prop.default)) if preserve_values else str(prop.default)
				control.custom_minimum_size = Vector2(0, 100)
				control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				
			"mesh":
				var resource_picker = EditorResourcePicker.new()
				resource_picker.base_type = "Mesh"
				resource_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				if preserve_values and stored_values.has(prop_name):
					resource_picker.edited_resource = stored_values[prop_name]
				control = resource_picker
				
			"texture2d":
				var resource_picker = EditorResourcePicker.new()
				resource_picker.base_type = "Texture2D"
				resource_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				if preserve_values and stored_values.has(prop_name):
					resource_picker.edited_resource = stored_values[prop_name]
				control = resource_picker
				
			"shape3d":
				var resource_picker = EditorResourcePicker.new()
				resource_picker.base_type = "Shape3D"
				resource_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				if preserve_values and stored_values.has(prop_name):
					resource_picker.edited_resource = stored_values[prop_name]
				control = resource_picker
				
			"vector3":
				var hbox_vector = HBoxContainer.new()
				hbox_vector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				
				var stored_vector = stored_values.get(prop_name, prop.default) if preserve_values else prop.default
				
				var x = SpinBox.new()
				x.value = stored_vector.x
				x.step = 0.1
				x.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				
				var y = SpinBox.new()
				y.value = stored_vector.y
				y.step = 0.1
				y.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				
				var z = SpinBox.new()
				z.value = stored_vector.z
				z.step = 0.1
				z.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				
				hbox_vector.add_child(x)
				hbox_vector.add_child(y)
				hbox_vector.add_child(z)
				control = hbox_vector
		
		hbox.add_child(control)
		current_properties[prop_name] = control

func _on_bool_property_toggled(button_pressed: bool, properties: Dictionary, prop_name: String) -> void:
	# Re-setup properties when a boolean property changes, preserving values
	_setup_properties(properties, true)

func _on_confirmed() -> void:
	var type = resource_type.get_item_text(resource_type.selected)
	var name = resource_name.text.strip_edges()
	
	if name.is_empty():
		push_error("Resource name cannot be empty")
		return
	
	# Create resource
	var resource = Resource.new()
	resource.script = load(RESOURCE_TYPES[type].script)
	
	# Set properties
	for prop_name in current_properties:
		var control = current_properties[prop_name]
		var prop_type = RESOURCE_TYPES[type].properties[prop_name].type
		var value
		
		match prop_type:
			"string", "text":
				value = control.text
			"float":
				value = control.value
			"bool":
				value = control.button_pressed
			"enum":
				value = control.get_item_text(control.selected)
			"range":
				value = control.value
			"string_array":
				value = control.text.split(",", false)
			"dictionary":
				value = str_to_var(control.text)
			"mesh", "shape3d", "texture2d":
				value = control.edited_resource
			"vector3":
				value = Vector3(
					control.get_child(0).value,
					control.get_child(1).value,
					control.get_child(2).value
				)
			_:
				value = control.text
		
		resource.set(prop_name, value)
	
	# Save resource
	var dir = "res://Resources/" + type + "s/"
	if not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_recursive_absolute(dir)
	
	var path = dir + name + ".tres"
	var err = ResourceSaver.save(resource, path)
	if err != OK:
		push_error("Failed to save resource: " + str(err))
	else:
		print("Resource saved successfully to: " + path)
		hide()
