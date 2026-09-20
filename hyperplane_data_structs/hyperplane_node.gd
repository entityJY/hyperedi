extends RefCounted
class_name HyperPlaneNode

var tile: Node2D
var neighbors: Array[HyperPlaneNode]
var coordinates: Array[HyperPlane.Steps]

func _init(p_coordinates: Array[HyperPlane.Steps]) -> void:
    coordinates = p_coordinates
