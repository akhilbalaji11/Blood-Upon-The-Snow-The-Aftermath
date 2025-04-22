# balgruuf.gd
extends CharacterBody2D # Or StaticBody2D

# Signal emitted when interaction should start, passing the dialogue lines DATA
signal request_dialogue(dialogue_data)

# --- Nodes ---
# Ensure this node exists and is named correctly in balgruuf.tscn
@onready var interaction_area: Area2D = $InteractionArea

# --- Dialogue Content ---
var initial_dialogue_data: Array[Dictionary] = [
	{ "speaker": "Balgruuf", "line": "Thorgestr? By Odin's beard, you too? What happened out there?" },
	{ "speaker": "Player", "line": "Balgruuf! I... They overpowered me, then darkness. Woke up in this cage. Husavik scum, must be." },
	{ "speaker": "Balgruuf", "line": "Aye, looks like some survivors weren't content with just running. Followed us right back to Reykjanesta's heart." },
	{ "speaker": "Balgruuf", "line": "But... something feels wrong. They moved too fast, knew the layout too well. Like rats guided through the walls." },
	{ "speaker": "Player", "line": "Insider help? You think someone betrayed us?" },
	{ "speaker": "Balgruuf", "line": "My gut screams it. But accusations are wind without proof. Right now, proof is getting out of this damn cell." },
	{ "speaker": "Player", "line": "How? This lock looks solid." },
	{ "speaker": "Balgruuf", "line": "Found these picks on one of the guards they overpowered." }, # He 'shows' them conceptually
	{ "speaker": "Balgruuf", "line": "Never had the knack myself, but I hear you've got nimble fingers. Five tumblers, they said. Strong iron. Give it a try?" }
]

# Dialogue after escaping the cell
var post_escape_dialogue_data: Array[Dictionary] = [
	{ "speaker": "Balgruuf", "line": "Ha! You did it, Thorgestr! Knew those hands weren't just for swinging an axe." },
	{ "speaker": "Player", "line": "That was tougher than it looked. Now what? We need to get out of here." },
	{ "speaker": "Balgruuf", "line": "And find out who sold us out. This stinks worse than Nídhöggr's breath. Someone wanted us out of the way." },
	{ "speaker": "Balgruuf", "line": "Find the truth, Thorgestr. Hunt down the traitors and end this Husavik threat for good. Their roots may run deeper than we thought." },
	{ "speaker": "Player", "line": "I will. For Reykjanesta. For the brothers we lost." },
	{ "speaker": "Balgruuf", "line": "Good lad. The path out of the brig leads right to the main hall. Go!" }
]

# Variable to hold the currently active dialogue
var current_dialogue_data: Array[Dictionary] = []

func _ready():
	# Default to initial dialogue
	set_dialogue_state(false) # Call function to set initial state
	if interaction_area:
		interaction_area.monitorable = true
	else: push_warning("Balgruuf has no InteractionArea node!")
	print("Balgruuf NPC '%s' Ready. Interactable Group Added." % name)


# Function called by jail.gd to set which dialogue to use
func set_dialogue_state(has_escaped: bool):
	if has_escaped:
		current_dialogue_data = post_escape_dialogue_data
		print("Balgruuf: Switched to POST-ESCAPE dialogue.")
	else:
		current_dialogue_data = initial_dialogue_data
		print("Balgruuf: Using INITIAL dialogue.")


func interact(player_node):
	print("Balgruuf: Player %s interacted with me!" % player_node.name)
	# Emit the currently active dialogue data
	if current_dialogue_data.is_empty():
		push_warning("Balgruuf: Current dialogue data is empty!")
		# Fallback?
		request_dialogue.emit([{"speaker": "Balgruuf", "line":"... Something's wrong."}])
		return
	request_dialogue.emit(current_dialogue_data)
