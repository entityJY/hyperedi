extends Node2D
class_name Tile


## array of disable able walls in order of E, N, W, S
@export var walls: Array[StaticBody2D]
@export var label: Label
@export var background: Sprite2D

var grid_position: Vector2i
var hyperplane_node: HyperPlaneNode

signal body_entered(tile: Tile)

func _on_area_2d_body_entered(_body: Node2D) -> void:
	body_entered.emit(self)
