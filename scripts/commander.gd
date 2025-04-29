# commander.gd (The one used in hall.tscn)
extends CharacterBody2D # Or StaticBody2D

# Signal emitted when interaction should start, passing the dialogue lines DATA
signal request_dialogue(dialogue_data)
# Signal emitted AFTER dialogue finishes, to trigger the minigame
signal start_minigame

# --- Nodes ---
@onready var interaction_area: Area2D = $InteractionArea
# Ensure this node exists in commander.tscn and sound is assigned
@onready var warcry_sound: AudioStreamPlayer = $WarcrySound

# --- Dialogue Content ---
# Line Indices: 0, 1, 2, 3, 4, 5, 6 (Final Line Index is 6)
@export var dialogue_data: Array[Dictionary] = [
	{ "speaker": "Commander", "line": "Thorgestr! The Old Man said you'd report. Step forward." },
	{ "speaker": "Player", "line": "Commander Bjorn. Ready for duty." },
	{ "speaker": "Commander", "line": "Duty well served in that western raid. Saw you hold the line - you fight with the heart of a true Viking!" },
	{ "speaker": "Player", "line": "Thank you, Commander. We showed them Reykjanesta's strength." },
	{ "speaker": "Commander", "line": "Aye. But strength must be honed. Victory yesterday means nothing tomorrow if our skills dull. Threats linger, always." },
	{ "speaker": "Commander", "line": "We prepare! We endure! We prove our might!" },
	{ "speaker": "Commander", "line": "THE RATS HAVE FOLLOWED US HERE! GRAB YOUR BOW THORGESTR! SHOW ME WHAT YOU'RE CAPABLE OF!" } # Final Line
]

func _ready():
	# Ensure interaction area is monitorable if needed for area-based detection
	if interaction_area:
		interaction_area.monitoring = true # Or false if only player detects it
		interaction_area.monitorable = true # Crucial for player's Area2D detection
	else:
		push_warning("Commander has no InteractionArea node!")

	# Check for WarcrySound node on ready
	if not warcry_sound:
		push_warning("Commander '%s' is missing WarcrySound node!" % name)

	print("Commander NPC '%s' Ready (Hall version)." % name)


# This function is called BY the player when they press E
func interact(player_node):
	print("Commander: Player %s interacted with me! (Hall version)" % player_node.name)

	# Start the dialogue sequence via the UI
	if dialogue_data.is_empty():
		push_warning("Commander: Dialogue data is empty!")
		return

	request_dialogue.emit(dialogue_data)


# --- NEW SIGNAL HANDLER ---
# This function needs to be connected FROM DialogueUI.line_will_display signal in hall.gd
func _on_dialogue_line_will_display(line_index: int, speaker: String):
	# Determine the index of the final line
	var final_line_index = dialogue_data.size() - 1

	# Check if the speaker is the Commander and if the line about to be displayed IS the final one
	if speaker == "Commander" and line_index == final_line_index:
		print("Commander: Playing warcry before final line (index %d)." % line_index)
		if warcry_sound:
			warcry_sound.play()
		else:
			print("Commander Warning: Cannot play warcry, WarcrySound node missing or invalid!")
# ---------------------------


# --- MODIFIED: Removed warcry play ---
# This function is called BY the PLAYER script after the *entire* dialogue sequence finishes
func trigger_post_dialogue_action():
	print("Commander: Dialogue finished. Signaling minigame start.")
	# Warcry is now played BEFORE the last line via the signal handler above.
	# Just emit the signal to start the next phase.
	start_minigame.emit()
# ------------------------------------


# Add basic physics process if it's a CharacterBody2D, otherwise remove
func _physics_process(delta):
	pass
