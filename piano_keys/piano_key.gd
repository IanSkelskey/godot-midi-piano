# Define a new class "PianoKey" that extends the Control node,
# representing an interactive piano key in the application.
class_name PianoKey
extends Control


const BASE_PITCH_INDEX = 69 # The MIDI note number for A4 (440 Hz). This is the frequency of the base audio sample.
const SEMITONES_PER_OCTAVE: float = 12.0

# Variable to store the pitch scale of the piano key. This scale adjusts
# the pitch of the sound played when the key is activated.
var pitch_scale: float

# Variable to store the note name of the piano key. This name is used to
var note_name: String

# Onready variables to cache important nodes and properties for later use.
# key: The visual representation of the piano key.
# start_color: The original color of the key, used to reset the key color upon deactivation.
# color_timer: A timer used to manage the duration of the color change when a key is activated.
@onready var key: ColorRect = $Key
@onready var start_color: Color = key.color
@onready var color_timer: Timer = $ColorTimer

# setup function initializes the piano key with the correct pitch scale based on its pitch index.
# pitch_index: MIDI note number for the key.
func setup(pitch_index: int):
	pitch_scale = get_pitch_scale(pitch_index) # Calculate the pitch scale based on the pitch index.
	note_name = get_note_name(pitch_index) # Get the note name based on the pitch index.

# activate function changes the key's color and plays its sound with appropriate pitch and volume.
# velocity: The MIDI velocity with which the key was pressed, affects the volume of the sound.
func activate(velocity: int):
	key.color = (Color.YELLOW + start_color) / 2 # Change the key's color to indicate activation.
	var audio := AudioStreamPlayer.new() # Create a new AudioStreamPlayer for playing the sound.
	add_child(audio) # Add the AudioStreamPlayer as a child of the PianoKey to play the sound.
	audio.stream = preload ("res://piano_keys/A440.wav") # Load the base audio sample to be played.
	audio.pitch_scale = pitch_scale # Adjust the pitch of the audio to match the key's pitch.
	audio.volume_db = velocity_to_volume(velocity) # Adjust the volume based on the MIDI velocity.
	print("Output Volume: " + str(audio.volume_db))
	audio.play() # Play the sound.
	color_timer.start() # Start the timer to revert the key's color after a set duration.
	await get_tree().create_timer(8.0).timeout # Await a timer to ensure audio plays for its duration before freeing.
	audio.queue_free() # Queue the AudioStreamPlayer to be freed after playing the sound.

# deactivate function resets the key's color to its original state.
func deactivate():
	key.color = start_color # Reset the key's color to indicate it is no longer activated.

# convert velocity to volume
func velocity_to_volume(velocity: int) -> float:
	if velocity == 0:
		print("No volume")
		return 0.0
	else:
		print("Velocity is: " + str(velocity))
		var volume = log(1 + float(velocity)/127) / log(2)
		print("Volume is: " + str(volume))
		return volume

func get_note_frequency(pitch_index: int) -> float:
	return 440.0 * get_pitch_scale(pitch_index)

func get_pitch_scale(pitch_index: int) -> float:
	var exponent := (pitch_index - BASE_PITCH_INDEX) / SEMITONES_PER_OCTAVE # Calculate the exponent for the pitch scale calculation.
	return pow(2, exponent) # Calculate the pitch scale using the exponent.
	
func get_note_name(pitch_index: int) -> String:
	var note_names = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
	return note_names[pitch_index % int(SEMITONES_PER_OCTAVE)] + str(pitch_index / int(SEMITONES_PER_OCTAVE) - 1)
