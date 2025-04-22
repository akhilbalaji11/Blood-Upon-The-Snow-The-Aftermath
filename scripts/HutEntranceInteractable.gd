# HutEntranceInteractable.gd
extends Node2D

# This function will be called BY the player when they interact
func interact(player_node):
	# Using %s formatting for the player's name
	print("HutEntrance: Player %s interacted with the entrance." % player_node.name)

	# --- TODO LATER ---
	# Add logic here to change scene, e.g.:
	get_tree().change_scene_to_file("res://scenes/Hall.tscn")
	# Maybe play a door opening sound
	# Maybe fade out/in
	# -----------------

	# For now, we just print the message.
	pass

# Optional _ready function if needed later
#func _ready():
#	pass
