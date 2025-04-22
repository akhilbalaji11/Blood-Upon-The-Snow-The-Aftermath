extends Control


func _ready():
	$MarginContainer/VBoxContainer/Play.grab_focus()
	VideoManager.show_video()
	
func _on_play_pressed():
	VideoManager.hide_video()
	get_tree().change_scene_to_file("res://Scenes/world.tscn")

func _on_options_pressed():
	get_tree().change_scene_to_file("res://Scenes/options_menu.tscn")
