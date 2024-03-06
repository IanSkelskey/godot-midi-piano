# Extends the ColorRect class, allowing this script to inherit properties and methods of a ColorRect node.
extends ColorRect

# Onready keyword is used to initialize the 'parent' variable once the node is ready.
# This variable holds a reference to this node's parent in the scene tree.
@onready var parent = get_parent()

# The method '_gui_input' is overridden to handle GUI input events for this ColorRect node.
func _gui_input(input_event):
	# Check if the input event is a mouse button event and if the button was pressed (not released).
	if input_event is InputEventMouseButton and input_event.pressed:
		# Call the 'activate' method on the parent node.
		# This assumes the parent node has an 'activate' method implemented, which will be executed in response to the mouse button press.
		parent.activate(127)
