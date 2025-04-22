extends Control

signal dialogue_finished
signal line_will_display(line_index: int, speaker: String) # <<< NEW SIGNAL

# --- Nodes ---
@onready var dialogue_box: NinePatchRect = %DialogueBox # Or NinePatchRect
@onready var dialogue_label: Label = %DialogueLabel
@onready var portrait_rect: TextureRect = %PortraitRect # Added PortraitRect
@onready var typewriter_timer: Timer = $TypewriterTimer # Added Timer
@onready var interaction_prompt_label: Label = %InteractionPromptLabel # Added prompt label
@onready var success_sound: AudioStreamPlayer = $SuccessSound
@onready var sweet_spot_sound: AudioStreamPlayer = $SweetSpotSound # Added previously
# etc.

# --- Exported Variables ---
# Assign these textures in the Godot Editor for the DialogueUI instance in world.tscn
@export var player_portrait: Texture2D
@export var father_portrait: Texture2D
@export var commander_portrait: Texture2D # <<< ADD THIS VARIABLE
@export var balgruuf_portrait: Texture2D # <<< ADD THIS


# You might want a dictionary if you have many speakers:
#@export var speaker_portraits: Dictionary = {"Player": null, "Father": null}

@export var character_interval: float = 0.04 # Time between letters (adjust for speed)

# --- Dialogue Data & State ---
var dialogue_queue: Array[Dictionary] = [] # Holds the incoming dialogue data
var current_line_data: Dictionary = {} # Holds speaker & line currently processing
var full_line_text: String = ""        # The complete text for the current line
var displayed_text_index: int = 0      # How many characters are currently shown
var is_typing: bool = false            # Is the typewriter effect active?
var current_line_index: int = -1 # <<< Ensure this is declared here


func _ready():
	dialogue_box.visible = false
	portrait_rect.visible = false
	interaction_prompt_label.visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	typewriter_timer.wait_time = character_interval
	typewriter_timer.timeout.connect(_on_typewriter_timer_timeout)

	if not InputMap.has_action("ui_accept"):
		push_warning("Input action 'ui_accept' not found! Dialogue advancement might not work.")
	print("DialogueUI Ready.")


func _unhandled_input(event: InputEvent):
	if not dialogue_box.visible: return
	if Input.is_action_just_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		if is_typing:
			# Skip Typewriter
			typewriter_timer.stop()
			dialogue_label.text = full_line_text
			displayed_text_index = full_line_text.length()
			is_typing = false
			# Ensure sounds stop if skipping
			if success_sound and success_sound.playing: success_sound.stop()
			if sweet_spot_sound and sweet_spot_sound.playing: sweet_spot_sound.stop()
		else:
			_advance_dialogue()


func start_dialogue(data: Array[Dictionary]):
	if data.is_empty():
		print("DialogueUI: Tried to start dialogue with empty data.")
		return

	print("DialogueUI: Starting dialogue.")
	hide_interaction_prompt()
	dialogue_queue = data.duplicate()
	current_line_index = -1 # Reset index BEFORE first advance
	dialogue_box.visible = true
	_advance_dialogue() # Display the first line


func _advance_dialogue():
	if is_typing:
		print("DialogueUI: Tried to advance while typing.")
		return

	if not dialogue_queue.is_empty():
		# --- Increment index FIRST ---
		current_line_index += 1
		# -----------------------------

		current_line_data = dialogue_queue.pop_front()
		full_line_text = current_line_data.get("line", "")
		var speaker = current_line_data.get("speaker", "")

		print("DialogueUI: Advancing. Line Index: %d, Speaker: '%s', Line: '%s'" % [current_line_index, speaker, full_line_text])

		# --- Emit signal AFTER index update, BEFORE UI update ---
		emit_signal("line_will_display", current_line_index, speaker)
		# ------------------------------------------------------

		# Update Portrait
		match speaker:
			"Player":
				if player_portrait: portrait_rect.texture = player_portrait; portrait_rect.visible = true
				else: print("Warning: Player portrait texture not assigned!"); portrait_rect.visible = false
			"Father":
				if father_portrait: portrait_rect.texture = father_portrait; portrait_rect.visible = true
				else: print("Warning: Father portrait texture not assigned!"); portrait_rect.visible = false
			"Commander":
				if commander_portrait: portrait_rect.texture = commander_portrait; portrait_rect.visible = true
				else: print("Warning: Commander portrait texture not assigned!"); portrait_rect.visible = false
			"Balgruuf":
				if balgruuf_portrait: portrait_rect.texture = balgruuf_portrait; portrait_rect.visible = true
				else: print("Warning: Balgruuf portrait texture not assigned!"); portrait_rect.visible = false
			_:
				print("Warning: Unknown speaker '%s' or speaker not defined." % speaker)
				portrait_rect.visible = false

		# Start Typewriter
		dialogue_label.text = ""
		displayed_text_index = 0
		is_typing = true
		typewriter_timer.start()

	else:
		# No more lines
		_end_dialogue()


func _on_typewriter_timer_timeout():
	if displayed_text_index < full_line_text.length():
		dialogue_label.text += full_line_text[displayed_text_index]
		displayed_text_index += 1
		if displayed_text_index < full_line_text.length():
			typewriter_timer.start()
		else:
			is_typing = false
			print("DialogueUI: Finished typing line.")
	else:
		is_typing = false
		print("DialogueUI: Timer timed out but text index was already at end.")


func _end_dialogue():
	print("DialogueUI: Ending dialogue.")
	dialogue_box.visible = false
	portrait_rect.visible = false
	dialogue_queue.clear()
	current_line_data.clear()
	full_line_text = ""
	displayed_text_index = 0
	is_typing = false
	current_line_index = -1 # Reset index when dialogue truly ends
	if typewriter_timer.time_left > 0: typewriter_timer.stop()
	if success_sound and success_sound.playing: success_sound.stop() # Ensure sounds stopped
	if sweet_spot_sound and sweet_spot_sound.playing: sweet_spot_sound.stop()
	dialogue_finished.emit()

# --- Prompt Functions (show/hide/handler) remain the same ---
func show_interaction_prompt():
	interaction_prompt_label.visible = true
func hide_interaction_prompt():
	interaction_prompt_label.visible = false
func _on_player_can_interact_changed(can_interact: bool, target_name: String):
	# --- ADDED check: Don't show prompt if dialogue is already visible ---
	if can_interact and not dialogue_box.visible:
	# -------------------------------------------------------------------
		show_interaction_prompt()
	else:
		hide_interaction_prompt()
