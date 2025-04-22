#extends CharacterBody2D
#
#@export var move_speed := 200
#@onready var arrow_scene = preload("res://scenes/Arrow.tscn")  # ✅ Update this path if needed
#
#func _physics_process(delta):
	#var direction = Vector2.ZERO
	#if Input.is_action_pressed("ui_up"): direction.y -= 1
	#if Input.is_action_pressed("ui_down"): direction.y += 1
	#if Input.is_action_pressed("ui_left"): direction.x -= 1
	#if Input.is_action_pressed("ui_right"): direction.x += 1
#
	#velocity = direction.normalized() * move_speed
	#move_and_slide()
#
	#look_at(get_global_mouse_position())
#
#func _input(event):
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		#shoot_arrow()
#
#func shoot_arrow():
	#var arrow = arrow_scene.instantiate()
	#arrow.global_position = global_position
	#arrow.direction = (get_global_mouse_position() - global_position).normalized()
	#arrow.rotation = arrow.direction.angle()
	#get_tree().current_scene.add_child(arrow)

#extends CharacterBody2D
#@export var max_health := 100
#var current_health := 100
#@export var move_speed := 200
#@onready var arrow_scene = preload("res://scenes/Arrow.tscn")
#@export var damage_cooldown := 1.0 # seconds
#var last_damage_times := {} # enemy -> last time they hit
#
#
#
#func _ready():
	#current_health = max_health
	#VideoManager.hide_video()
	#
#func _physics_process(delta):
	#var direction = Vector2.ZERO
	#if Input.is_action_pressed("ui_up"): direction.y -= 1
	#if Input.is_action_pressed("ui_down"): direction.y += 1
	#if Input.is_action_pressed("ui_left"): direction.x -= 1
	#if Input.is_action_pressed("ui_right"): direction.x += 1
#
	#velocity = direction.normalized() * move_speed
	#move_and_slide()
#
	#look_at(get_global_mouse_position())
	#var now = Time.get_ticks_msec() / 1000.0
	#for enemy in touching_enemies:
		#if now - last_damage_times[enemy] >= damage_cooldown:
			#last_damage_times[enemy] = now
			#take_damage(10)
#
#func _input(event):
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		#shoot_arrow()
#
#func shoot_arrow():
	#var arrow = arrow_scene.instantiate()
	#arrow.global_position = global_position
	#arrow.direction = (get_global_mouse_position() - global_position).normalized()
	#arrow.rotation = arrow.direction.angle()
	#get_tree().current_scene.add_child(arrow)
#
#func take_damage(amount):
	#current_health -= amount
	#print("Health:", current_health)
#
	#if current_health <= 0:
		#die()
#
#func die():
	#print("You died!")
	#var hud = get_tree().get_first_node_in_group("hud")
	#if hud:
		#Global.update_score(hud.kills)
	#else:
		#print("[Archer] ERROR: HUD not found!")
		#Global.update_score(0)
#
	#get_tree().change_scene_to_file("res://scenes/GameOver.tscn")
#
	##queue_free() # or show game over screen
	####Global.last_score = current_health <= 0 ? hud.kills : 0
	####get_tree().change_scene_to_file("res://scenes/GameOver.tscn")
##func die():
	##var hud = get_tree().get_first_node_in_group("hud")
	##if hud:
		##Global.last_score = hud.kills
	##else:
		##Global.last_score = 0
##
	##get_tree().change_scene_to_file("res://scenes/GameOver.tscn")
#
#
#var touching_enemies := []
#func _on_hurtbox_body_entered(body: Node2D) -> void:
	#if body.is_in_group("enemy"):
		#touching_enemies.append(body)
		#last_damage_times[body] = -999.0
#
#func _on_hurtbox_body_exited(body: Node2D) -> void:
	#if body in touching_enemies:
		#touching_enemies.erase(body)
		#last_damage_times.erase(body)
#
#func heal(amount):
	#current_health = min(current_health + amount, max_health)
	#print("[Archer] Healed to:", current_health)

#extends CharacterBody2D
#
#@export var max_health := 100
#var current_health := 100
#var hud = get_tree().get_first_node_in_group("hud")
#
#@export var move_speed := 200
#@onready var arrow_scene = preload("res://scenes/Arrow.tscn")
#
#@export var damage_cooldown := 1.0 # seconds
#var last_damage_times := {} # enemy -> last time they hit
#var touching_enemies := []
#
#
#func _ready():
	#current_health = max_health
	#VideoManager.hide_video()
#
#
#func _physics_process(delta):
	#var direction = Vector2.ZERO
	#if Input.is_action_pressed("ui_up"): direction.y -= 1
	#if Input.is_action_pressed("ui_down"): direction.y += 1
	#if Input.is_action_pressed("ui_left"): direction.x -= 1
	#if Input.is_action_pressed("ui_right"): direction.x += 1
#
	#velocity = direction.normalized() * move_speed
	#move_and_slide()
#
	#look_at(get_global_mouse_position())
#
	#var now = Time.get_ticks_msec() / 1000.0
	#for enemy in touching_enemies:
		#if now - last_damage_times[enemy] >= damage_cooldown:
			#last_damage_times[enemy] = now
			#take_damage(10)
#
#
#func _input(event):
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		#shoot_arrow()
#
#
#func shoot_arrow():
	#var arrow = arrow_scene.instantiate()
	#arrow.global_position = global_position
	#arrow.direction = (get_global_mouse_position() - global_position).normalized()
	#arrow.rotation = arrow.direction.angle()
	#get_tree().current_scene.add_child(arrow)
#
#
#func take_damage(amount):
	#current_health -= amount
	#print("Health:", current_health)
#
	#if current_health <= 0:
		#die()
#
#
#func die():
	#print("You died!")
#
	#var hud = get_tree().get_first_node_in_group("hud")
	#if hud:
		#Global.update_score(hud.kills)
	#else:
		#print("[Archer] ERROR: HUD not found!")
		#Global.update_score(0)
#
	#get_tree().change_scene_to_file("res://scenes/GameOver.tscn")
#
#
#func _on_hurtbox_body_entered(body: Node2D) -> void:
	#if body.is_in_group("enemy"):
		#touching_enemies.append(body)
		#last_damage_times[body] = -999.0
#
#
#func _on_hurtbox_body_exited(body: Node2D) -> void:
	#if body in touching_enemies:
		#touching_enemies.erase(body)
		#last_damage_times.erase(body)
#
#
#func heal(amount):
	#current_health = min(current_health + amount, max_health)
	#print("[Archer] Healed to:", current_health)

extends CharacterBody2D

@export var max_health := 100
@export var move_speed := 200
@export var damage_cooldown := 1.0 # seconds
# Preload the scenes for smoother transition
@onready var arrow_scene = preload("res://scenes/Arrow.tscn")
@onready var game_over_scene = preload("res://scenes/GameOver.tscn") # Verify this path
@onready var jail_scene = preload("res://scenes/jail.tscn")          # Verify this path
var current_health := 100
var last_damage_times := {} # enemy -> last hit time
var touching_enemies := []

func _ready():
	current_health = max_health
	VideoManager.hide_video()

func _physics_process(delta):
	# Movement
	var direction = Vector2.ZERO
	if Input.is_action_pressed("ui_up"): direction.y -= 1
	if Input.is_action_pressed("ui_down"): direction.y += 1
	if Input.is_action_pressed("ui_left"): direction.x -= 1
	if Input.is_action_pressed("ui_right"): direction.x += 1
	velocity = direction.normalized() * move_speed
	move_and_slide()

	# Rotate towards mouse
	look_at(get_global_mouse_position())

	# Apply damage over time
	var now = Time.get_ticks_msec() / 1000.0
	for enemy in touching_enemies:
		if now - last_damage_times[enemy] >= damage_cooldown:
			last_damage_times[enemy] = now
			take_damage(10)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		shoot_arrow()

func shoot_arrow():
	var arrow = arrow_scene.instantiate()
	arrow.global_position = global_position
	arrow.direction = (get_global_mouse_position() - global_position).normalized()
	arrow.rotation = arrow.direction.angle()
	get_tree().current_scene.add_child(arrow)

func take_damage(amount):
	current_health -= amount
	print("Health:", current_health)
	update_hud_health()

	if current_health <= 0:
		die()

func die():
	print("You died!")

	var kills_achieved := 0 # Default to 0 kills if HUD is not found
	var hud = get_tree().get_first_node_in_group("hud")

	if hud:
		# Ensure the 'kills' variable exists in the HUD script
		if "kills" in hud:
			kills_achieved = hud.kills
			print("Final Kills: %d" % kills_achieved)
			# Update global high score regardless of win/loss condition?
			# If Global script handles high score logic, this call is fine here.
			Global.update_score(kills_achieved)
		else:
			print("[Archer] ERROR: HUD node found but does not have 'kills' property!")
			# Update score with 0 if kills property missing from HUD
			Global.update_score(0)
	else:
		print("[Archer] ERROR: HUD not found! Cannot determine kill count.")
		# Update score with 0 if no HUD found
		Global.update_score(0)

	# --- Conditional Scene Change Based on Kills ---
	if kills_achieved >= 50:
		print("Kills reached target (%d >= 50)! Proceeding to Jail scene." % kills_achieved)
		# Ensure the preloaded scene is valid before changing
		if jail_scene:
			get_tree().change_scene_to_packed(jail_scene)
		else:
			push_error("Jail scene not preloaded or path is incorrect!")
			# Fallback? Maybe go to game over anyway?
			if game_over_scene: get_tree().change_scene_to_packed(game_over_scene)

	else:
		print("Kills below target (%d < 50). Game Over." % kills_achieved)
		# Ensure the preloaded scene is valid before changing
		if game_over_scene:
			get_tree().change_scene_to_packed(game_over_scene)
		else:
			push_error("Game Over scene not preloaded or path is incorrect!")
			# Critical error - nowhere to go? Maybe quit or go to main menu?
			# get_tree().quit()
	# ---------------------------------------------

	# Note: queue_free() is generally not needed when changing scenes,
	# as the current scene tree is usually freed automatically.

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		touching_enemies.append(body)
		last_damage_times[body] = -999.0

func _on_hurtbox_body_exited(body: Node2D) -> void:
	if body in touching_enemies:
		touching_enemies.erase(body)
		last_damage_times.erase(body)

func heal(amount):
	current_health = min(current_health + amount, max_health)
	print("[Archer] Healed to:", current_health)
	update_hud_health()

func update_hud_health():
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.update_health(current_health)
