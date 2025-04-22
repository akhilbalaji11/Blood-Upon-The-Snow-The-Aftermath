# BetrayalCommander.gd
class_name BetrayalCommander # Use class_name for easier type checking
extends CharacterBody2D # Or StaticBody2D if he doesn't move

signal request_dialogue(dialogue_data)
signal start_duel # Signal to trigger the duel scene transition

# --- Nodes ---
@onready var interaction_area: Area2D = $InteractionArea
# Get reference to the sprite to flip its direction
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D # ADJUST NAME if using AnimatedSprite2D or different name

# --- Dialogue Content ---
@export var betrayal_dialogue_data: Array[Dictionary] = [
	# Commander muttering to himself (Player overhears)
	{ "speaker": "Commander", "line": "(Muttering)...That old fool Jarl... always underestimating me. This alliance with the Husavik curs... messy, but necessary.)" },
	{ "speaker": "Commander", "line": "(Muttering)... Once Thorgestr is dealt with... Reykjanesta will finally have a leader worthy of its strength... Me.)" },
	# Player Confrontation
	{ "speaker": "Player", "line": "Commander Bjorn! What is the meaning of this treason?!" },
	{ "speaker": "Commander", "line": "Thorgestr! You... you weren't meant to hear that. Seems Balgruuf's escape complicated things." },
	{ "speaker": "Commander", "line": "No matter. Your father's weakness held this clan back for too long! I did what was needed!" },
	{ "speaker": "Player", "line": "You betrayed us all! For power? You spit on the graves of the men who died following YOU!" },
	{ "speaker": "Commander", "line": "Silence, boy! You understand nothing of true leadership! Prepare to join your weakling father!" },
	{ "speaker": "Player", "line": "I'll send you to Helheim myself! FOR REYKJANESTA!" } # Final line before duel
]

# --- State ---
#var has_turned_to_player: bool = false

func _ready():
	if interaction_area: interaction_area.monitorable = true
	else: push_warning("BetrayalCommander has no InteractionArea node!")

	# Set initial facing direction (away from player)
	if sprite:
		sprite.flip_h = true # Start facing left (assuming default sprite faces right)
	else: push_warning("BetrayalCommander sprite node not found!")

	if not is_in_group("interactable"): add_to_group("interactable")
	print("BetrayalCommander NPC '%s' Ready." % name)


func interact(player_node: Node2D):
	print("BetrayalCommander: Player %s interacted!" % player_node.name)

	# --- REMOVED Turning logic from here ---

	# Emit dialogue signal
	if betrayal_dialogue_data.is_empty():
		push_warning("BetrayalCommander: Dialogue data is empty!")
		return
	request_dialogue.emit(betrayal_dialogue_data)


# --- NEW FUNCTION to handle turning ---
func turn_to_face_target(target_node: Node2D):
	if not is_instance_valid(target_node) or not sprite:
		return # Cannot turn if target or sprite is invalid

	print("BetrayalCommander: Turning to face target %s." % target_node.name)
	var direction_to_target = (target_node.global_position - global_position).normalized()
	# Assuming sprite faces right by default:
	# If target is to the left (dir.x < 0), flip_h should be true.
	# If target is to the right (dir.x > 0), flip_h should be false.
	var should_flip = direction_to_target.x < 0
	if sprite.flip_h != should_flip:
		sprite.flip_h = should_flip
# ---------------------------------------


func trigger_post_dialogue_action():
	print("BetrayalCommander: Dialogue finished. Signaling duel start.")
	start_duel.emit()


# --- NEW SIGNAL HANDLER (Connected in betrayal.gd) ---
func _on_dialogue_line_will_display(line_index: int, speaker: String):
	# Turn when the player's first line (index 2) is about to be shown
	if line_index == 2:
		# Need a reference to the player to turn towards
		var player = get_tree().get_first_node_in_group("player") # Assumes player is in group "player"
		if player:
			turn_to_face_target(player)
		else:
			print("BetrayalCommander Warning: Could not find player node to turn towards!")
# ------------------------------------------------------
