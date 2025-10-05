# Camera2D.gd
extends Camera2D
func _process(_dt: float) -> void:
	global_position = global_position.round()  # whole pixels = no shimmer
