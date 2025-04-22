extends Node2D

@onready var spawn_timer = $SpawnTimer
@onready var enemy_scene = preload("res://scenes/Enemy.tscn")
var time_between_spawns = 2.0
var min_time = 0.5

func _ready():
	spawn_timer.timeout.connect(spawn_enemy)


func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	var spawn_position = get_random_spawn_position()
	enemy.global_position = spawn_position
	get_tree().current_scene.add_child(enemy)

	# Increase difficulty: spawn faster
	time_between_spawns = max(time_between_spawns - 0.1, min_time)
	spawn_timer.wait_time = time_between_spawns
	spawn_timer.start()

func get_random_spawn_position() -> Vector2:
	var screen_rect = get_viewport_rect()
	var margin = 50
	var side = randi() % 4

	match side:
		0:  # Top
			return Vector2(randf_range(0, screen_rect.size.x), -margin)
		1:  # Bottom
			return Vector2(randf_range(0, screen_rect.size.x), screen_rect.size.y + margin)
		2:  # Left
			return Vector2(-margin, randf_range(0, screen_rect.size.y))
		3:  # Right
			return Vector2(screen_rect.size.x + margin, randf_range(0, screen_rect.size.y))
	
	# fallback (should never hit)
	return Vector2.ZERO
