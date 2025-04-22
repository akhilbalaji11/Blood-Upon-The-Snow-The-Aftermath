# jail.gd
extends Node2D

# --- References ---
@onready var player: CharacterBody2D = $Player
@onready var balgruuf: CharacterBody2D = $Balgruuf # Ensure this is the correct node type
@onready var dialogue_ui: Control = $DialogueUI
@onready var jail_door_interactable: Node2D = $JailDoorInteractable # Reference to the first door node
@onready var exit_door_interactable: Node2D = $ExitDoorInteractable # Reference to the NEW exit door node

# Optional: Reference the visual sprite of the jail door if it's separate
@onready var jail_door_sprite: Sprite2D = $JailDoorInteractable/JailDoorSprite # ADJUST PATH/NAME
@onready var jail_door_collider: StaticBody2D = $JailDoorInteractable.get_node_or_null("JailDoorCollider") # Adjust path if needed


func _ready():
	# --- Error Checking ---
	if not is_instance_valid(player): push_error("Jail Error: Player node not found!"); return
	if not is_instance_valid(balgruuf): push_error("Jail Error: Balgruuf node not found!"); return
	if not is_instance_valid(dialogue_ui): push_error("Jail Error: DialogueUI node not found!"); return
	if not is_instance_valid(jail_door_interactable): push_error("Jail Error: JailDoorInteractable node not found!"); return
	if not is_instance_valid(exit_door_interactable): push_error("Jail Error: ExitDoorInteractable node not found!"); return
	if not is_instance_valid(jail_door_collider):  push_error("Jail Error: JailDoorCollider node not found!"); return # Check collider exists 

	if not is_instance_valid(jail_door_sprite): push_warning("Jail Warning: jail_door_sprite node not found (optional)!"); # Warning if not found

	print("Jail: Checking lock state...")

	# --- Check Global Flag and Set Scene State ---
	if Global.jail_lock_picked:
		print("Jail: Lock is picked. Setting post-escape state.")
		# Hide the original jail door sprite
		if is_instance_valid(jail_door_sprite):
			jail_door_sprite.hide()
		# Make the original jail door NO LONGER interactable
		if jail_door_interactable.is_in_group("interactable"):
			jail_door_interactable.remove_from_group("interactable")
		# Disable its interaction area just in case
		var jail_area = jail_door_interactable.get_node_or_null("InteractionArea")
		if jail_area: jail_area.monitoring = false; jail_area.monitorable = false
		 # --- Disable Physical Collision for Jail Door ---
		var collision_shape = jail_door_collider.get_node_or_null("CollisionShape2D")
		if is_instance_valid(collision_shape):
			collision_shape.disabled = true # true = collision DISABLED
			print("Jail: Disabled jail door physical collider.")
		else:
			push_warning("Jail Warning: CollisionShape2D not found under JailDoorCollider!")
		# Tell Balgruuf to use post-escape dialogue
		if balgruuf.has_method("set_dialogue_state"):
			balgruuf.set_dialogue_state(true)
		else: push_error("Jail Error: Balgruuf missing set_dialogue_state method!")

		# Make the NEW exit door interactable
		if not exit_door_interactable.is_in_group("interactable"):
			exit_door_interactable.add_to_group("interactable")
		var exit_area = exit_door_interactable.get_node_or_null("InteractionArea")
		if exit_area: exit_area.monitorable = true # Ensure player can detect it

		# --- Reset the global flag after applying the state ---
		# So if the player leaves and comes back (e.g., via menu), it doesn't incorrectly re-apply
		# Or handle this based on your save/load system if applicable
		# Global.jail_lock_picked = false # Consider the implications

	else:
		print("Jail: Lock is NOT picked. Setting initial state.")
		# Ensure original jail door is visible and interactable
		if is_instance_valid(jail_door_sprite):
			jail_door_sprite.show()
		if not jail_door_interactable.is_in_group("interactable"):
			jail_door_interactable.add_to_group("interactable")
		var jail_area = jail_door_interactable.get_node_or_null("InteractionArea")
		if jail_area: jail_area.monitorable = true
		
		# --- Enable Physical Collision for Jail Door ---
		var collision_shape = jail_door_collider.get_node_or_null("CollisionShape2D")
		if is_instance_valid(collision_shape):
			collision_shape.disabled = false # false = collision ENABLED
			print("Jail: Enabled jail door physical collider.")
		else:
			push_warning("Jail Warning: CollisionShape2D not found under JailDoorCollider!")
		# Tell Balgruuf to use initial dialogue
		if balgruuf.has_method("set_dialogue_state"):
			balgruuf.set_dialogue_state(false)
		else: push_error("Jail Error: Balgruuf missing set_dialogue_state method!")

		# Ensure NEW exit door is NOT interactable
		if exit_door_interactable.is_in_group("interactable"):
			exit_door_interactable.remove_from_group("interactable")
		var exit_area = exit_door_interactable.get_node_or_null("InteractionArea")
		if exit_area: exit_area.monitorable = false # Player shouldn't detect it yet

	# --- Connect Signals (Do this AFTER setting initial state) ---
	connect_signals()

	print("Jail Ready. Scene state configured.")


func connect_signals():
	# Connect Balgruuf Dialogue Signal
	if balgruuf.has_signal("request_dialogue"):
		if not balgruuf.request_dialogue.is_connected(dialogue_ui.start_dialogue): # Prevent duplicate connections
			var err = balgruuf.request_dialogue.connect(dialogue_ui.start_dialogue)
			if err == OK: print("Jail: Connected Balgruuf.request_dialogue -> DialogueUI.start_dialogue")
			else: push_error("Jail Error: FAILED to connect Balgruuf.request_dialogue! Error: %s" % err)
	else: push_error("Jail Error: Balgruuf node does not have 'request_dialogue' signal!")

	# Connect Dialogue UI Finish Signal
	if dialogue_ui.has_signal("dialogue_finished"):
		if not dialogue_ui.dialogue_finished.is_connected(player.end_dialogue):
			var err = dialogue_ui.dialogue_finished.connect(player.end_dialogue)
			if err == OK: print("Jail: Connected DialogueUI.dialogue_finished -> Player.end_dialogue")
			else: push_error("Jail Error: FAILED to connect DialogueUI.dialogue_finished! Error: %s" % err)
	else: push_error("Jail Error: DialogueUI node does not have 'dialogue_finished' signal!")

	# Connect Player Interaction Prompt Signal
	if player.has_signal("can_interact_changed"):
		if not player.can_interact_changed.is_connected(dialogue_ui._on_player_can_interact_changed):
			var err = player.can_interact_changed.connect(dialogue_ui._on_player_can_interact_changed)
			if err == OK: print("Jail: Connected Player.can_interact_changed -> DialogueUI._on_player_can_interact_changed")
			else: push_error("Jail Error: FAILED to connect Player.can_interact_changed! Error: %s" % err)
	else: push_error("Jail Error: Player node does not have 'can_interact_changed' signal!")
