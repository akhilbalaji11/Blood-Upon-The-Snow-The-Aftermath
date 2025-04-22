#extends CharacterBody2D
#
#@export var speed := 100
#var player = null
#
#func _ready():
	#player = get_tree().get_first_node_in_group("player")
#
#func _physics_process(delta):
	#if player:
		#var direction = (player.global_position - global_position).normalized()
		#velocity = direction * speed
		#move_and_slide()
# kinda works
#extends CharacterBody2D
#
#@export var speed := 100
#var player = null
#var damage_cooldown := 1.0
#var last_damage_time := -999.0
#
#func _ready():
	#player = get_tree().get_first_node_in_group("player")
#
#func _physics_process(delta):
	#if player:
		#var direction = (player.global_position - global_position).normalized()
		#velocity = direction * speed
		#move_and_slide()
#
### For Option B (if using Area2D for attack)
##func _on_AttackArea_body_entered(body):
	##if body.is_in_group("player"):
		##var now = Time.get_ticks_msec() / 1000.0
		##if now - last_damage_time >= damage_cooldown:
			##last_damage_time = now
			##body.take_damage(10)
#
#
#func _on_attack_area_body_entered(body: Node2D) -> void:
	#if body.is_in_group("player"):
		#var now = Time.get_ticks_msec() / 1000.0
		#if now - last_damage_time >= damage_cooldown:
			#last_damage_time = now
			#body.take_damage(10)
#
#extends CharacterBody2D
#
#@export var speed := 100
#@export var damage := 10
#var player = null
#var is_player_in_range := false
#
#@onready var damage_timer = $AttackArea/DamageTimer
#
#func _ready():
	#player = get_tree().get_first_node_in_group("player")
	#$AttackArea.body_entered.connect(_on_body_entered)
	#$AttackArea.body_exited.connect(_on_body_exited)
	#damage_timer.timeout.connect(_on_damage_timer_timeout)
#
#func _physics_process(delta):
	#if player:
		#var direction = (player.global_position - global_position).normalized()
		#velocity = direction * speed
		#move_and_slide()
#
#func _on_body_entered(body):
	#if body.is_in_group("player"):
		#is_player_in_range = true
		#damage_timer.start()
#
#func _on_body_exited(body):
	#if body.is_in_group("player"):
		#is_player_in_range = false
		#damage_timer.stop()
#
#func _on_damage_timer_timeout():
	#if is_player_in_range and player:
		#player.take_damage(damage)
#
#extends CharacterBody2D
#
#@export var speed := 100
#@export var damage := 10
#
#@onready var damage_timer = $AttackArea/DamageTimer
#var player = null
#var is_player_in_range := false
#
#func _ready():
	#player = get_tree().get_first_node_in_group("player")
	#$AttackArea.body_entered.connect(_on_body_entered)
	#$AttackArea.body_exited.connect(_on_body_exited)
	#damage_timer.timeout.connect(_on_damage_timer_timeout)
#
#func _physics_process(delta):
	#if player:
		#var direction = (player.global_position - global_position).normalized()
		#velocity = direction * speed
		#move_and_slide()
#
#func _on_body_entered(body):
	#if body.is_in_group("player"):
		#is_player_in_range = true
		#player = body
		#player.take_damage(damage)  # 👈 INSTANT first hit
		#damage_timer.start()        # 👈 Start timer for next hits
#
#func _on_body_exited(body):
	#if body.is_in_group("player"):
		#is_player_in_range = false
		#damage_timer.stop()        # 👈 Stop when archer leaves
#
#func _on_damage_timer_timeout():
	#if is_player_in_range and player:
		#player.take_damage(damage)  # 👈 Repeated hits every 1s
#
#func die():
	#print("[Enemy] Died")
	#try_drop_health()
	#queue_free()
#
#@onready var health_pack_scene = preload("res://scenes/HealthPack.tscn")
#
#func try_drop_health():
	#if randi() % 4 == 0: # 25% chance
		#var pack = health_pack_scene.instantiate()
		#pack.global_position = global_position
		#get_tree().current_scene.add_child(pack)
		#print("[Enemy] Dropped health pack!")
	#else:
		#print("[Enemy] No health drop.")

#extends CharacterBody2D
#
#@export var speed := 100
#@export var damage := 10
#@onready var damage_timer = $AttackArea/DamageTimer
#@onready var health_pack_scene = preload("res://scenes/HealthPack.tscn")
#
#var player = null
#var is_player_in_range := false
#
#func _ready():
	#randomize() # ensure random drop rates work
	#player = get_tree().get_first_node_in_group("player")
	#$AttackArea.body_entered.connect(_on_body_entered)
	#$AttackArea.body_exited.connect(_on_body_exited)
	#damage_timer.timeout.connect(_on_damage_timer_timeout)
#
#func _physics_process(delta):
	#if player:
		#var direction = (player.global_position - global_position).normalized()
		#velocity = direction * speed
		#move_and_slide()
#
#func _on_body_entered(body):
	#if body.is_in_group("player"):
		#is_player_in_range = true
		#player = body
		#player.take_damage(damage)  # 👈 INSTANT first hit
		#damage_timer.start()        # 👈 Start timer for next hits
#
#func _on_body_exited(body):
	#if body.is_in_group("player"):
		#is_player_in_range = false
		#damage_timer.stop()        # 👈 Stop when archer leaves
#
#func _on_damage_timer_timeout():
	#if is_player_in_range and player:
		#player.take_damage(damage)  # 👈 Repeated hits every 1s
#
#func die():
	#print("[Enemy] Died")
	#try_drop_health()
	#queue_free()
#
##func try_drop_health():
	##print("[Enemy] Trying to drop health pack...")
##
	##var pack = health_pack_scene.instantiate()
	##if not pack:
		##print("ERROR: Could not instantiate health pack!")
		##return
##
	##pack.global_position = global_position
	##get_tree().current_scene.add_child(pack)
	##print("[Enemy] Health pack dropped at:", global_position)
#
#func try_drop_health():
	#print("[Drop] Trying to drop health pack...")
#
	#var chance := randf()
	#print("[Drop] Random value:", chance)
#
	## For testing — force drop
	#if true:  # change to (chance <= 0.4) for 40% later
		#var pack = health_pack_scene.instantiate()
		#if not pack:
			#print("[Drop] ERROR: Failed to instantiate health pack!")
			#return
#
		#pack.global_position = Vector2(300, 300)  # force visible center for test
		#call_deferred("add_health_pack", pack)
	#else:
		#print("[Drop] No health pack dropped. Chance was:", chance)
#
#func add_health_pack(pack):
	#if not pack:
		#print("[Drop] ERROR: No pack to add!")
		#return
#
	#print("[Drop] Adding health pack to scene.")
	#get_tree().current_scene.add_child(pack)

extends CharacterBody2D

@export var speed := 100
@export var damage := 10
@onready var damage_timer = $AttackArea/DamageTimer
@onready var health_pack_scene = preload("res://scenes/HealthPack.tscn")
@onready var hud = get_tree().get_first_node_in_group("hud") # Make sure HUD group exists and node is ready

var player = null
var is_player_in_range := false

# Optional: Reference to sprite if needed for specific visual effects later
# @onready var sprite = $Sprite2D # Or $AnimatedSprite2D, adjust name as needed

func _ready():
	randomize()  # Make sure randf() gives different values each run

	# Get player reference - consider making this more robust if player might not exist initially
	var player_nodes = get_tree().get_nodes_in_group("player")
	if not player_nodes.is_empty():
		player = player_nodes[0] # Get the first node in the group
	else:
		print("[Enemy] Error: Player not found in group 'player' on ready!")
		# Consider how to handle this - maybe disable the enemy? queue_free()?

	# Ensure AttackArea exists before connecting signals
	var attack_area = $AttackArea
	if attack_area:
		attack_area.body_entered.connect(_on_body_entered)
		attack_area.body_exited.connect(_on_body_exited)
	else:
		print("[Enemy] Error: AttackArea node not found!")

	# Ensure DamageTimer exists
	if damage_timer:
		damage_timer.timeout.connect(_on_damage_timer_timeout)
	else:
		# This might fail if AttackArea was missing, as the path includes it
		print("[Enemy] Error: DamageTimer node not found (check path $AttackArea/DamageTimer)!")


func _physics_process(delta):
	# Check if player exists (it might have been destroyed)
	if not is_instance_valid(player):
		# Player is gone, maybe stop moving or despawn?
		velocity = Vector2.ZERO
		# Optionally: queue_free() or find a new target if applicable
		move_and_slide()
		return # Stop processing if no valid player

	# --- Calculate Direction and Rotate ---
	var direction = (player.global_position - global_position).normalized()

	# Rotate the entire enemy body to look at the player
	# Assumes the enemy's sprite faces RIGHT (positive X) by default
	look_at(player.global_position)
	# ------------------------------------

	# --- Movement ---
	velocity = direction * speed
	move_and_slide()


func _on_body_entered(body):
	# Check if the body entering is the specific player instance we track
	if body == player:
		print("[Enemy] Player entered attack range.") # Debug
		is_player_in_range = true
		# Removed setting player = body here, we already have the reference from _ready
		if is_instance_valid(player) and player.has_method("take_damage"): # Check if player can take damage
			player.take_damage(damage)  # Instant first hit
		if damage_timer:
			damage_timer.start()        # Start repeated damage

func _on_body_exited(body):
	# Check if the body leaving is the specific player instance we track
	if body == player:
		print("[Enemy] Player exited attack range.") # Debug
		is_player_in_range = false
		if damage_timer:
			damage_timer.stop()

func _on_damage_timer_timeout():
	# Check player instance validity again before damaging
	if is_player_in_range and is_instance_valid(player) and player.has_method("take_damage"):
		print("[Enemy] Dealing periodic damage to player.") # Debug
		player.take_damage(damage)

func die():
	print("[Enemy] Died")
	try_drop_health()
	if hud and hud.has_method("add_kill"): # Check if hud and method exist
		hud.add_kill()
	queue_free()

func try_drop_health():
	print("[Drop] Trying to drop health pack...")

	var chance := randf()
	print("[Drop] Random value:", chance)

	if chance <= 0.5:  # 50% drop chance
		var pack = health_pack_scene.instantiate()
		if not pack:
			print("[Drop] ERROR: Could not instantiate health pack!")
			return

		pack.global_position = global_position  # Spawn at enemy's death spot
		# Use call_deferred for adding nodes outside the physics step sometimes helps stability
		call_deferred("add_health_pack", pack)
	else:
		print("[Drop] No health pack dropped. Chance was:", chance)

func add_health_pack(pack):
	# Get the current scene dynamically, safer than assuming it's always the same parent
	var current_scene = get_tree().current_scene
	if not is_instance_valid(current_scene):
		print("[Drop] ERROR: Could not get current scene to add health pack!")
		# Need to ensure the pack is freed if it can't be added
		if is_instance_valid(pack):
			pack.queue_free()
		return

	if not is_instance_valid(pack):
		print("[Drop] ERROR: No valid pack instance to add!")
		return

	print("[Drop] Adding health pack to scene: %s" % current_scene.name) # Debug
	current_scene.add_child(pack)
