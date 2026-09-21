extends Node2D


@export var tile_resource: PackedScene
@export var player: Player
@export var debug_label: RichTextLabel

@export var depth: int = 2

var loaded_tiles: Array[Array] = [
	[null, null, null],
	[null, null, null],
	[null, null, null]
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initialize_level()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func disable_tile(tile: Tile) -> void:
	if !is_instance_valid(tile):
		return
	tile.visible = false
	tile.process_mode = Node.PROCESS_MODE_DISABLED
	loaded_tiles[tile.grid_position.x][tile.grid_position.y] = null

func enable_tile(tile: Tile, tile_position: Vector2i) -> void:
	disable_tile(loaded_tiles[tile_position.x][tile_position.y])
	loaded_tiles[tile_position.x][tile_position.y] = tile

	tile.grid_position = tile_position
	tile.visible = true
	tile.process_mode = Node.PROCESS_MODE_INHERIT
	tile.position = (tile_position - Vector2i(1, 1)) * 135

	for key in tile.hyperplane_node.reachable_neighbors.keys():
		var wall = tile.walls[key]
		wall.visible = false
		wall.process_mode = Node.PROCESS_MODE_DISABLED

func enable_neighbor_tiles(tile: Tile):

	debug_label.text = "Current tile: " + tile.hyperplane_node.get_coordinates_nice() + "\n\n+-+-+-+-+\n\n"
	debug_label.text += "Reachable Neighbors:\n" + tile.hyperplane_node.get_neighbors_nice() + "\n+-+-+-+-+\n\nReachable Neighbors:\n---------\n"

	var tile_rotation = tile.rotation
	for index in tile.hyperplane_node.reachable_neighbors.keys():
		var node = tile.hyperplane_node.reachable_neighbors[index]

		debug_label.text += node.get_coordinates_nice() + "\n"
		debug_label.text += node.get_neighbors_nice() + "---------\n"

		var from_index = node.reachable_neighbors.find_key(tile.hyperplane_node)
		var neighbor_tile = node.tile

		var final_rotation_int: int
		match index - from_index:
			-2: final_rotation_int = 0
			-1: final_rotation_int = 3
			0: final_rotation_int = 2
			1: final_rotation_int = 1
			2: final_rotation_int = 0

		var final_rotation = wrapf(final_rotation_int * PI / 2 + tile_rotation, 0, 2*PI)
		neighbor_tile.rotation = final_rotation

		var neighbor_tile_position: Vector2i

		index = wrapi(index - int(tile.rotation * 2 / PI), 0, 4)

		match index:
			0: neighbor_tile_position = Vector2i(wrapi(tile.grid_position.x + 1, 0, 3), tile.grid_position.y)
			1: neighbor_tile_position = Vector2i(tile.grid_position.x, wrapi(tile.grid_position.y - 1, 0, 3))
			2: neighbor_tile_position = Vector2i(wrapi(tile.grid_position.x - 1, 0, 3), tile.grid_position.y)
			3: neighbor_tile_position = Vector2i(tile.grid_position.x, wrapi(tile.grid_position.y + 1, 0, 3))
		
		enable_tile(neighbor_tile, neighbor_tile_position)

func generate_maze(node: HyperPlaneNode) -> void:
	
	var explore_stack: Array[HyperPlaneNode] = []
	explore_stack.push_back(node)
	node.explored = true

	var rng = RandomNumberGenerator.new()

	while true:
		var filtered_nodes = node.neighbors.values().filter(
			func(neighbor): return neighbor != explore_stack[-1] and neighbor.explored == false
		)

		if rng.randf() > .6:
			var neighbor_node = node.neighbors.values().pick_random()
			node.reachable_neighbors[node.neighbors.find_key(neighbor_node)] = neighbor_node
			neighbor_node.reachable_neighbors[neighbor_node.neighbors.find_key(node)] = node

		if !filtered_nodes.is_empty():
			var neighbor_node = filtered_nodes.pick_random()
			node.reachable_neighbors[node.neighbors.find_key(neighbor_node)] = neighbor_node
			neighbor_node.reachable_neighbors[neighbor_node.neighbors.find_key(node)] = node

			node = neighbor_node
			explore_stack.push_back(node)
			node.explored = true
		else:
			explore_stack.pop_back()
			if explore_stack.is_empty():
				break
			node = explore_stack[-1]
			
func initialize_level() -> void:
	var hyperplane = HyperPlane.new(depth)
	for node in hyperplane.cell_hashmap.values():
		var tile: Tile = tile_resource.instantiate()
		add_child(tile)
		tile.visible = false
		tile.process_mode = Node.PROCESS_MODE_DISABLED
		tile.hyperplane_node = node
		node.tile = tile

		tile.label.text = tile.hyperplane_node.get_coordinates_nice()

		tile.body_entered.connect(enable_neighbor_tiles)
	
	var starting_tile: Tile
	while true:
		starting_tile = hyperplane.cell_hashmap.values().pick_random().tile
		if len(starting_tile.hyperplane_node.coordinates) >= depth: break
	generate_maze(starting_tile.hyperplane_node)
	enable_tile(starting_tile, Vector2i(1, 1))


func _on_top_down_walls_body_entered(body: Node2D) -> void:
	if body != player:
		return
	body.position.y = -185 * sign(body.position.y)

func _on_left_right_walls_body_entered(body: Node2D) -> void:
	if body != player:
		return
	body.position.x = -185 * sign(body.position.x)
