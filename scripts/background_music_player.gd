# BackgroundMusicPlayer.gd
extends Node

# Reference to the actual AudioStreamPlayer child node
# Make sure your AudioStreamPlayer is named "MusicPlayer" in the scene
@onready var music_player: AudioStreamPlayer = $MusicPlayer

# Export the initial volume so you can tweak it easily in the Inspector
# -10 dB is noticeably quieter, -20 dB is quite low. -80 is basically silent.
@export var initial_volume_db: float = -30.0

func _ready():
	# Check if the MusicPlayer node was found correctly
	if not is_instance_valid(music_player):
		push_error("BackgroundMusicPlayer Error: Could not find child node 'MusicPlayer'!")
		return # Stop if node is missing

	# Set the initial volume BEFORE it starts playing (or very shortly after)
	print("[BackgroundMusic] Setting initial volume to %s dB" % initial_volume_db)
	music_player.volume_db = initial_volume_db

	# Autoplay is handled by the AudioStreamPlayer node's property set in the editor.
	# If Autoplay was OFF, you would add 'music_player.play()' here after setting volume.
