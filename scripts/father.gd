extends CharacterBody2D

# Signal emitted when interaction should start, passing the dialogue lines DATA
signal request_dialogue(dialogue_data) # Changed signal argument name

# --- NEW DIALOGUE STRUCTURE ---
# Export an array of dictionaries. Edit this in the Inspector!
# Each dictionary needs "speaker" (String) and "line" (String) keys.
@export var dialogue_data: Array[Dictionary] = [
	# Existing Start
	{ "speaker": "Father", "line": "Thorgestr. You carry the dust of the raid well. Reykjanesta is secure thanks to your spear arm." },
	{ "speaker": "Player", "line": "The Westerners paid dearly for their treachery, Father. Their hall fell silent." },
	{ "speaker": "Father", "line": "Aye, their silence cost us good men... too many brothers now feast in Odin's Hall." }, # Slightly modified

	# Added Mourning/Gods Section
	{ "speaker": "Father", "line": "We must honour them properly. Tonight, we raise horns high and pray they found glorious passage." },
	{ "speaker": "Player", "line": "Their courage will be sung by the skalds. Their sacrifice strengthens Reykjanesta." },
	{ "speaker": "Father", "line": "It must. But victory always has a price. Remember that weight, always." }, # Reiteration of theme

	# Existing Foreshadowing + NEW Task
	{ "speaker": "Father", "line": "Now, listen. The Seer spoke of shifting shadows... whispers on the wind from the north. Vigilance is key." },
	{ "speaker": "Father", "line": "Report to Commander Bjorn. He's inside the Great Hall, likely near the strategy table, organizing the watch. Go." }, # Added Task
	{ "speaker": "Player", "line": "I understand. I will find Commander Bjorn at once. Skål, Father." } # Added Acknowledgement
]
# ---------------------------------

@onready var interaction_area: Area2D = $InteractionArea

func interact(player_node):
	print("Father: Player %s interacted with me!" % player_node.name)

	print("Father: Emitting dialogue data: %s" % str(dialogue_data)) # Debug print
	if dialogue_data.is_empty():
		push_warning("Father: Trying to emit empty dialogue data!")
		# If empty, maybe emit a default line instead of crashing the UI?
		request_dialogue.emit([{"speaker": "Father", "line": "..."}]) # Example fallback
		return

	# Emit the structured dialogue data
	request_dialogue.emit(dialogue_data) # Pass the array of dictionaries

func _ready():
	interaction_area.monitoring = true
	print("Father NPC '%s' Ready. Interactable Group Added." % name)

func _physics_process(delta):
	pass # No movement needed currently
