class_name SceneTransition extends CanvasLayer

@onready var animation_player: AnimationPlayer = $Control/AnimationPlayer

func _ready() -> void:
	Global.scene_transition = self

func fade_out(duration: float = -1.0) -> bool:
	_play_with_duration("fade_out", duration)
	await animation_player.animation_finished
	return true

func fade_in(duration: float = -1.0) -> bool:
	_play_with_duration("fade_in", duration)
	await animation_player.animation_finished
	return true

func _play_with_duration(name: String, duration: float) -> void:
	if duration > 0.0:
		var anim := animation_player.get_animation(name)
		if anim:
			var speed := anim.length / duration
			animation_player.play(name, -1.0, speed)
			return
	# Fallback: normal speed
	animation_player.play(name)
