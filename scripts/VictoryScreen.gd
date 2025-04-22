extends Control

func _ready():
	$Button.pressed.connect(_on_next_pressed)

func _on_next_pressed():
	match Global.current_level:
		1: get_tree().change_scene_to_file("res://scenes/duelMain2.tscn")
		2: get_tree().change_scene_to_file("res://scenes/duelMain3.tscn")
		3: get_tree().change_scene_to_file("res://scenes/win.tscn")  # optional final win screen
