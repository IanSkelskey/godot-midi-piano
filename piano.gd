extends Control

# Constants defining the range of piano keys. These can be adjusted to simulate different piano sizes.
const START_KEY = 21 # Standard piano start key (A0).
const END_KEY = 108 # Standard piano end key (C8).

# Preloaded scenes for white and black piano keys.
const WhiteKeyScene = preload("res://piano_keys/white_piano_key.tscn")
const BlackKeyScene = preload("res://piano_keys/black_piano_key.tscn")

# Dictionary to hold the mapping of pitch indexes to piano key instances.
var piano_key_dict := Dictionary()

# Nodes for organizing white and black keys visually.
@onready var white_keys = $WhiteKeys
@onready var black_keys = $BlackKeys

func _ready():
	# Ensure the starting key is not a sharp note due to layout constraints.
	if _is_note_index_sharp(_pitch_index_to_note_index(START_KEY)):
		printerr("The start key can't be a sharp note. Try 21.")
		return

	# Generate and add piano keys for the defined range.
	for i in range(START_KEY, END_KEY + 1):
		piano_key_dict[i] = _create_piano_key(i)

	# Add a placeholder key to balance the layout if necessary.
	if white_keys.get_child_count() != black_keys.get_child_count():
		_add_placeholder_key(black_keys)

	open_midi_inputs() # Open MIDI inputs to receive events from connected MIDI devices.

func _input(input_event):
	# Process only MIDI input events.
	if not (input_event is InputEventMIDI):
		return

	var midi_event: InputEventMIDI = input_event
	# Ignore MIDI pitches outside the configured range of the piano.
	if midi_event.pitch < START_KEY or midi_event.pitch > END_KEY:
		return

	_print_midi_info(midi_event) # Debugging: Print information about the MIDI event.

	# Activate or deactivate the corresponding key visual based on MIDI message.
	var key: PianoKey = piano_key_dict[midi_event.pitch]
	if midi_event.message == MIDI_MESSAGE_NOTE_ON:
		key.activate(midi_event.velocity)
		$"../CurrentNote".text = key.note_name
	else:
		key.deactivate()

func _add_placeholder_key(container):
	# Adds an invisible placeholder to the key container for layout purposes.
	var placeholder = Control.new()
	placeholder.size_flags_horizontal = SIZE_EXPAND_FILL
	placeholder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	placeholder.name = "Placeholder"
	container.add_child(placeholder)

func _create_piano_key(pitch_index):
	# Creates a piano key instance based on the pitch index.
	var note_index = _pitch_index_to_note_index(pitch_index)
	var piano_key: PianoKey
	if _is_note_index_sharp(note_index):
		# For sharp notes, use black key visuals.
		piano_key = BlackKeyScene.instantiate()
		black_keys.add_child(piano_key)
	else:
		# For natural notes, use white key visuals.
		piano_key = WhiteKeyScene.instantiate()
		white_keys.add_child(piano_key)
		# Add placeholder for layout if a sharp note is missing next to this key.
		if _is_note_index_lacking_sharp(note_index):
			_add_placeholder_key(black_keys)
	piano_key.setup(pitch_index) # Initialize the piano key.
	return piano_key

func _is_note_index_lacking_sharp(note_index: int):
	# Determines if a natural note should not have a sharp note next to it (e.g., B, E).
	return note_index in [2, 7]

func _is_note_index_sharp(note_index: int):
	# Determines if a note index corresponds to a sharp note.
	return note_index in [1, 4, 6, 9, 11]

func _pitch_index_to_note_index(pitch: int):
	# Converts a MIDI pitch to a note index, adjusting for octave.
	pitch += 3
	return pitch % 12

func _print_midi_info(midi_event: InputEventMIDI):
	# Utility function to print detailed information about a MIDI event.
	print(midi_event)
	print("Channel: " + str(midi_event.channel))
	print("Message: " + str(midi_event.message))
	print("Pitch: " + str(midi_event.pitch))
	print("Velocity: " + str(midi_event.velocity))
	print("Instrument: " + str(midi_event.instrument))
	print("Pressure: " + str(midi_event.pressure))
	print("Controller number: " + str(midi_event.controller_number))
	print("Controller value: " + str(midi_event.controller_value))

func open_midi_inputs():
	OS.open_midi_inputs()
	print(OS.get_connected_midi_inputs()) # Log the detected MIDI devices.
	

func _on_midi_device_refresh_button_pressed():
	open_midi_inputs()

