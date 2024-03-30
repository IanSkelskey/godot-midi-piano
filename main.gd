extends Node2D

const NOTE_SPEED = 200
const FALL_DISTANCE = 507

var delay_time : float

signal sound_note(note: int)

var notes = []
var notes_on = {}

var midi_player: MidiPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	delay_time = FALL_DISTANCE / float(NOTE_SPEED)
	midi_player = $MidiPlayer
	midi_player.loop = false
	midi_player.note.connect(on_note)
	midi_player.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	midi_player.process_delta(delta)
	_process_notes(delta)

func _spawn_note(note_value):
	const START_Y_POSITION = 0
	var note_rect = ColorRect.new()
	note_rect.color = Color(1, 0, 0)  # Red color for visibility
	note_rect.size = Vector2(20, 20)
	add_child(note_rect)
	note_rect.position.x = 14.7 * (note_value - 21)  # Use note_value for positioning
	note_rect.position.y = START_Y_POSITION
	notes.append(note_rect)
	# Add note label
	var note_label = Label.new()
	note_label.text = str(note_value)
	note_label.size = Vector2(20, 20)
	note_rect.add_child(note_label)

func _process_notes(delta):
	for note in notes:
		note.position.y += delta * NOTE_SPEED
		if note.position.y > 497:
			notes.remove_at(notes.find(note))
			note.queue_free()
			

func on_note(event, track):
	print("Event: ", event, " Track: ", track)
	if track == 4:
		return
	if event['subtype'] == MIDI_MESSAGE_NOTE_ON:  # note on
		notes_on[event['note']] = true  # Just mark note as active, no need to store track here
		_spawn_note(event['note'])  # Spawn note using note value
		# Sound the note after a delay
		var delay_timer = Timer.new()
		delay_timer.wait_time = delay_time
		delay_timer.one_shot = true
		delay_timer.timeout.connect(on_note_timer_timeout.bind(event['note']))
		add_child(delay_timer)
		delay_timer.start()

	elif event['subtype'] == MIDI_MESSAGE_NOTE_OFF:  # note off
		notes_on.erase(event['note'])
		
		
func on_note_timer_timeout(note : int):
	sound_note.emit(note)
