extends Node

const BASE_WIDTH = 320
const BASE_HEIGHT = 180

func _ready():
	get_tree().root.size_changed.connect(_on_window_resized)
	center_window()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("set_1080p"):
		set_1080p()
	elif event.is_action_pressed("set_720p"):
		set_720p()

func set_720p():
	get_window().mode = Window.MODE_WINDOWED
	get_window().size = Vector2i(1280, 720)
	center_window()

func set_1080p():
	get_window().mode = Window.MODE_WINDOWED
	get_window().size = Vector2i(1920, 1080)
	center_window()

func center_window():
	await get_tree().process_frame
	var screen_size = DisplayServer.screen_get_size()
	var window_size = get_window().size
	get_window().position = (screen_size - window_size) / 2

func _on_window_resized():
	# With ViewportContainer, scaling is handled automatically
	pass
