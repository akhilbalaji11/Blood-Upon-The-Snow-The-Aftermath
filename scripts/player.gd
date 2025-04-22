extends CharacterBody2D

# --- NEW SIGNAL ---
# Emitted when the player enters/exits range of an interactable target,
# or when dialogue starts/ends while in range.
signal can_interact_changed(can_interact: bool, target_name: String)

# --- Constants ---
const STOPPING_DISTANCE: float = 5.0 # Pixels within which the character begins stopping

# --- Export Variables ---
@export var move_speed: float = 250.0

# --- Nodes ---
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_detection_area: Area2D = $InteractionDetectionArea # Added


# --- State Machine ---
enum State { IDLE, START_RUN, RUNNING, STOP_RUN, DIALOGUE }
var current_state: State = State.IDLE

# --- Movement Variables ---
var target_position: Vector2 = Vector2.ZERO

# --- Interaction ---
var potential_interaction_target: Node = null # Node we can potentially interact with
var can_move: bool = true # Flag to disable movement during dialogue

# --- Interaction (kept from original) ---
var objIAmInteractingWith: Node2D # Review if this name/var is still needed

const OriginalCommanderScript = preload("res://scripts/commander.gd")


# --- Godot Lifecycle Functions ---
func _ready() -> void:
	if animated_sprite == null:
		push_error("ERROR: AnimatedSprite2D node not found or path is incorrect!")
		return
	if interaction_detection_area == null:
		push_error("ERROR: InteractionDetectionArea node not found or path is incorrect!")
		return

	target_position = global_position
	_change_state(State.IDLE)
	animated_sprite.animation_finished.connect(_on_animation_finished)

	# Connect signals for the interaction detection area
	interaction_detection_area.body_entered.connect(_on_interaction_body_or_area_entered) # Rename target function
	interaction_detection_area.body_exited.connect(_on_interaction_body_or_area_exited)   # Rename target function

	interaction_detection_area.area_entered.connect(_on_interaction_body_or_area_entered) # Connect area signal too
	interaction_detection_area.area_exited.connect(_on_interaction_body_or_area_exited)   # Connect area signal too
	if not InputMap.has_action("interact"):
		push_warning("Input action 'interact' not found! Please define it in Project Settings -> Input Map (e.g., assign key E).")

	# Connect other signal (kept from original)
	# GlobalScriptHelperManager.updateObjPlayerIsLookingAt.connect(jibajaba) # Review if still needed
	print("Player Ready. Initial State: IDLE")

func _input(event: InputEvent) -> void:
	# --- Movement Input ---
	# Allow click movement only if can_move is true AND state allows it
	if can_move and event.is_action_pressed("click"):
		if current_state == State.IDLE or current_state == State.RUNNING:
			target_position = get_global_mouse_position()
			if current_state == State.IDLE:
				_change_state(State.START_RUN)

	# --- Interaction Input ---
	if Input.is_action_just_pressed("interact"):
		if current_state == State.IDLE or current_state == State.RUNNING:
			if potential_interaction_target != null:
				if potential_interaction_target.has_method("interact"):
					print("Player: Interacting with %s" % potential_interaction_target.name)
					potential_interaction_target.call("interact", self)
					_change_state(State.DIALOGUE) # Entering dialogue state
				else:
					print("Player: %s has no 'interact' method." % potential_interaction_target.name)
			else:
				print("Player: Nothing nearby to interact with.")
		else:
			print("Player: Tried to interact while in state %s. Ignored." % State.keys()[current_state])


	# Original interaction input (review if still needed)
	# if Input.is_action_just_pressed("eToInteract"):
	#     print("I just interacted with this thing")

func _physics_process(delta: float) -> void:
	var was_running = (current_state == State.RUNNING) # Remember if we started this frame running

	# Only process movement if we are allowed to move
	if not can_move:
		if animated_sprite.animation != "idle":
			_play_animation("idle")
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# --- Movement State Logic (only runs if can_move is true) ---
	match current_state:
		State.IDLE:
			velocity = Vector2.ZERO
		State.START_RUN:
			velocity = Vector2.ZERO
			_update_sprite_flip(target_position - global_position)
		State.RUNNING:
			var direction = (target_position - global_position).normalized()
			var distance = global_position.distance_to(target_position)
			if distance < STOPPING_DISTANCE:
				_change_state(State.STOP_RUN)
				velocity = Vector2.ZERO
			else:
				velocity = direction * move_speed
				_update_sprite_flip(velocity)
				# Overshoot prevention
				if distance < velocity.length() * delta:
					velocity = direction * (distance / delta)
		State.STOP_RUN:
			velocity = Vector2.ZERO

	# --- Apply movement ---
	move_and_slide()

	# --- Check for collision *after* moving ---
	# If we were supposed to be running but a collision happened
	if was_running and get_slide_collision_count() > 0:
		# Check if we are still technically in the RUNNING state
		# (meaning the distance check didn't trigger STOP_RUN yet)
		if current_state == State.RUNNING:
			var collision = get_last_slide_collision()
			# Optional: Check if colliding specifically with the father if needed
			# if collision and collision.get_collider() == potential_interaction_target:
			print("Player: Collided with something while running, stopping.") # Corrected print
			# Force stop state due to collision
			_change_state(State.STOP_RUN)
			# Set target to current spot to prevent resuming run immediately
			target_position = global_position
			# Set velocity zero immediately too
			velocity = Vector2.ZERO


# --- State Machine & Animation Logic ---
func _change_state(new_state: State) -> void:
	if current_state == new_state: return

	# FIXED PRINT: Using %s and accessing keys() which returns an Array
	# Note: State.keys() gives an array of strings ["IDLE", "START_RUN", ...]
	# We need to use the enum value (which is an int) as the index
	print("Player State Change: %s -> %s" % [State.keys()[current_state], State.keys()[new_state]])
	#var old_state = current_state # Store old state if needed later (keep commented if unused)
	current_state = new_state

	# Handle entering/exiting states
	match current_state:
		State.IDLE:
			_play_animation("idle")
			can_move = true
		State.START_RUN:
			_play_animation("startrun")
			can_move = true
		State.RUNNING:
			_play_animation("run")
			can_move = true
		State.STOP_RUN:
			_play_animation("stoprun")
			can_move = true
		State.DIALOGUE:
			print("Attempting to force IDLE animation for DIALOGUE state...") # This one was okay
			_play_animation("idle")
			can_move = false
			velocity = Vector2.ZERO
			# FIXED PRINT: Using %s for multiple arguments, passed as an array
			print("In DIALOGUE state. can_move: %s, velocity: %s" % [can_move, velocity])

func _play_animation(anim_name: String) -> void:
	if animated_sprite and animated_sprite.sprite_frames.has_animation(anim_name):
		if animated_sprite.animation != anim_name or not animated_sprite.is_playing():
			animated_sprite.play(anim_name)
	elif animated_sprite:
		# FIXED PRINT: Using %s for string formatting
		print("Warning: Animation '%s' not found!" % anim_name)


func _on_animation_finished() -> void:
	var finished_anim = animated_sprite.animation
	if current_state != State.DIALOGUE:
		if finished_anim == "startrun" and current_state == State.START_RUN:
			if global_position.distance_to(target_position) < STOPPING_DISTANCE:
				_change_state(State.STOP_RUN)
			else:
				_change_state(State.RUNNING)
		elif finished_anim == "stoprun" and current_state == State.STOP_RUN:
			_change_state(State.IDLE)
			global_position = target_position
			velocity = Vector2.ZERO

func _on_interaction_body_or_area_entered(body_or_area: Node):
	var interactable_node: Node = null

	if body_or_area is Area2D:
		# --- CHANGE: Get PARENT first for Area2D ---
		interactable_node = body_or_area.get_parent()
		# --------------------------------------------
		# DEBUG print remains helpful
		print("Interaction Area: Area Entered - %s (Parent: %s)" % [body_or_area.name, interactable_node.name if interactable_node else "None"]) # Updated print label

	elif body_or_area is PhysicsBody2D:
		interactable_node = body_or_area
		print("Interaction Area: Body Entered - %s" % body_or_area.name) # DEBUG
	else:
		print("Interaction Area: Unknown node type entered - %s" % body_or_area.name) # DEBUG
		return

	if not interactable_node:
		print("Interaction Area: Could not determine interactable node from %s" % body_or_area.name) # DEBUG
		return

		# --- Now use interactable_node for checks ---
	if interactable_node.is_in_group("interactable"):
		print("Interaction Area: Node '%s' IS in 'interactable' group." % interactable_node.name) # DEBUG
		if interactable_node.has_method("interact"):
			print("Interaction Area: Node '%s' HAS 'interact' method." % interactable_node.name) # DEBUG
			print("Player: Entered range of interactable %s" % interactable_node.name)
			potential_interaction_target = interactable_node
			if current_state != State.DIALOGUE:
				print("Player: Emitting can_interact_changed(true, %s)" % interactable_node.name) # DEBUG
				can_interact_changed.emit(true, interactable_node.name)
		else:
			print("Interaction Area: Node '%s' DOES NOT have 'interact' method." % interactable_node.name) # DEBUG
	else:
		print("Interaction Area: Node '%s' is NOT in 'interactable' group." % interactable_node.name) # DEBUG


# MODIFIED function - PRIORITIZE PARENT for Areas
func _on_interaction_body_or_area_exited(body_or_area: Node):
	var interactable_node: Node = null
	if body_or_area is Area2D:
		# --- CHANGE: Get PARENT first for Area2D ---
		interactable_node = body_or_area.get_parent()
		# --------------------------------------------
	elif body_or_area is PhysicsBody2D:
		interactable_node = body_or_area
	else: return

	if not interactable_node: return

	if interactable_node == potential_interaction_target:
		print("Player: Exited range of interactable %s" % interactable_node.name)
		potential_interaction_target = null
		print("Player: Emitting can_interact_changed(false, '')") # DEBUG
		can_interact_changed.emit(false, "")

# --- Helper Functions ---
# Inside player.gd -> _update_sprite_flip
func _update_sprite_flip(direction_vector: Vector2) -> void:
	if direction_vector.x != 0:
		var should_flip = direction_vector.x < 0 # Flip if moving left
		# --- DEBUG ---
		print("Flip Check: DirX=%.2f, ShouldFlip=%s, CurrentFlip=%s" % [direction_vector.x, should_flip, animated_sprite.flip_h])
		# -----------
		if animated_sprite.flip_h != should_flip:
			print(" ==> Flipping sprite! New flip_h = %s" % should_flip) # DEBUG
			animated_sprite.flip_h = should_flip

# --- Signal Handler (kept from original) ---
func jibajaba(nodeName, secondVar) -> void: # Review if this signal is still needed
	# FIXED PRINT: Using %s for multiple arguments, passed as an array
	print("Signal 'updateObjPlayerIsLookingAt' received from: %s with data: %s" % [nodeName, secondVar])
	pass

# --- Public function to be called when dialogue ends ---
# Inside player.gd

func end_dialogue():
	if current_state == State.DIALOGUE:
		print("Player: Dialogue ended. Resuming control.")
		var interaction_target = potential_interaction_target
		_change_state(State.IDLE) # Change state *before* triggering actions

		if is_instance_valid(interaction_target):
			# --- Check specific NPC types ---
			# --- CHANGE: Check using the preloaded script resource ---
			if interaction_target.get_script() == OriginalCommanderScript:
				print("Player: Interaction target is the Original Commander.") # Debug
			# -----------------------------------------------------------
				if interaction_target.has_method("trigger_post_dialogue_action"):
					interaction_target.call("trigger_post_dialogue_action")

			# VVVV --- ADD CHECK FOR BETRAYAL COMMANDER --- VVVV
			elif interaction_target is BetrayalCommander: # Check using class_name
				if interaction_target.has_method("trigger_post_dialogue_action"):
					print("Player: Telling BetrayalCommander to trigger post-dialogue action.")
					interaction_target.call("trigger_post_dialogue_action")
				else:
					print("Player: BetrayalCommander object lacks 'trigger_post_dialogue_action' method!")
			# ^^^^ --- ADD CHECK FOR BETRAYAL COMMANDER --- ^^^^

			# Optional: Add checks for Father, Balgruuf if they need post-dialogue actions
			# elif interaction_target is Balgruuf: ...

		elif not is_instance_valid(interaction_target):
			print("Player: Interaction target became invalid after ending dialogue.")
