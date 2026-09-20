extends Node2D


@export var tile_resource: PackedScene
var loaded_tiles: Array[Array] = [
	[null, null, null],
	[null, null, null],
	[null, null, null],
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var hyperplane = HyperPlane.new(2)
	for node in hyperplane.cell_hashmap.values():
		var tile: Tile = tile_resource.instantiate()
		tile.visible = false
		tile.process_mode = Node.PROCESS_MODE_DISABLED
		node.tile = tile
	
	loaded_tiles[1][1] = hyperplane.cell_hashmap.values().pick_random()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
