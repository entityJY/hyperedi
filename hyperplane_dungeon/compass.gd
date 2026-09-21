extends Sprite2D
class_name Compass


@export var player: Player
var current_tile: Tile
var facing_direction: int = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var player_position = Vector2(wrapf(player.position.x, -135, 135), wrapf(player.position.y, -135, 135))

	if !is_instance_valid(current_tile): return

	for step in current_tile.hyperplane_node.coordinates:
		match step:
			HyperPlane.Steps.C: break
			HyperPlane.Steps.L:
				facing_direction = wrapi(facing_direction + 1, 0, 4)
				player_position = advance_player_position(player_position)
			HyperPlane.Steps.F:
				player_position = advance_player_position(player_position)
			HyperPlane.Steps.R:
				facing_direction = wrapi(facing_direction - 1, 0, 4)
				player_position = advance_player_position(player_position)
			HyperPlane.Steps.E:
				facing_direction = 0
				player_position.x += 135
			HyperPlane.Steps.N:
				facing_direction = 1
				player_position.y -= 135
			HyperPlane.Steps.W:
				facing_direction = 2
				player_position.x -= 135
			HyperPlane.Steps.S:
				facing_direction = 3
				player_position.y += 135
	
	var angle_to_center = player_position.angle() - current_tile.rotation
	print(player_position)
	rotation = angle_to_center


func advance_player_position(curr_position: Vector2) -> Vector2:
	match facing_direction:
		0: curr_position.x += 135
		1: curr_position.y -= 135
		2: curr_position.x -= 135
		3: curr_position.y += 135
	return curr_position
