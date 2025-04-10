extends Area2D

@export var msg := ""

func _ready() -> void:
	body_entered.connect(onBodyEnter)

func onBodyEnter(body:PhysicsBody2D) -> void:
	GlobalScriptHelperManager.emit_signal("updateObjPlayerIsLookingAt", msg, self.name)
