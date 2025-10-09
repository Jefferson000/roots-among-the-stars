extends Node2D

func _ready() -> void:
	visible = false
	if not PlayerManager.player_spawned:
		PlayerManager.add_player_instance()
		PlayerManager.set_player_position( global_position )
		PlayerManager.player_spawned = true
