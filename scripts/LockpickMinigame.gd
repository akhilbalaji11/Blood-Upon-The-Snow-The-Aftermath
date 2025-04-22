extends Control

signal all_levels_completed

# --- Nodes ---
@onready var lock_cylinder: TextureRect = $LockCylinder
@onready var moving_lock: TextureRect = $MovingLock
@onready var lockpick: TextureRect = $Lockpick
@onready var pick_break_timer: Timer = $PickBreakTimer
@onready var jiggle_sound: AudioStreamPlayer = $JiggleSound
@onready var break_sound: AudioStreamPlayer = $BreakSound
@onready var success_sound: AudioStreamPlayer = $SuccessSound
@onready var sweet_spot_sound: AudioStreamPlayer = $SweetSpotSound
@onready var level_indicator_label: Label = $LevelIndicatorLabel # <<< ADDED Level Label Reference

# --- Export Variables (CHANGED TO STRINGS) ---
@export var next_scene_path_string: String = "res://scenes/jail.tscn" # Scene path to go to after beating level 5
@export var exit_scene_path_string: String = "res://scenes/jail.tscn" # Scene path to go to if player cancels (e.g., Esc)

# --- Lock Properties ---
var sweet_spot_angle_deg: float = 0.0
var sweet_spot_width_deg: float = 20.0
const MAX_CYLINDER_ROTATION_DEG: float = 90.0

# --- Pick State ---
var current_pick_angle_deg: float = 0.0
const MAX_PICK_ANGLE_DEG: float = 55.0
var is_rotating_cylinder: bool = false
var current_cylinder_rotation_deg: float = 0.0
var was_in_sweet_spot: bool = false
var level_just_succeeded: bool = false

# --- Gameplay Tuning ---
@export var mouse_sensitivity: float = 0.5
@export var pick_jiggle_intensity: float = 3
var pick_break_resistance_time: float = 0.25

# --- Level Management ---
var current_level_index: int = 0
const TOTAL_LEVELS: int = 5
const DIFFICULTY_SETTINGS: Array[Dictionary] = [
	{"width": 35.0, "resistance": 0.40}, # Level 0 (Novice)
	{"width": 25.0, "resistance": 0.30}, # Level 1 (Apprentice)
	{"width": 15.0, "resistance": 0.25}, # Level 2 (Adept)
	{"width": 8.0, "resistance": 0.20}, # Level 3 (Expert)
	{"width": 4.0, "resistance": 0.15}  # Level 4 (Master)
]

#-----------------------------------------------------------------------------
# Initialization and Level Start
#-----------------------------------------------------------------------------

func _ready():
	pick_break_timer.timeout.connect(_on_pick_break_timer_timeout)
	_start_level(current_level_index)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	set_process_input(true)
	set_process(true)
	if level_indicator_label: # Ensure label exists before using
		level_indicator_label.visible = true


func _start_level(level_index: int):
	print("Starting Lockpicking Level: %d" % (level_index + 1))
	level_index = clamp(level_index, 0, DIFFICULTY_SETTINGS.size() - 1)
	current_level_index = level_index
	level_just_succeeded = false

	# --- Update Level Indicator Label ---
	if level_indicator_label:
		level_indicator_label.text = "Level %d / %d\nUse mouse to move lockpick\nListen for the sweet spot\nHold Space to pry lock cylinder\nBreaking a lockpick resets you to Level 1
" % [current_level_index + 1, TOTAL_LEVELS]
	# ------------------------------------

	# Set difficulty
	sweet_spot_width_deg = DIFFICULTY_SETTINGS[current_level_index]["width"]
	pick_break_resistance_time = DIFFICULTY_SETTINGS[current_level_index]["resistance"]
	pick_break_timer.wait_time = pick_break_resistance_time

	# Generate random sweet spot
	var padding = sweet_spot_width_deg / 2.0 + 5.0
	sweet_spot_angle_deg = randf_range(-MAX_PICK_ANGLE_DEG + padding, MAX_PICK_ANGLE_DEG - padding)
	print("Level %d - Sweet Spot Angle: %.2f (Width: %.2f)" % [current_level_index + 1, sweet_spot_angle_deg, sweet_spot_width_deg])

	# Reset state variables
	current_pick_angle_deg = 0.0
	current_cylinder_rotation_deg = 0.0
	is_rotating_cylinder = false
	was_in_sweet_spot = false
	lockpick.rotation_degrees = current_pick_angle_deg
	lock_cylinder.rotation_degrees = current_cylinder_rotation_deg
	moving_lock.rotation_degrees = current_cylinder_rotation_deg
	pick_break_timer.stop()
	_stop_all_sounds()


func _stop_all_sounds():
	if jiggle_sound and jiggle_sound.playing: jiggle_sound.stop()
	if success_sound and success_sound.playing: success_sound.stop()
	if sweet_spot_sound and sweet_spot_sound.playing: sweet_spot_sound.stop()


func _go_to_scene(scene_path_string: String): # Accepts a string path now
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if level_indicator_label: level_indicator_label.visible = false

	# --- ADD DEBUG PRINTS ---
	print("--- Entering _go_to_scene ---")
	print("Argument scene_path_string: %s" % scene_path_string)
	# --------------------------

	if not scene_path_string.is_empty():
		# --- Load the scene using the path ---
		var loaded_scene = load(scene_path_string)
		# -------------------------------------
		if loaded_scene: # Check if loading succeeded
			var err = get_tree().change_scene_to_packed(loaded_scene)
			if err != OK:
				print("Error changing scene using path '%s': %s" % [scene_path_string, err])
		else:
			print("Error: Failed to load scene from path: %s" % scene_path_string)
	else:
		print("Error: Target scene path string was empty!")

	print("--- Exiting _go_to_scene ---")


#-----------------------------------------------------------------------------
# Input Handling
#-----------------------------------------------------------------------------

func _input(event: InputEvent):
	# --- Mouse Motion for Lockpick Angle ---
	if event is InputEventMouseMotion and not is_rotating_cylinder:
		var angle_change = -event.relative.x * mouse_sensitivity
		current_pick_angle_deg += angle_change
		current_pick_angle_deg = clamp(current_pick_angle_deg, -MAX_PICK_ANGLE_DEG, MAX_PICK_ANGLE_DEG)
		lockpick.rotation_degrees = current_pick_angle_deg # Set rotation based *only* on aiming here

		# Check for sweet spot sound trigger *during aiming*
		var angle_diff = abs(current_pick_angle_deg - sweet_spot_angle_deg)
		var is_currently_in_sweet_spot = angle_diff <= sweet_spot_width_deg / 2.0
		if is_currently_in_sweet_spot and not was_in_sweet_spot:
			if sweet_spot_sound: sweet_spot_sound.play()
		was_in_sweet_spot = is_currently_in_sweet_spot # Update state for next frame

	# --- Start/Stop Cylinder Rotation ---
	if event.is_action_pressed("ui_accept"):
		is_rotating_cylinder = true
		if sweet_spot_sound and sweet_spot_sound.playing: sweet_spot_sound.stop()

	if event.is_action_released("ui_accept"):
		is_rotating_cylinder = false
		pick_break_timer.stop()
		if jiggle_sound and jiggle_sound.playing: jiggle_sound.stop()
		if success_sound and success_sound.playing: success_sound.stop()

	# --- Exit Minigame (Escape key) ---
	if event.is_action_pressed("ui_cancel"):
		print("Exiting lockpicking minigame sequence.")
		_stop_all_sounds()
		_go_to_scene(exit_scene_path_string)

#-----------------------------------------------------------------------------
# Process Loop (Handles Rotation, Jiggle, Breaking)
#-----------------------------------------------------------------------------

func _process(delta):
	if not is_rotating_cylinder:
		# Slowly return cylinder to start if not holding
		current_cylinder_rotation_deg = lerp(current_cylinder_rotation_deg, 0.0, delta * 5.0)
		lock_cylinder.rotation_degrees = current_cylinder_rotation_deg
		moving_lock.rotation_degrees = current_cylinder_rotation_deg
		lockpick.rotation_degrees = current_pick_angle_deg # Update lockpick to only aiming angle

		# Ensure aiming sounds reflect current state if mouse isn't moving / rotation stopped
		var angle_diff = abs(current_pick_angle_deg - sweet_spot_angle_deg)
		var is_currently_in_sweet_spot = angle_diff <= sweet_spot_width_deg / 2.0
		if not is_currently_in_sweet_spot and was_in_sweet_spot: # Stop if moved out
			if sweet_spot_sound and sweet_spot_sound.playing: sweet_spot_sound.stop()
		was_in_sweet_spot = is_currently_in_sweet_spot

		if jiggle_sound and jiggle_sound.playing: jiggle_sound.stop()
		return

	# --- Player is holding the button ---
	var angle_difference = abs(current_pick_angle_deg - sweet_spot_angle_deg)
	var is_in_sweet_spot = angle_difference <= sweet_spot_width_deg / 2.0

	if is_in_sweet_spot:
		# --- SUCCESS PATH ---
		pick_break_timer.stop()
		if jiggle_sound and jiggle_sound.playing: jiggle_sound.stop()
		if sweet_spot_sound and sweet_spot_sound.playing: sweet_spot_sound.stop()

		# Rotate cylinder AND moving lock
		current_cylinder_rotation_deg = lerp(current_cylinder_rotation_deg, MAX_CYLINDER_ROTATION_DEG, delta * 4.0)
		lock_cylinder.rotation_degrees = current_cylinder_rotation_deg
		moving_lock.rotation_degrees = current_cylinder_rotation_deg

		# --- Rotate Lockpick WITH Cylinder ---
		lockpick.rotation_degrees = current_pick_angle_deg + current_cylinder_rotation_deg
		# -----------------------------------

		# Play Success Sound *while* turning
		if not level_just_succeeded and success_sound and not success_sound.playing:
			success_sound.play()

		# Check for win condition
		if is_equal_approx(current_cylinder_rotation_deg, MAX_CYLINDER_ROTATION_DEG):
			if not level_just_succeeded:
				_level_succeeded()

	else:
		# --- RESISTANCE / FAIL PATH ---
		# Stop cylinder/moving lock rotation
		current_cylinder_rotation_deg = lerp(current_cylinder_rotation_deg, 0.0, delta * 1.0)
		lock_cylinder.rotation_degrees = current_cylinder_rotation_deg
		moving_lock.rotation_degrees = current_cylinder_rotation_deg

		# Jiggle the pick visually (relative to aiming angle, NOT cylinder)
		var jiggle_offset = randf_range(-pick_jiggle_intensity, pick_jiggle_intensity) * (angle_difference / MAX_PICK_ANGLE_DEG)
		lockpick.rotation_degrees = current_pick_angle_deg + jiggle_offset
		# ----------------------------

		# Play jiggle sound
		if jiggle_sound and not jiggle_sound.playing: jiggle_sound.play()
		# Stop other sounds
		if success_sound and success_sound.playing: success_sound.stop()
		if sweet_spot_sound and sweet_spot_sound.playing: sweet_spot_sound.stop()

		if pick_break_timer.is_stopped():
			pick_break_timer.start()

#-----------------------------------------------------------------------------
# Event Handlers (Timer, Success)
#-----------------------------------------------------------------------------

# Inside LockpickMinigame.gd

func _on_pick_break_timer_timeout():
	# Only break if still holding and outside sweet spot
	if is_rotating_cylinder:
		var angle_difference = abs(current_pick_angle_deg - sweet_spot_angle_deg)
		if angle_difference > sweet_spot_width_deg / 2.0:
			# Determine which level it broke on *before* resetting the index
			var level_it_broke_on = current_level_index + 1
			print("Lockpick broke on Level %d! Resetting to Level 1." % level_it_broke_on) # Updated print

			# --- Play break sound FIRST ---
			if break_sound:
				break_sound.play()
			# -----------------------------

			# --- Stop OTHER sounds AFTER ---
			if jiggle_sound and jiggle_sound.playing: jiggle_sound.stop()
			if success_sound and success_sound.playing: success_sound.stop()
			if sweet_spot_sound and sweet_spot_sound.playing: sweet_spot_sound.stop()
			# -----------------------------

			# --- CHANGE THIS LINE ---
			# Restart from level index 0 (Level 1)
			_start_level(0) # <<< Changed argument from current_level_index to 0
			# ------------------------

			# Optional: Add logic here to consume a lockpick if tracking inventory


func _level_succeeded():
	# ... (print messages, set flags, stop sounds) ...
	print("Level %d Picked!" % (current_level_index + 1))
	level_just_succeeded = true
	is_rotating_cylinder = false
	_stop_all_sounds()
	if success_sound and success_sound.playing: success_sound.stop()

	current_level_index += 1

	if current_level_index < TOTAL_LEVELS:
		_start_level(current_level_index)
	else:
		print("All lockpicking levels completed!")
		Global.jail_lock_picked = true
		emit_signal("all_levels_completed")
		# --- Pass the STRING path ---
		_go_to_scene(next_scene_path_string)
		# ----------------------------
