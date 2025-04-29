extends Node2D # Or your hall's root node type

# --- References ---
# Ensure these nodes exist in hall.tscn with these names/paths
@onready var player: CharacterBody2D = $Player
@onready var commander: CharacterBody2D = $Commander # Or StaticBody2D, ensure it uses the right script (commander.gd)
@onready var dialogue_ui: Control = $DialogueUI # Adjust path/access if needed

# --- Export Variables ---
# Assign your archery minigame scene path in the Inspector for the hall node
@export var archery_minigame_scene: PackedScene # Use PackedScene for better checking

func _ready():
	# --- Error Checking ---
	if not is_instance_valid(player): push_error("Hall Error: Player node not found!"); return
	if not is_instance_valid(commander): push_error("Hall Error: Commander node not found!"); return
	if not is_instance_valid(dialogue_ui): push_error("Hall Error: DialogueUI node not found!"); return
	if not archery_minigame_scene: push_warning("Hall Warning: Archery Minigame Scene not assigned in Inspector!")

	# --- Connect Signals ---
	connect_signals_if_needed()

	print("Hall Ready. Signal connections established (check logs for errors).")


func connect_signals_if_needed():
	"""Connects signals, checking first to prevent duplicates."""
	print("Hall: Checking and connecting signals...")
	var error_flag := false # Flag to track if any connection failed

	# Check/Connect Commander Dialogue Request
	if is_instance_valid(commander) and commander.has_signal("request_dialogue"):
		if is_instance_valid(dialogue_ui) and dialogue_ui.has_method("start_dialogue"):
			if not commander.request_dialogue.is_connected(dialogue_ui.start_dialogue):
				var err = commander.request_dialogue.connect(dialogue_ui.start_dialogue)
				if err == OK: 
					print("Hall: Connected Commander.request_dialogue -> DialogueUI.start_dialogue")
				else: 
					push_error("Hall Error: FAILED connect Commander.request_dialogue! Error: %s" % err); error_flag = true
			else: push_error("Hall Error: DialogueUI invalid/missing method for Balgruuf connection!"); error_flag = true
	else: push_error("Hall Error: Commander node missing or lacks 'request_dialogue' signal!"); error_flag = true

	# Check/Connect Dialogue UI Finish
	if is_instance_valid(dialogue_ui) and dialogue_ui.has_signal("dialogue_finished"):
		if is_instance_valid(player) and player.has_method("end_dialogue"):
			if not dialogue_ui.dialogue_finished.is_connected(player.end_dialogue):
				var err = dialogue_ui.dialogue_finished.connect(player.end_dialogue)
				if err == OK: 
					print("Hall: Connected DialogueUI.dialogue_finished -> Player.end_dialogue")
				else: 
					push_error("Hall Error: FAILED connect DialogueUI.dialogue_finished! Error: %s" % err); error_flag = true
		else: push_error("Hall Error: Player invalid/missing method for DialogueUI connection!"); error_flag = true
	else: push_error("Hall Error: DialogueUI node missing or lacks 'dialogue_finished' signal!"); error_flag = true

	# Check/Connect Player Interaction Prompt
	if is_instance_valid(player) and player.has_signal("can_interact_changed"):
		if is_instance_valid(dialogue_ui) and dialogue_ui.has_method("_on_player_can_interact_changed"):
			if not player.can_interact_changed.is_connected(dialogue_ui._on_player_can_interact_changed):
				var err = player.can_interact_changed.connect(dialogue_ui._on_player_can_interact_changed)
				if err == OK: 
					print("Hall: Connected Player.can_interact_changed -> DialogueUI._on_player_can_interact_changed")
				else: 
					push_error("Hall Error: FAILED connect Player.can_interact_changed! Error: %s" % err); error_flag = true
		else: push_error("Hall Error: DialogueUI invalid/missing method for Player connection!"); error_flag = true
	else: push_error("Hall Error: Player node missing or lacks 'can_interact_changed' signal!"); error_flag = true

	# Check/Connect Commander Minigame Start Signal
	if is_instance_valid(commander) and commander.has_signal("start_minigame"):
		if not commander.start_minigame.is_connected(_on_commander_start_minigame):
			var err = commander.start_minigame.connect(_on_commander_start_minigame)
			if err == OK: print("Hall: Connected Commander.start_minigame -> _on_commander_start_minigame")
			else: push_error("Hall Error: FAILED connect Commander.start_minigame! Error: %s" % err); error_flag = true
	else: push_error("Hall Error: Commander node missing or lacks 'start_minigame' signal!"); error_flag = true

	# --- ADDED: Connect DialogueUI line signal to Commander handler ---
	if is_instance_valid(dialogue_ui) and dialogue_ui.has_signal("line_will_display"):
		 # Make sure commander instance is valid AND has the handler method
		if is_instance_valid(commander) and commander.has_method("_on_dialogue_line_will_display"):
			if not dialogue_ui.line_will_display.is_connected(commander._on_dialogue_line_will_display):
				var err = dialogue_ui.line_will_display.connect(commander._on_dialogue_line_will_display)
				if err == OK:
					print("Hall: Connected DialogueUI.line_will_display -> Commander._on_dialogue_line_will_display")
				else: 
					push_error("Hall Error: FAILED connect DialogueUI.line_will_display to Commander! Error: %s" % err); error_flag = true
			else:
				push_error("Hall Error: Commander invalid or missing '_on_dialogue_line_will_display' method!")
		else:
			push_error("Hall Error: DialogueUI node does not have 'line_will_display' signal!")
	# ------------------------------------------------------------------

	if not error_flag:
		print("Hall: All signal connections checked/established successfully.")
	else:
		print("Hall WARNING: One or more signal connections failed. Check errors above.")


# Handles the signal FROM the commander AFTER dialogue is totally done
func _on_commander_start_minigame():
	print("Hall: Received start_minigame signal from Commander.")

	# Transition to the archery minigame scene
	if archery_minigame_scene: # Check if PackedScene is assigned
		print("Hall: Changing scene to archery minigame.")
		var err = get_tree().change_scene_to_packed(archery_minigame_scene)
		if err != OK:
			print("Hall Error: Failed to change scene! Code: %s" % err)
	else:
		push_error("Hall Error: Archery minigame scene PackedScene not assigned in Hall script Inspector!")
