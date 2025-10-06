class_name LevelTileSet extends TileMapLayer

@export var tile_size : float = 16

func _ready() -> void:
	LevelManager.change_tile_map_bounds(get_tile_map_bounds())

func get_tile_map_bounds() -> Array[Vector2]:
	var bounds : Array[Vector2] =[]
	bounds.append(
		Vector2( get_used_rect().position * tile_size ) + position
	)
	bounds.append(
		Vector2( get_used_rect().end * tile_size ) + position
	)
	return bounds
