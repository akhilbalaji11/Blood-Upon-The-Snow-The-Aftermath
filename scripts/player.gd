extends CharacterBody2D

var objIAmInteractingWith: Node2D
var posToGoTo : Vector2


func _ready() -> void:
	GlobalScriptHelperManager.updateObjPlayerIsLookingAt.connect(jibajaba)

func jibajaba(nodeName, secondVar) -> void:
	print("was called by ", nodeName, secondVar)
	pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		posToGoTo = get_global_mouse_position()
	if Input.is_action_just_pressed("eToInteract"):
		print("I just interacted with this thing")

func _physics_process(delta: float) -> void:
	var vel = (posToGoTo - self.global_position)
	vel = vel.clamp(Vector2(-100, -100), Vector2(100, 100))
	velocity = vel
	move_and_slide()
