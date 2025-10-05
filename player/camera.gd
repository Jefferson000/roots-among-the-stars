# Camera2D.gd
extends Camera2D
func _process(_dt):
	global_position = global_position.round()
