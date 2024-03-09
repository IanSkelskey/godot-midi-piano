extends Node2D

const NOTE_SPEED = 200

const BASE_PITCH_INDEX = 69 # The MIDI note number for A4 (440 Hz). This is the frequency of the base audio sample.
const SEMITONES_PER_OCTAVE: float = 12.0

signal sound_note(note: int)

var notes = []
var notes_on = {}

var midi_player: MidiPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	midi_player = $MidiPlayer
	midi_player.loop = false
	midi_player.note.connect(on_note)
	midi_player.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	midi_player.process_delta(delta)
	_process_notes(delta)

func _spawn_note(note_value):
	const START_Y_POSITION = 507
	var note_rect = ColorRect.new()
	note_rect.color = Color(1, 0, 0)  # Red color for visibility
	note_rect.size = Vector2(20, 20)
	add_child(note_rect)
	note_rect.position.x = 14.7 * (note_value - 21)  # Use note_value for positioning
	note_rect.position.y = START_Y_POSITION
	notes.append(note_rect)

	var note_label = Label.new()
	note_label.text = str(note_value)
	note_label.size = Vector2(20, 20)
	note_rect.add_child(note_label)

func _process_notes(delta):
	for note in notes:
		note.position.y -= delta * NOTE_SPEED
		if note.position.y < 0:
			notes.remove_at(notes.find(note))
			note.queue_free()

func on_note(event, track):
	print("Callback: " + str(event) + " " + str(track))
	if event['subtype'] == MIDI_MESSAGE_NOTE_ON:  # note on
		print("Note on: " + str(event['note']))
		notes_on[event['note']] = true  # Just mark note as active, no need to store track here
		_spawn_note(event['note'])  # Spawn note using note value
	elif event['subtype'] == MIDI_MESSAGE_NOTE_OFF:  # note off
		print("Note off: " + str(event['note']))
		notes_on.erase(event['note'])
		sound_note.emit(event['note'])  # Emit signal with note value
		
