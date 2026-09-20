extends CharacterBody2D
class_name Player


@export var SPEED = 300.0


func _physics_process(_delta: float) -> void:
	
	velocity = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")) * SPEED

	move_and_slide()
