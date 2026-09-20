extends Node2D
class_name Tile


signal body_entered(tile: Tile)

var grid_position: Vector2i
var hyperplane_node: HyperPlaneNode

func _on_area_2d_body_entered(_body: Node2D) -> void:
	body_entered.emit(self)
