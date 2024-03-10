# MIDI Piano

This sprite art is for concept only and is not included in the demo.

![Logo](logo_4x.png)

This demo shows how to use
[InputEventMIDI](https://docs.godotengine.org/en/latest/classes/class_inputeventmidi.html)
by creating a piano that can be controlled by a MIDI device.
This is known to work with a `Yamaha MX88` as well as a `Casio Privia PX-160`.

The piano can also be controlled by clicking on the keys, or by
manually calling the activate and deactivate methods on each key.

Note that MIDI output is not yet supported in Godot, only input works.

Language: GDScript

Renderer: GLES 2

Check out this demo on the asset library: https://godotengine.org/asset-library/asset/1292

## Features

- **MIDI File Playback** - Load and play MIDI files.
- **Dynamic Note Visualization** - Connects the `note` signal from `MidiPlayer` to a function that dynamically spawns and despawns visual representations of notes. These visual notes appear at a starting y-position of 0, with their x-positions determined by their pitch, creating a falling note animation towards the piano.
- **Audio and Visual Synchronization** - Implements a delay between the appearance of midi notes on the screen and the corresponding audio playback. This delay is calculated based on the time it takes for a note to travel down to the piano, determined by `NOTE_SPEED/FALL_DISTANCE`.
- **Single Audio Sample Pitch Scaling** - Utilizes a single audio sample provided in the official midi-piano demo by Godot, specifically the pitch A440, which is then scaled to match all other keys.
- **Live MIDI Instrument Support** - Allows for live playing on a connected MIDI instrument, with notes sounding in real-time alongside the MIDI file playback.
- **MIDI Device Refresh** - Includes a button at the top left of the screen to refresh the list of connected MIDI devices, useful if the game is started before the device is connected or if new devices are connected mid-session.

## Screenshots

![Screenshot](screenshots/piano-pressed.png)
