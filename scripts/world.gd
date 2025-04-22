extends Node2D # Or whatever your world root node is

@onready var player: CharacterBody2D = $Player # Adjust path if needed
@onready var father: Node2D = $Father # Adjust path if needed
@onready var dialogue_ui: Control = $DialogueUI # Adjust path if needed

func _ready():
	# --- Error checking ---
	if player == null: push_error("World Error: Player node not found!"); return
	if father == null: push_error("World Error: Father node not found!"); return
	if dialogue_ui == null: push_error("World Error: DialogueUI node not found!"); return

	# --- Connect Dialogue Signals ---
	if father.has_signal("request_dialogue"):
		father.request_dialogue.connect(dialogue_ui.start_dialogue)
		print("World: Connected Father.request_dialogue -> DialogueUI.start_dialogue")
	else: push_error("World Error: Father node does not have 'request_dialogue' signal!")

	if dialogue_ui.has_signal("dialogue_finished"):
		if player.has_method("end_dialogue"):
			dialogue_ui.dialogue_finished.connect(player.end_dialogue)
			print("World: Connected DialogueUI.dialogue_finished -> Player.end_dialogue")
		else: push_error("World Error: Player node does not have 'end_dialogue' method!")
	else: push_error("World Error: DialogueUI node does not have 'dialogue_finished' signal!")

	# --- Connect Player Interaction Prompt Signal ---
	# VVVV --- ADD THIS CONNECTION --- VVVV
	if player.has_signal("can_interact_changed"):
		# Make sure DialogueUI script HAS the '_on_player_can_interact_changed' function.
		if dialogue_ui.has_method("_on_player_can_interact_changed"):
			player.can_interact_changed.connect(dialogue_ui._on_player_can_interact_changed)
			print("World: Connected Player.can_interact_changed -> DialogueUI._on_player_can_interact_changed")
		else:
			push_error("World Error: DialogueUI node does not have '_on_player_can_interact_changed' method!")
	else:
		push_error("World Error: Player node does not have 'can_interact_changed' signal!")
	# ^^^^ --- ADD THIS CONNECTION --- ^^^^

	print("World Ready. Signal connections established.")
