extends Node2D # Or your hall's root node type

# --- References ---
# Ensure these nodes exist in hall.tscn with these names/paths
@onready var player: CharacterBody2D = $Player
@onready var commander: CharacterBody2D = $Commander # Or StaticBody2D
# ASSUMPTION: DialogueUI is also instanced in hall.tscn or globally accessible
# If global, use: get_node("/root/GlobalUISingleton/DialogueUI") or similar
@onready var dialogue_ui: Control = $DialogueUI

@export var archery_minigame_scene: PackedScene # Assign archery scene in Inspector

func _ready():
	# --- Error Checking ---
	if not is_instance_valid(player): push_error("Hall Error: Player node not found!"); return
	if not is_instance_valid(commander): push_error("Hall Error: Commander node not found!"); return
	if not is_instance_valid(dialogue_ui): push_error("Hall Error: DialogueUI node not found!"); return

	# --- Connect Dialogue Signals ---
	if commander.has_signal("request_dialogue"):
		commander.request_dialogue.connect(dialogue_ui.start_dialogue)
		print("Hall: Connected Commander.request_dialogue -> DialogueUI.start_dialogue")
	else: push_error("Hall Error: Commander node does not have 'request_dialogue' signal!")

	if dialogue_ui.has_signal("dialogue_finished"):
		if player.has_method("end_dialogue"):
			dialogue_ui.dialogue_finished.connect(player.end_dialogue)
			print("Hall: Connected DialogueUI.dialogue_finished -> Player.end_dialogue")
		else: push_error("Hall Error: Player node does not have 'end_dialogue' method!")
	else: push_error("Hall Error: DialogueUI node does not have 'dialogue_finished' signal!")

	# --- Connect Player Interaction Prompt Signal ---
	if player.has_signal("can_interact_changed"):
		if dialogue_ui.has_method("_on_player_can_interact_changed"):
			player.can_interact_changed.connect(dialogue_ui._on_player_can_interact_changed)
			print("Hall: Connected Player.can_interact_changed -> DialogueUI._on_player_can_interact_changed")
		else: push_error("Hall Error: DialogueUI node does not have '_on_player_can_interact_changed' method!")
	else: push_error("Hall Error: Player node does not have 'can_interact_changed' signal!")

	# --- Connect Commander Minigame Start Signal ---
	if commander.has_signal("start_minigame"):
		commander.start_minigame.connect(_on_commander_start_minigame)
		print("Hall: Connected Commander.start_minigame -> _on_commander_start_minigame")
	else:
		push_error("Hall Error: Commander does not have 'start_minigame' signal!")

	print("Hall Ready. Signal connections established.")


func _on_commander_start_minigame():
	print("Hall: Received start_minigame signal from Commander.")
	# Optional: Add a slight delay here if needed after the warcry sound starts
	# await get_tree().create_timer(0.5).timeout
	
	# Transition to the archery minigame scene
	if archery_minigame_scene:
		print("Hall: Changing scene to archery minigame.")
		var err = get_tree().change_scene_to_packed(archery_minigame_scene)
		if err != OK:
			print("Hall Error: Failed to change scene! Code: %s" % err)
	else:
		push_error("Hall Error: Archery minigame scene path not set in Hall script Inspector!")
