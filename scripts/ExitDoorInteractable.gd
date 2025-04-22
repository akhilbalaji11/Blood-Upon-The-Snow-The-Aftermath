# ExitDoorInteractable.gd
extends Node2D

# Assign the *next* scene (before last minigame) in the Inspector
@export var next_main_scene_path: PackedScene

# Called BY the player IF this node is made interactable
func interact(player_node):
	print("Exit Door: Player %s proceeding." % player_node.name)

	if next_main_scene_path:
		var err = get_tree().change_scene_to_packed(next_main_scene_path)
		if err != OK:
			push_error("Exit Door: Failed to change scene! Error: %s" % err)
	else:
		push_error("Exit Door: Next main scene path not set in Inspector!")
