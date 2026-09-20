extends RefCounted
class_name HyperPlane


enum Steps { F, L, R, N, E, S, W, C, NA }
const EMPTY_STEPS_ARRAY: Array[Steps] = []
const EMPTY_NODE_ARRAY: Array[HyperPlaneNode] = []

var cell_hashmap: Dictionary[Array, HyperPlaneNode]

func _init(depth: int = 2) -> void:
	# set up tree
	var root_cell = HyperPlaneNode.new([Steps.C])
	cell_hashmap[root_cell.coordinates] = root_cell

	root_cell.neighbors = [
		HyperPlaneNode.new([Steps.N]),
		HyperPlaneNode.new([Steps.E]),
		HyperPlaneNode.new([Steps.S]),
		HyperPlaneNode.new([Steps.W])
	]

	for cell in root_cell.neighbors:
		cell_hashmap[cell.coordinates] = cell
		init_tree(cell, depth)
	
	# find neighbors to make full graph
	for cell in cell_hashmap.values():
		# grab [N], [E], [S], [W], [C] cells -> special case
		if len(cell.coordinates) <= 1:
			if cell.coordinates != [HyperPlane.Steps.C]:
				cell.neighbors.append(root_cell)
			continue
		
		# add parent neighbor
		cell.neighbors = [cell_hashmap[cell.coordinates.slice(0, -1)]]

		# add right neighbor
		if cell.coordinates[-1] == Steps.R:
			var new_coord = cell.coordinates.slice(0, -2)
			new_coord += [turn_direction_right(cell.coordinates[-2]), Steps.L]
			cell.neighbors.append(cell_hashmap[new_coord])
		elif len(cell.coordinates) <= depth:
			cell.neighbors.append(cell_hashmap[cell.coordinates + [Steps.R]])
		
		# add center neighbor
		if len(cell.coordinates) <= depth:
			var new_coord = cell.coordinates.duplicate()
			new_coord.append(Steps.C)
			cell.neighbors.append(cell_hashmap[new_coord])
		
		# add left neighbor
		if cell.coordinates[-1] == Steps.L:
			var new_coord = cell.coordinates.slice(0, -2)
			new_coord += [turn_direction_left(cell.coordinates[-2]), Steps.R]
			cell.neighbors.append(cell_hashmap[new_coord])
		elif len(cell.coordinates) <= depth:
			cell.neighbors.append(cell_hashmap[cell.coordinates + [Steps.R]])


func init_tree(node: HyperPlaneNode, depth: int) -> void:
	if depth == 0: return
	depth -= 1

	var append_cell = func(step: Steps):
		var child = HyperPlaneNode.new(append_new_step_array(node.coordinate, [step]))
		cell_hashmap[child.coordinates] = child
		node.neighbors.append(child)
		init_tree(child, depth)

	if node.coordinates[-1] != Steps.R:
		append_cell.call(Steps.R)
	append_cell.call(Steps.F)
	if check_l_step_allowed(node.coordinates):
		append_cell.call(Steps.L)

func check_l_step_allowed(steps: Array[Steps]) -> bool:
	for i in range(steps.size() - 1, -1, -1):
		if steps[i] == Steps.L:
			return false
		if steps[i] == Steps.R:
			return true
	return true

func append_new_step_array(array: Array[Steps], new_coords: Array[Steps]) -> Array[Steps]:
	var new_array: Array[Steps] = (EMPTY_STEPS_ARRAY.duplicate() + array + new_coords) as Array[Steps]
	return new_array

func turn_direction_right(direction: Steps) -> Steps:
	match direction:
		Steps.L:
			return Steps.C
		Steps.C:
			return Steps.R
		_:
			printerr("Attempted to turn an invalid direction to the right!")
			return Steps.NA

func turn_direction_left(direction: Steps) -> Steps:
	match direction:
		Steps.R:
			return Steps.C
		Steps.C:
			return Steps.L
		_:
			printerr("Attempted to turn an invalid direction to the left!")
			return Steps.NA
