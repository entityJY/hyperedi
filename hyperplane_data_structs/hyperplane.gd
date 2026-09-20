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

	root_cell.neighbors[0] = HyperPlaneNode.new([Steps.E])
	root_cell.neighbors[1] = HyperPlaneNode.new([Steps.N])
	root_cell.neighbors[2] = HyperPlaneNode.new([Steps.W])
	root_cell.neighbors[3] = HyperPlaneNode.new([Steps.S])

	for cell in root_cell.neighbors.values():
		cell_hashmap[cell.coordinates] = cell
		init_tree(cell, depth)
	
	# find neighbors to make full graph
	for cell in cell_hashmap.values():
		# exclude [C] cells
		if len(cell.coordinates) <= 1 and cell.coordinates == [HyperPlane.Steps.C]:
			continue
		
		# get rotation num
		var cell_rotation: int = 0
		for dir in cell.coordinates:
			match dir:
				Steps.C: break
				Steps.N: cell_rotation = 1
				Steps.W: cell_rotation = 2
				Steps.S: cell_rotation = 3
				Steps.R: cell_rotation = wrapi(cell_rotation + 3, 0, 4)
				Steps.L: cell_rotation = wrapi(cell_rotation + 1, 0, 4)
		
		# clear existing neighbor list
		cell.neighbors.clear()
		
		# add parent neighbor
		if len(cell.coordinates) == 1 and cell.coordinates != [Steps.C]:
			cell.neighbors[wrapi(2+cell_rotation, 0, 4)] = root_cell
		else:
			cell.neighbors[wrapi(2+cell_rotation, 0, 4)] = cell_hashmap[cell.coordinates.slice(0, -1)]

		# add right neighbor
		if cell.coordinates[-1] == Steps.R:
			var new_coord = cell.coordinates.slice(0, -2)
			new_coord += [turn_direction_right(cell.coordinates[-2]), Steps.L]
			cell.neighbors[wrapi(3+cell_rotation, 0, 4)] = cell_hashmap[new_coord]
		elif len(cell.coordinates) <= depth:
			cell.neighbors[wrapi(3+cell_rotation, 0, 4)] = cell_hashmap[cell.coordinates + [Steps.R]]
		
		# add forward neighbor
		if len(cell.coordinates) <= depth:
			var new_coord = cell.coordinates.duplicate()
			new_coord.append(Steps.F)
			cell.neighbors[wrapi(0+cell_rotation, 0, 4)] = cell_hashmap[new_coord]
		
		# add left neighbor
		if cell.coordinates[-1] == Steps.L:
			var new_coord = cell.coordinates.slice(0, -2)
			new_coord += [turn_direction_left(cell.coordinates[-2]), Steps.R]
			cell.neighbors[wrapi(1+cell_rotation, 0, 4)] = cell_hashmap[new_coord]
		elif len(cell.coordinates) <= depth:
			cell.neighbors[wrapi(1+cell_rotation, 0, 4)] = cell_hashmap[cell.coordinates + [Steps.L]]


func init_tree(node: HyperPlaneNode, depth: int) -> void:
	if depth == 0: return
	depth -= 1

	var append_cell = func(step: Steps):
		var child = HyperPlaneNode.new(append_new_step_array(node.coordinates, [step]))
		cell_hashmap[child.coordinates] = child
		node.neighbors[step] = child
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
		Steps.L: return Steps.F
		Steps.F: return Steps.R
		Steps.E: return Steps.S
		Steps.N: return Steps.E
		Steps.W: return Steps.N
		Steps.S: return Steps.W
		_:
			printerr("Attempted to turn an invalid direction to the right!")
			return Steps.NA

func turn_direction_left(direction: Steps) -> Steps:
	match direction:
		Steps.R: return Steps.F
		Steps.F: return Steps.L
		Steps.E: return Steps.N
		Steps.N: return Steps.W
		Steps.W: return Steps.S
		Steps.S: return Steps.E
		_:
			printerr("Attempted to turn an invalid direction to the left!")
			return Steps.NA
