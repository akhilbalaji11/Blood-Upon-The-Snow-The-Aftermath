#extends CanvasLayer
#
#var kills := 0
#var high_score := 0
#
#@onready var kill_label = $KillLabel
#@onready var high_score_label = $HighScoreLabel
#
#func _ready():
	#update_labels()
#
#func add_kill():
	#kills += 1
	#if kills > high_score:
		#high_score = kills
	#update_labels()
#
#func reset_kills():
	#kills = 0
	#update_labels()
#
#func update_labels():
	#kill_label.text = "Kills: " + str(kills)
	#high_score_label.text = "High Score: " + str(high_score)
# high score
extends CanvasLayer

var kills := 0
var max_health := 100
@onready var kill_label = $KillLabel
@onready var high_score_label = $HighScoreLabel
@onready var health_label = $HealthLabel
func _ready():
	update_labels()

func add_kill():
	kills += 1
	update_labels()

func reset_kills():
	kills = 0
	update_labels()

func update_labels():
	kill_label.text = "Kills: " + str(kills)
	high_score_label.text = "High Score: " + str(Global.high_score)  # 👈 use the real one

func update_health(current: int):
	health_label.text = "Health: " + str(current) + "/" + str(max_health)
