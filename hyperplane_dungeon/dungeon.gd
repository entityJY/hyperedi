extends Node2D


@export var tile_resource: PackedScene
@export var player: Player

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
	tile.grid_position = tile_position
	tile.visible = true
	tile.process_mode = Node.PROCESS_MODE_INHERIT
	tile.position = (tile_position - Vector2i(1, 1)) * 135

func enable_neighbor_tiles(tile: Tile):
	var tile_rotation = tile.rotation
	for index in tile.hyperplane_node.neighbors.keys():
		var node = tile.hyperplane_node.neighbors[index]

		var from_index = node.neighbors.find_key(tile.hyperplane_node)
		var neighbor_tile = node.tile

		var final_rotation = wrapf(wrapf(2 + index - from_index, 0, 4) * PI / 2 + tile_rotation, 0, 2*PI)
		neighbor_tile.rotation = final_rotation

		var neighbor_tile_position: Vector2i
		match index:
			0: neighbor_tile_position = Vector2i(wrapi(tile.grid_position.x + 1, 0, 3), tile.grid_position.y)
			1: neighbor_tile_position = Vector2i(tile.grid_position.x, wrapi(tile.grid_position.y - 1, 0, 3))
			2: neighbor_tile_position = Vector2i(wrapi(tile.grid_position.x - 1, 0, 3), tile.grid_position.y)
			3: neighbor_tile_position = Vector2i(tile.grid_position.x, wrapi(tile.grid_position.y + 1, 0, 3))
		
		enable_tile(neighbor_tile, neighbor_tile_position)

func initialize_level() -> void:
	var hyperplane = HyperPlane.new(2)
	for node in hyperplane.cell_hashmap.values():
		var tile: Tile = tile_resource.instantiate()
		add_child(tile)
		tile.visible = false
		tile.process_mode = Node.PROCESS_MODE_DISABLED
		tile.hyperplane_node = node
		node.tile = tile
		tile.body_entered.connect(enable_neighbor_tiles)
	
	var starting_tile: Tile = hyperplane.cell_hashmap.values().pick_random().tile
	enable_tile(starting_tile, Vector2i(1, 1))


func _on_top_down_walls_body_entered(body: Node2D) -> void:
	if body != player:
		return
	body.position.y = -190 * sign(body.position.y)

func _on_left_right_walls_body_entered(body: Node2D) -> void:
	if body != player:
		return
	body.position.x = -190 * sign(body.position.x)
