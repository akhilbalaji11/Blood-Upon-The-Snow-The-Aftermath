extends Control

func _ready():
	$Button.pressed.connect(_on_retry_pressed)

func _on_retry_pressed():
	match Global.current_level:
		1: get_tree().change_scene_to_file("res://scenes/duelMain.tscn")
		2: get_tree().change_scene_to_file("res://scenes/duelMain2.tscn")
		3: get_tree().change_scene_to_file("res://scenes/duelMain3.tscn")
