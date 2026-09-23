extends CharacterBody2D
class_name Player

@export var SPEED = 300.0
@export var sprite: Sprite2D

var current_tile: Tile
var markers: Array[Sprite2D]

var out_of_bounds_x = 0
var out_of_bounds_y = 0

func _physics_process(_delta: float) -> void:
	
	velocity = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")) * SPEED

	if position.x * sign(position.x) >= 100 and sign(velocity.x) == sign(position.x):
		velocity.x = 0
		out_of_bounds_x = sign(position.x)
	else:
		out_of_bounds_x = 0
	if position.y * sign(position.y) >= 100 and sign(velocity.y) == sign(position.y):
		velocity.y = 0
		out_of_bounds_y = sign(position.y)
	else:
		out_of_bounds_y = 0

	move_and_slide()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("place") and is_instance_valid(current_tile):
		var duped_sprite = sprite.duplicate()
		duped_sprite.modulate = Color.from_string("00a1a1", Color.CYAN)
		var saved_position = global_position
		var saved_rotation = global_rotation
		current_tile.add_child(duped_sprite)

		duped_sprite.global_position = saved_position
		duped_sprite.global_rotation = saved_rotation
		markers.append(duped_sprite)

		if len(markers) > 5:
			markers.pop_front().queue_free()
