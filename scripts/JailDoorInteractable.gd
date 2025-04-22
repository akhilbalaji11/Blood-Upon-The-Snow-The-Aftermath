# JailDoorInteractable.gd
extends Node2D

# --- CHANGED TO STRING ---
# Assign the *path* (e.g., "res://scenes/LockpickMinigame.tscn") in the Inspector
@export var lockpick_minigame_scene_path: String = "res://scenes/LockpickMinigame.tscn"
# -------------------------

func interact(player_node):
	print("Jail Door: Player %s trying to pick the lock." % player_node.name)

	if not lockpick_minigame_scene_path.is_empty():
		# --- Load the scene using the path ---
		var loaded_scene = load(lockpick_minigame_scene_path)
		# -------------------------------------
		if loaded_scene:
			var err = get_tree().change_scene_to_packed(loaded_scene)
			if err != OK:
				push_error("Jail Door: Failed to change scene to lockpick minigame! Error: %s" % err)
		else:
			push_error("Jail Door: Failed to load lockpick scene from path: %s" % lockpick_minigame_scene_path)
	else:
		push_error("Jail Door: Lockpick minigame scene path string not set in Inspector!")
