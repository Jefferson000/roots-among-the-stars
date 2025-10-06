# res://autoload/DevWindow.gd
extends Node

@export var base_virtual_size: Vector2i = Vector2i(320, 180)
@export var dev_window_size: Vector2i = Vector2i(1280, 720)
@export var dev_fullscreen: bool = false
@export var dev_borderless: bool = true
@export var lock_resize: bool = true

# Add this group on scenes that already manage scaling (e.g., your Main)
const OPT_OUT_GROUP := "uses_custom_scaler"

func _ready() -> void:
	if not OS.is_debug_build():
		return

	# Nice editor window size/shape for both F5/F6
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, dev_borderless)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, lock_resize)
	DisplayServer.window_set_size(dev_window_size)
	get_window().move_to_center()

	# Wait a frame so current_scene is set
	await get_tree().process_frame
	var scene := get_tree().current_scene
	if scene == null:
		return

	# If the current scene is the project's main_scene, it's an F5 run -> do nothing.
	var main_path: String = str(ProjectSettings.get_setting("application/run/main_scene"))
	var scene_path: String = scene.scene_file_path  # Godot 4 property
	if scene_path == main_path:
		return

	# If this scene opts out or already has a SubViewport scaler, skip as well.
	if scene.is_in_group(OPT_OUT_GROUP) or _scene_has_subviewport(scene):
		return

	# F6 run of a regular scene: apply dev-only virtual resolution
	var win: Window = get_window()
	win.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	win.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	win.content_scale_size = base_virtual_size

func _scene_has_subviewport(root: Node) -> bool:
	for child in root.get_children():
		if child is SubViewport:
			return true
		if _scene_has_subviewport(child):
			return true
	return false
