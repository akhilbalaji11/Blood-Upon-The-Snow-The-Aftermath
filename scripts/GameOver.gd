extends Node2D

func _ready():
	$CanvasLayer/FinalScoreLabel.text = "Kills: " + str(Global.last_score)
	$CanvasLayer/HighScoreLabel.text = "High Score: " + str(Global.high_score)
	$CanvasLayer/RestartButton.pressed.connect(_on_restart_pressed)


func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ArcheryMinigame.tscn")
