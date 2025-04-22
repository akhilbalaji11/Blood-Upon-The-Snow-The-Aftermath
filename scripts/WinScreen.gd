extends Node2D

# --- Nodes ---
@onready var win_text_label: Label = $CanvasLayer/WinTextLabel
@onready var typewriter_timer: Timer = $TypewriterTimer
@onready var continue_button: Button = $ContinueButton # Optional

# --- Export Variables ---
# Assign the Main Menu or Credits scene path in the Inspector for WinScreen.tscn
@export var final_destination_scene_path: String = ""
@export var character_interval: float = 0.05 # Adjust typing speed

# --- Text Content (Paste your final paragraph here) ---
@export var paragraph_text: String = "And so, the Saga of Thorgestr reached its zenith! By his hand, the last embers of the treacherous Husavik clan were extinguished, their raiding flame quenched forever in the cold fjords. The venomous betrayal of Commander Bjorn, a serpent coiled in their midst, was silenced by Thorgestr's righteous fury. Yet, it was not only the fury of his axe arm that proved his worth. Through trials demanding sharp eyes, quick wits, and nimble fingers, he showed resourcefulness worthy of legend. Before the assembled warriors of Reykjanesta, his father, the Jarl, watched with swelling pride. For Thorgestr had not merely survived; he had prevailed through strength and cunning. Thus, he was anointed Jarl, shield of his people, his name now etched into the annals of the North!"


# --- State Variables ---
var full_text: String = ""
var displayed_index: int = 0
var is_typing: bool = false

#-----------------------------------------------------------------------------
# Initialization
#-----------------------------------------------------------------------------

func _ready():
	# Ensure button is hidden initially if it exists
	if continue_button:
		continue_button.visible = false
		# Connect button press signal if it exists
		if not continue_button.pressed.is_connected(_on_continue_button_pressed):
			continue_button.pressed.connect(_on_continue_button_pressed)

	# Connect timer signal
	if typewriter_timer:
		if not typewriter_timer.timeout.is_connected(_on_typewriter_timer_timeout):
			typewriter_timer.timeout.connect(_on_typewriter_timer_timeout)
		typewriter_timer.wait_time = character_interval
	else:
		push_error("WinScreen Error: TypewriterTimer node not found!")
		return # Cannot proceed without timer

	# Start the typewriter effect
	start_typewriter()
	set_process_input(true) # Enable input for skipping

#-----------------------------------------------------------------------------
# Typewriter Logic
#-----------------------------------------------------------------------------

func start_typewriter():
	if not is_instance_valid(win_text_label):
		push_error("WinScreen Error: WinTextLabel node not found!")
		return

	full_text = paragraph_text
	displayed_index = 0
	is_typing = false # Will be set true when timer starts
	win_text_label.text = "" # Clear previous text

	if not full_text.is_empty():
		is_typing = true
		typewriter_timer.start() # Start the timer for the first character
	else:
		print("WinScreen Warning: Paragraph text is empty.")
		_show_continue_button() # Show button even if no text


func _on_typewriter_timer_timeout():
	if displayed_index < full_text.length():
		win_text_label.text += full_text[displayed_index]
		displayed_index += 1
		if displayed_index < full_text.length():
			typewriter_timer.start() # Restart timer for next char
		else:
			# Finished typing
			is_typing = false
			print("WinScreen: Finished typing.")
			_show_continue_button()
	else:
		# Should ideally not happen if logic is correct
		is_typing = false
		print("WinScreen: Timer timeout but index was at end.")
		_show_continue_button()


func _show_continue_button():
	if continue_button:
		continue_button.visible = true


#-----------------------------------------------------------------------------
# Input Handling
#-----------------------------------------------------------------------------

func _input(event: InputEvent):
	# Skip typewriter effect
	if is_typing and event.is_action_pressed("ui_accept"): # Space, Enter, etc.
		print("WinScreen: Skipping typewriter.")
		get_viewport().set_input_as_handled()
		typewriter_timer.stop()
		win_text_label.text = full_text # Show full text immediately
		displayed_index = full_text.length()
		is_typing = false
		_show_continue_button()

	# Alternative: Allow ui_accept to also trigger continue if button exists and typing is done
	# if not is_typing and continue_button and event.is_action_just_pressed("ui_accept"):
	#     _on_continue_button_pressed()


func _on_continue_button_pressed():
	print("WinScreen: Continue button pressed.")
	_go_to_scene(final_destination_scene_path)


#-----------------------------------------------------------------------------
# Scene Transition
#-----------------------------------------------------------------------------

func _go_to_scene(scene_path_string: String):
	if not scene_path_string.is_empty():
		var loaded_scene = load(scene_path_string)
		if loaded_scene:
			var err = get_tree().change_scene_to_packed(loaded_scene)
			if err != OK:
				print("WinScreen Error: Failed to change scene to '%s'! Error: %s" % [scene_path_string, err])
		else:
			print("WinScreen Error: Failed to load scene from path: %s" % scene_path_string)
	else:
		print("WinScreen Error: Final destination scene path string not set in Inspector!")

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
