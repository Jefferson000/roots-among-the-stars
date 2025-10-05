extends Control

## =======================
##  Config (Inspector)
## =======================

@export_category("Window Defaults")
@export var start_fullscreen: bool = false
@export var default_window_size: Vector2i = Vector2i(1280, 720) # good starting preset
@export var use_borderless_for_presets: bool = true             # exact client sizes for presets

## =======================
##  Virtual Resolution
## =======================

# Base 320×180:
# - 1280×720  → ×4 (perfect fit)
# - 1920×1080 → ×6 (perfect fit)
# - 2560×1440 → ×8 (perfect fit)
const BASE_SIZE: Vector2i = Vector2i(320, 180)

## =======================
##  Node Refs
## =======================

@onready var game_container: SubViewportContainer = $GameContainer
@onready var game_viewport: SubViewport = $GameContainer/GameViewport

## Initializes window, locks SubViewport to the virtual size, applies integer scaling.
func _ready() -> void:
	# Disallow manual resize via OS borders.
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, true)

	if start_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		_apply_window_preset(default_window_size)

	game_viewport.size = BASE_SIZE
	_apply_integer_scale()
	get_viewport().size_changed.connect(_apply_integer_scale)

## Computes the largest integer scale that fits the current client area,
## scales the SubViewportContainer, and centers the gameplay region.
func _apply_integer_scale() -> void:
	var win: Vector2i = get_viewport().get_visible_rect().size
	var base: Vector2 = Vector2(BASE_SIZE)

	var sx: int = int(floor(float(win.x) / base.x))
	var sy: int = int(floor(float(win.y) / base.y))
	var k: int = max(1, min(sx, sy))

	var target: Vector2 = base * float(k)

	game_container.scale = Vector2(k, k)
	game_container.size = base

	var pos: Vector2 = (Vector2(win) - target) * 0.5
	game_container.position = pos.floor()

	print("client_win=", win, " base=", BASE_SIZE, " scale=", k)

## =======================
##  Presets & Hotkeys
## =======================

const RES_720P:  Vector2i = Vector2i(1280, 720)   # ×4 (perfect)
const RES_1080P: Vector2i = Vector2i(1920, 1080)  # ×6 (perfect)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("set_720p"):
		_apply_window_preset(RES_720P)
	elif event.is_action_pressed("set_1080p"):
		_apply_window_preset(RES_1080P)
	elif event.is_action_pressed("toggle_fullscreen"):
		var mode: int = DisplayServer.window_get_mode()
		if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			_apply_window_preset(default_window_size)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

## =======================
##  Window sizing (strictly typed)
## =======================

# Resizes the window to an exact integer multiple of BASE_SIZE that matches the
# requested preset (and fits the work area), centers it, reapplies scaling.
func _apply_window_preset(target_client: Vector2i) -> void:
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		await get_tree().process_frame
		await get_tree().process_frame

	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, use_borderless_for_presets)

	# temp allow resizing so the WM accepts the new size
	var prev_resize_disabled := DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED)
	if prev_resize_disabled:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, false)

	var screen := DisplayServer.window_get_current_screen()
	DisplayServer.window_set_current_screen(screen)
	var work: Rect2i = DisplayServer.screen_get_usable_rect(screen)

	# 1) Integer scale desired by the preset.
	var want_k_x: int = int(floor(float(target_client.x) / float(BASE_SIZE.x)))
	var want_k_y: int = int(floor(float(target_client.y) / float(BASE_SIZE.y)))
	var want_k: int = max(1, min(want_k_x, want_k_y))

	# 2) Integer scale that fits the monitor's usable area.
	var fit_k_x: int = int(floor(float(work.size.x) / float(BASE_SIZE.x)))
	var fit_k_y: int = int(floor(float(work.size.y) / float(BASE_SIZE.y)))
	var fit_k: int = max(1, min(fit_k_x, fit_k_y))

	var k: int = min(want_k, fit_k)

	# 3) Exact client size = BASE_SIZE * k (prevents 1919/1921/1922 side gaps).
	var exact: Vector2i = Vector2i(BASE_SIZE.x * k, BASE_SIZE.y * k)

	# 4) If decorated, add decoration delta so the client stays 'exact'.
	var total_target: Vector2i = exact
	if not use_borderless_for_presets:
		var total: Vector2i = DisplayServer.window_get_size()
		var client: Vector2i = Vector2i(get_viewport().get_visible_rect().size)
		var deco: Vector2i = total - client
		total_target += deco

	# Clamp to usable work area just in case.
	if total_target.x > work.size.x:
		total_target.x = work.size.x
	if total_target.y > work.size.y:
		total_target.y = work.size.y

	DisplayServer.window_set_size(total_target)

	# Center the window.
	var pos: Vector2i = work.position + (work.size - total_target) / 2
	DisplayServer.window_set_position(pos)
	if prev_resize_disabled:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, true)

	_apply_integer_scale()
