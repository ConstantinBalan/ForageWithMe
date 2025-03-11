extends Node

func _ready():
	# Create a new palette texture
	var palette = Image.create(8, 1, false, Image.FORMAT_RGB8)

	# Fill in our whimsical forest colors
	palette.set_pixel(0, 0, Color("#1e4620")) # Rich emerald green
	palette.set_pixel(1, 0, Color("#3eae48")) # Bright spring green
	palette.set_pixel(2, 0, Color("#825233")) # Warm cedar brown
	palette.set_pixel(3, 0, Color("#87ceeb")) # Clear sky blue
	palette.set_pixel(4, 0, Color("#9b6b9e")) # Soft mystic purple
	palette.set_pixel(5, 0, Color("#ffd700")) # Warm golden glow
	palette.set_pixel(6, 0, Color("#98ff98")) # Pale mint green
	palette.set_pixel(7, 0, Color("#2a1f1d")) # Rich dark brown

	# Save the palette as a PNG file
	palette.save_png("res://whimsical_forest_palette.png")
	print("Palette has been saved!")

	# Clean up by removing this node after generation
	queue_free()
