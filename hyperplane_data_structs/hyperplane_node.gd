extends RefCounted
class_name HyperPlaneNode

var tile: Tile
var neighbors: Dictionary[int, HyperPlaneNode]
var coordinates: Array[HyperPlane.Steps]

## for use with maze generation
var explored = false
## for use with maze generation
var reachable_neighbors: Dictionary[int, HyperPlaneNode]

func _init(p_coordinates: Array[HyperPlane.Steps]) -> void:
	coordinates = p_coordinates

func get_neighbors_nice() -> String:
	var final_str: String = ""
	for key in neighbors.keys():
		final_str += "key: " + str(key) + ", coordinate: " + neighbors[key].get_coordinates_nice() + "\n"
	if final_str.is_empty():
		return "Contains no neighbors"
	return final_str

func get_reachable_neighbors_nice() -> String:
	var final_str: String = ""
	for key in reachable_neighbors.keys():
		final_str += "key: " + str(key) + ", coordinate: " + reachable_neighbors[key].get_coordinates_nice() + "\n"
	if final_str.is_empty():
		return "Contains no reachable neighbors"
	return final_str

func get_coordinates_nice() -> String:
	var final_str: String = ""
	for dir in coordinates:
		final_str += HyperPlane.Steps.find_key(dir)
	return final_str
