#extends Area2D
#
#@export var speed := 600
#var direction := Vector2.ZERO
#
#func _process(delta):
	#position += direction * speed * delta
#
	## If the arrow goes off screen, remove it
	#if not get_viewport_rect().has_point(global_position):
		#queue_free()
#
#
#func _on_body_entered(body: Node2D) -> void:
	#if body.is_in_group("enemy"):
		#body.queue_free() # kill the enemy
		#queue_free() # remove the arrow

extends Area2D

@export var speed := 600
var direction := Vector2.ZERO

func _process(delta):
	position += direction * speed * delta
	if not get_viewport_rect().has_point(global_position):
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		print("[Arrow] Hit enemy:", body.name)
		if body.has_method("die"):
			body.die() # 👈 This calls the enemy's die() method
		else:
			print("[Arrow] ERROR: Enemy has no die() method!")
		queue_free()
