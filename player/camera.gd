class_name PlayerCamera extends Camera2D

func _ready() -> void:
	LevelManager.tile_map_bounds_changed.connect(update_limits)
	update_limits(LevelManager.current_tilemap_bounds)
	#PlayerManager.camera_shook.connect( add_camara_shake ) TODO
	pass

# TODO
#func _physics_process(delta: float) -> void:
	#if shake_trauma > 0:
		#shake_trauma = max( shake_trauma - shake_decay * delta, 0 )
		#shake()
#
#func shake() -> void:
	#var amount : float = pow( shake_trauma * shake_power, 2 )
	#offset = Vector2( randf_range( -1, 1), randf_range( -1, 1) ) * shake_max_offset * amount
#
#func add_camara_shake( value : float ) -> void:
	#shake_trauma = value
	pass

func _process(_dt: float) -> void:
	global_position = global_position.round()  # whole pixels = no shimmer

func update_limits(bounds: Array[Vector2]) -> void:
	if bounds == []:
		return
	limit_left = int(bounds[0].x)
	limit_top = int(bounds[0].y)
	limit_right = int(bounds[1].x)
	limit_bottom = int(bounds[1].y)
