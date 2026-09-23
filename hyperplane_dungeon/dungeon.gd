extends Node2D


@export var tile_resource: PackedScene
@export var player: Player
@export var debug_label: RichTextLabel
@export var compass: Compass
@export var game_complete_text: RichTextLabel
@export var tile_container: Node2D

var depth: int

var loaded_tiles: Dictionary[Vector2i, Tile]

signal game_won()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	depth = SceneTransition.dungeon_depth
	initialize_level()
	debug_label.visible = SceneTransition.debug

func _physics_process(delta: float) -> void:
	tile_container.position += Vector2(player.out_of_bounds_x, player.out_of_bounds_y) * -player.SPEED * delta


func disable_tile(tile: Tile) -> void:
	tile.visible = false
	tile.process_mode = Node.PROCESS_MODE_DISABLED

func enable_tile(tile: Tile, tile_position: Vector2i) -> void:
	var old_tile = loaded_tiles.get(tile_position)
	if is_instance_valid(old_tile):
		disable_tile(old_tile)
	
	loaded_tiles.set(tile_position, tile)

	tile.grid_position = tile_position
	tile.visible = true
	tile.process_mode = Node.PROCESS_MODE_INHERIT
	tile.position = tile_position * 81

	for key in tile.hyperplane_node.reachable_neighbors.keys():
		var wall = tile.walls[key]
		wall.visible = false
		wall.process_mode = Node.PROCESS_MODE_DISABLED

func enable_neighbor_tiles(tile: Tile):

	compass.current_tile = tile
	player.current_tile = tile

	debug_label.text = "Current tile: " + tile.hyperplane_node.get_coordinates_nice() + "\n\n+-+-+-+-+\n\n"
	debug_label.text += "Reachable Neighbors:\n" + tile.hyperplane_node.get_reachable_neighbors_nice() + "\n+-+-+-+-+\n\nReachable Neighbors:\n---------\n"

	var tile_rotation = tile.rotation
	for index in tile.hyperplane_node.reachable_neighbors.keys():
		var node = tile.hyperplane_node.reachable_neighbors[index]

		debug_label.text += node.get_coordinates_nice() + "\n"
		debug_label.text += node.get_reachable_neighbors_nice() + "---------\n"

		var from_index = node.reachable_neighbors.find_key(tile.hyperplane_node)
		var neighbor_tile = node.tile

		var final_rotation_int: int
		match index - from_index:
			-3: final_rotation_int = 1
			-2: final_rotation_int = 0
			-1: final_rotation_int = 3
			0: final_rotation_int = 2
			1: final_rotation_int = 1
			2: final_rotation_int = 0
			3: final_rotation_int = 3

		var final_rotation = wrapf(final_rotation_int * PI / 2 + tile_rotation, 0, 2*PI)
		neighbor_tile.rotation = final_rotation

		var neighbor_tile_position: Vector2i

		index = wrapi(index - int(tile.rotation * 2 / PI), 0, 4)

		match index:
			0: neighbor_tile_position = Vector2i(tile.grid_position.x + 1, tile.grid_position.y)
			1: neighbor_tile_position = Vector2i(tile.grid_position.x, tile.grid_position.y - 1)
			2: neighbor_tile_position = Vector2i(tile.grid_position.x - 1, tile.grid_position.y)
			3: neighbor_tile_position = Vector2i(tile.grid_position.x, tile.grid_position.y + 1)
		
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
		tile_container.add_child(tile)
		tile.visible = false
		tile.process_mode = Node.PROCESS_MODE_DISABLED
		tile.hyperplane_node = node
		node.tile = tile

		tile.debug_label.text = tile.hyperplane_node.get_coordinates_nice()

		tile.body_entered.connect(enable_neighbor_tiles)

		if node.coordinates == [HyperPlane.Steps.C]:
			tile.background.modulate = Color.AQUA
			wait_for_win(tile)
	
	var starting_tile: Tile
	while true:
		starting_tile = hyperplane.cell_hashmap.values().pick_random().tile
		if len(starting_tile.hyperplane_node.coordinates) >= depth: break
	generate_maze(starting_tile.hyperplane_node)
	enable_tile(starting_tile, Vector2i(0, 0))

	SceneTransition.fade_in()


func _on_top_down_walls_body_entered(body: Node2D) -> void:
	if body != player:
		return
	body.position.y = 100 * sign(body.position.y)

func _on_left_right_walls_body_entered(body: Node2D) -> void:
	if body != player:
		return
	body.position.x = 100 * sign(body.position.x)

func wait_for_win(center_tile: Tile) -> void:
	await center_tile.body_entered
	var tween = get_tree().create_tween()
	tween.tween_property(game_complete_text, "position", Vector2(-277, -47.5), 1)
	game_won.emit()


func _on_hyper_plan_renderer_restart_button_pressed() -> void:
	SceneTransition.fade_out()
	await SceneTransition.animation_finished
	get_tree().reload_current_scene()
