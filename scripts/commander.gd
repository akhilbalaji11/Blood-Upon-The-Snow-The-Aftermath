extends CharacterBody2D # Or StaticBody2D

# Signal emitted when interaction should start, passing the dialogue lines DATA
signal request_dialogue(dialogue_data)
# Signal emitted AFTER dialogue finishes, to trigger the minigame
signal start_minigame

# --- Nodes ---
@onready var interaction_area: Area2D = $InteractionArea
@onready var warcry_sound: AudioStreamPlayer = $WarcrySound

# --- Dialogue Content ---
@export var dialogue_data: Array[Dictionary] = [
	{ "speaker": "Commander", "line": "Thorgestr! The Old Man said you'd report. Step forward." },
	{ "speaker": "Player", "line": "Commander Bjorn. Ready for duty." },
	{ "speaker": "Commander", "line": "Duty well served in that western raid. Saw you hold the line - you fight with the heart of a true Viking!" },
	{ "speaker": "Player", "line": "Thank you, Commander. We showed them Reykjanesta's strength." },
	{ "speaker": "Commander", "line": "Aye. But strength must be honed. Victory yesterday means nothing tomorrow if our skills dull. Threats linger, always." },
	{ "speaker": "Commander", "line": "We prepare! We endure! We prove our might!" },
	{ "speaker": "Commander", "line": "THE RATS HAVE FOLLOWED US HERE! GRAB YOUR BOW THORGESTR! SHOW ME WHAT YOU'RE CAPABLE OF" } # This line's completion will trigger the warcry
]

func _ready():
	# Ensure interaction area is monitorable if needed for area-based detection
	if interaction_area:
		interaction_area.monitoring = true # Or false if only player detects it
		interaction_area.monitorable = true # Crucial for player's Area2D detection
	else:
		push_warning("Commander has no InteractionArea node!")

	print("Commander NPC '%s' Ready. Interactable Group Added." % name)


# This function is called BY the player when they press E
func interact(player_node):
	print("Commander: Player %s interacted with me!" % player_node.name)

	# Start the dialogue sequence via the UI
	if dialogue_data.is_empty():
		push_warning("Commander: Dialogue data is empty!")
		# Emit default line? request_dialogue.emit([{"speaker": "Commander", "line":"..."}])
		return

	request_dialogue.emit(dialogue_data)


# This function is called BY the PLAYER script after the dialogue finishes
func trigger_post_dialogue_action():
	print("Commander: Dialogue finished. Playing warcry and signaling minigame start.")
	if warcry_sound:
		warcry_sound.play()
	else:
		push_warning("Commander: WarcrySound node not found or assigned!")

	# Wait briefly for sound? Or just emit. Add delay in Hall script if needed.
	start_minigame.emit()


# Add basic physics process if it's a CharacterBody2D, otherwise remove
func _physics_process(delta):
	pass
