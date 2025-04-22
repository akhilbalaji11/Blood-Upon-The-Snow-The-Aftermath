extends Node2D

@export_enum("EASY", "MEDIUM", "HARD")
var duelDifficulty := 0  # 0 = Easy, 1 = Medium, 2 = Hard

const MAX_HP := 100
const DMG := 40
const WINDOW := { 0: 1.5, 1: 1.0, 2: 0.8 }   # How long button stays

var duelPlayerHP := MAX_HP
var duelEnemyHP := MAX_HP
var rng := RandomNumberGenerator.new()

@onready var duelPlayer := $duelPlayer
@onready var duelEnemy := $duelEnemy
@onready var duelClickBtn := $duelUILayer/duelClickBtn
@onready var duelSpawnTimer := $duelSpawnTimer
@onready var duelWindowTimer := $duelWindowTimer
@onready var duelAttackTimer := $duelAttackTimer
@onready var labelPlayer := $duelHUD/duelPlayerHP
@onready var labelEnemy := $duelHUD/duelEnemyHP

#func _ready():
	#Global.current_level = 3
	#rng.randomize()
	#_update_health_labels()
	#duelClickBtn.pressed.connect(_on_button_pressed)
	#duelSpawnTimer.timeout.connect(_spawn_button)
	#duelWindowTimer.timeout.connect(_missed_window)
	#duelAttackTimer.timeout.connect(_round_over)
	#duelClickBtn.hide()
	#VideoManager.hide_video()
#
## ⏱ Called every 5 seconds by duelSpawnTimer
#func _spawn_button():
	#if duelPlayerHP <= 0 or duelEnemyHP <= 0:
		#duelSpawnTimer.stop()
		#return
#
	#var margin := 32
	#var screen_size = get_viewport_rect().size
	#var btn_size = duelClickBtn.get_size()
	#duelClickBtn.position = Vector2(
	#rng.randf_range(0, screen_size.x - btn_size.x),
	#rng.randf_range(0, screen_size.y - btn_size.y)
#)
#
	#duelClickBtn.disabled = false
	#duelClickBtn.show()
	#duelWindowTimer.start(WINDOW[duelDifficulty])
#
## ✅ Player clicked button on time
#func _on_button_pressed():
	#duelWindowTimer.stop()
	#duelClickBtn.hide()
	#duelClickBtn.disabled = true
	#_player_hits()
#
## ❌ Player missed the button
#func _missed_window():
	#duelClickBtn.hide()
	#duelClickBtn.disabled = true
	#_enemy_hits()
#
#func _player_hits():
	#duelPlayer.play("attack")
	#duelEnemy.play("hurt")
	#duelEnemyHP = max(duelEnemyHP - DMG, 0)
	#_update_health_labels()
#
	#if duelEnemyHP <= 0:
		#duelSpawnTimer.stop()
		#duelClickBtn.hide()
		#duelClickBtn.disabled = true
		#duelEnemy.animation_finished.connect(_on_enemy_death_finished, CONNECT_ONE_SHOT)
		#duelEnemy.play("death")
	#else:
		## Wait for attack animation to finish before returning to idle
		#duelPlayer.animation_finished.connect(_on_attack_finished, CONNECT_ONE_SHOT)
#
#func _enemy_hits():
	#duelEnemy.play("attack")
	#duelPlayer.play("hurt")
	#duelPlayerHP = max(duelPlayerHP - DMG, 0)
	#_update_health_labels()
#
	#if duelPlayerHP <= 0:
		#duelSpawnTimer.stop()
		#duelClickBtn.hide()
		#duelClickBtn.disabled = true
		#duelPlayer.animation_finished.connect(_on_player_death_finished, CONNECT_ONE_SHOT)
		#duelPlayer.play("death")
	#else:
		## Wait for enemy attack animation to finish before returning to idle
		#duelEnemy.animation_finished.connect(_on_attack_finished, CONNECT_ONE_SHOT)
#
#func _on_attack_finished():
	#if duelPlayerHP > 0:
		#duelPlayer.play("idle")
	#if duelEnemyHP > 0:
		#duelEnemy.play("idle")
#
## 🔁 Return to idle after attack
#func _round_over():
	#if duelPlayerHP > 0:
		#duelPlayer.play("idle")
	#if duelEnemyHP > 0:
		#duelEnemy.play("idle")
#
## 💡 Update health label text
#func _update_health_labels():
	#labelPlayer.text = "YOU: %d" % duelPlayerHP
	#labelEnemy.text = "FOE: %d" % duelEnemyHP
#
#func _on_enemy_death_finished():
	#get_tree().change_scene_to_file("res://scenes/victory.tscn")
#
#func _on_player_death_finished():
	#get_tree().change_scene_to_file("res://scenes/lose.tscn")
#NEW
func _ready():
	Global.current_level = 3
	rng.randomize()
	_update_health_labels()
	# Start both characters in idle animation
	duelPlayer.play("idle")
	duelEnemy.play("idle")
	duelClickBtn.pressed.connect(_on_button_pressed)
	duelSpawnTimer.timeout.connect(_spawn_button)
	duelWindowTimer.timeout.connect(_missed_window)
	duelAttackTimer.timeout.connect(_round_over)
	duelClickBtn.hide()
	VideoManager.hide_video()

# ⏱ Called every 5 seconds by duelSpawnTimer
func _spawn_button():
	if duelPlayerHP <= 0 or duelEnemyHP <= 0:
		duelSpawnTimer.stop()
		return

	var margin := 32
	var screen_size = get_viewport_rect().size
	var btn_size = duelClickBtn.get_size()
	duelClickBtn.position = Vector2(
	rng.randf_range(0, screen_size.x - btn_size.x),
	rng.randf_range(0, screen_size.y - btn_size.y)
)

	duelClickBtn.disabled = false
	duelClickBtn.show()
	duelWindowTimer.start(WINDOW[duelDifficulty])

# ✅ Player clicked button on time
func _on_button_pressed():
	duelWindowTimer.stop()
	duelClickBtn.hide()
	duelClickBtn.disabled = true
	_player_hits()

# ❌ Player missed the button
func _missed_window():
	duelClickBtn.hide()
	duelClickBtn.disabled = true
	_enemy_hits()

func _player_hits():
	# Stop gameplay inputs during the attack-hurt sequence
	duelSpawnTimer.stop()
	duelClickBtn.hide()
	duelClickBtn.disabled = true

	# Step 1: Player attacks first
	duelPlayer.animation_finished.connect(_on_player_attack_finished, CONNECT_ONE_SHOT)
	duelPlayer.play("attack")

func _enemy_hits():
	# Stop gameplay inputs during the attack-hurt sequence
	duelSpawnTimer.stop()
	duelClickBtn.hide()
	duelClickBtn.disabled = true

	# Step 1: Enemy attacks first
	duelEnemy.animation_finished.connect(_on_enemy_attack_finished, CONNECT_ONE_SHOT)
	duelEnemy.play("attack")


func _on_player_attack_finished():
	duelEnemy.play("hurt")
	duelEnemyHP = max(duelEnemyHP - DMG, 0)
	_update_health_labels()

	if duelEnemyHP <= 0:
		duelEnemy.animation_finished.connect(_on_enemy_death_finished, CONNECT_ONE_SHOT)
		duelEnemy.play("death")
	else:
		duelEnemy.animation_finished.connect(_on_attack_finished, CONNECT_ONE_SHOT)

func _on_enemy_attack_finished():
	duelPlayer.play("hurt")
	duelPlayerHP = max(duelPlayerHP - DMG, 0)
	_update_health_labels()

	if duelPlayerHP <= 0:
		duelPlayer.animation_finished.connect(_on_player_death_finished, CONNECT_ONE_SHOT)
		duelPlayer.play("death")
	else:
		duelPlayer.animation_finished.connect(_on_attack_finished, CONNECT_ONE_SHOT)

func _on_attack_finished():
	if duelPlayerHP > 0:
		duelPlayer.play("idle")
	if duelEnemyHP > 0:
		duelEnemy.play("idle")
	# 🔁 Restart the spawn cycle
	duelSpawnTimer.start()

func _on_player_death_finished():
	get_tree().change_scene_to_file("res://scenes/lose.tscn")

func _on_enemy_death_finished():
	get_tree().change_scene_to_file("res://scenes/victory.tscn")


# 🔁 Return to idle after attack
func _round_over():
	if duelPlayerHP > 0:
		duelPlayer.play("idle")
	if duelEnemyHP > 0:
		duelEnemy.play("idle")

# 💡 Update health label text
func _update_health_labels():
	labelPlayer.text = "Thorgestr: %d" % duelPlayerHP
	labelEnemy.text = "Bjorn: %d" % duelEnemyHP
