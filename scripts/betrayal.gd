# betrayal.gd
extends Node2D # Or your scene's root node type

# --- References ---
# Adjust paths/names if necessary in your Betrayal.tscn
@onready var player: CharacterBody2D = $Player
# IMPORTANT: Use the specific class name for type hint if available
@onready var commander: BetrayalCommander = $Commander
@onready var dialogue_ui: Control = $DialogueUI # Or global access path

# --- Export Variables ---
# Assign duelMain.tscn to this in the Inspector for the Betrayal scene root
@export var duel_scene_path_string: String = ""

func _ready():
	VideoManager.hide_video()
	# --- Error Checking ---
	if not is_instance_valid(player): push_error("Betrayal Error: Player node not found!"); return
	if not is_instance_valid(commander): push_error("Betrayal Error: Commander node (BetrayalCommander) not found!"); return
	if not is_instance_valid(dialogue_ui): push_error("Betrayal Error: DialogueUI node not found!"); return
	if duel_scene_path_string.is_empty(): push_warning("Betrayal Warning: Duel Scene Path String is not set in Inspector!")

	# --- Connect Signals ---
	connect_signals_if_needed()

	print("Betrayal Scene Ready.")


func connect_signals_if_needed():
	print("Betrayal: Checking and connecting signals...")

	# Connect Commander Dialogue Request
	if commander.has_signal("request_dialogue"):
		if not commander.request_dialogue.is_connected(dialogue_ui.start_dialogue):
			var err = commander.request_dialogue.connect(dialogue_ui.start_dialogue)
			if err == OK: print("Betrayal: Connected Commander.request_dialogue -> DialogueUI.start_dialogue")
			else: push_error("Betrayal Error: FAILED to connect Commander.request_dialogue! Error: %s" % err)
	else: push_error("Betrayal Error: Commander node does not have 'request_dialogue' signal!")

	# Connect Dialogue UI Finish
	if dialogue_ui.has_signal("dialogue_finished"):
		if not dialogue_ui.dialogue_finished.is_connected(player.end_dialogue):
			var err = dialogue_ui.dialogue_finished.connect(player.end_dialogue)
			if err == OK: print("Betrayal: Connected DialogueUI.dialogue_finished -> Player.end_dialogue")
			else: push_error("Betrayal Error: FAILED to connect DialogueUI.dialogue_finished! Error: %s" % err)
	else: push_error("Betrayal Error: DialogueUI node does not have 'dialogue_finished' signal!")

	# Connect Player Interaction Prompt
	if player.has_signal("can_interact_changed"):
		if not player.can_interact_changed.is_connected(dialogue_ui._on_player_can_interact_changed):
			var err = player.can_interact_changed.connect(dialogue_ui._on_player_can_interact_changed)
			if err == OK: print("Betrayal: Connected Player.can_interact_changed -> DialogueUI._on_player_can_interact_changed")
			else: push_error("Betrayal Error: FAILED to connect Player.can_interact_changed! Error: %s" % err)
	else: push_error("Betrayal Error: Player node does not have 'can_interact_changed' signal!")

	# Connect Commander Duel Start Signal
	if commander.has_signal("start_duel"):
		if not commander.start_duel.is_connected(_on_commander_start_duel):
			var err = commander.start_duel.connect(_on_commander_start_duel)
			if err == OK: print("Betrayal: Connected Commander.start_duel -> _on_commander_start_duel")
			else: push_error("Betrayal Error: FAILED to connect Commander.start_duel! Error: %s" % err)
	else:
		push_error("Betrayal Error: Commander does not have 'start_duel' signal!")

	print("Betrayal: Signal connection check complete.")


func _on_commander_start_duel():
	print("Betrayal: Received start_duel signal. Transitioning to duel scene.")
	if not duel_scene_path_string.is_empty():
		var loaded_scene = load(duel_scene_path_string)
		if loaded_scene:
			var err = get_tree().change_scene_to_packed(loaded_scene)
			if err != OK:
				push_error("Betrayal Error: Failed to change scene to duel! Error: %s" % err)
		else:
			push_error("Betrayal Error: Failed to load duel scene from path: %s" % duel_scene_path_string)
	else:
		push_error("Betrayal Error: Duel scene path string not set in Inspector!")
