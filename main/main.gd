extends Control

@export_category("Window Defaults")
@export var start_fullscreen: bool = false
@export var default_window_size: Vector2i = Vector2i(1280, 720)
@export var use_borderless_for_presets: bool = true

const BASE: Vector2i = Vector2i(320, 180)
const RES_720P:  Vector2i = Vector2i(1280, 720)
const RES_1080P: Vector2i = Vector2i(1920, 1080)

@onready var game_container: SubViewportContainer = $GameContainer
@onready var game_viewport: SubViewport = $GameContainer/GameViewport

func _ready() -> void:
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, true)
	if start_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		_apply_window_preset(default_window_size)

	# Lock the virtual size of the gameplay viewport
	game_viewport.size = BASE
	_apply_integer_scale()
	get_viewport().size_changed.connect(_apply_integer_scale)

func _input(e: InputEvent) -> void:
	if e.is_action_pressed("set_720p"):
		_apply_window_preset(RES_720P)
	elif e.is_action_pressed("set_1080p"):
		_apply_window_preset(RES_1080P)
	elif e.is_action_pressed("toggle_fullscreen"):
		var mode: int = DisplayServer.window_get_mode()
		if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			_apply_window_preset(default_window_size)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

# --- Integer scaling & centering of the SubViewportContainer ---
func _apply_integer_scale() -> void:
	var win: Vector2i = get_viewport().get_visible_rect().size
	var bx: float = float(BASE.x)
	var by: float = float(BASE.y)

	var sx: int = int(floor(float(win.x) / bx))
	var sy: int = int(floor(float(win.y) / by))
	var k: int = max(1, min(sx, sy))

	var target: Vector2 = Vector2(bx, by) * float(k)

	game_container.scale = Vector2(k, k)
	game_container.size = Vector2(BASE)     # container’s logical size
	game_container.position = (Vector2(win) - target).floor() * 0.5

# --- Resize the OS window to an exact multiple of BASE (prevents side gaps) ---
func _apply_window_preset(target_client: Vector2i) -> void:
	# Make sure we’re in windowed mode for exact sizing.
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		await get_tree().process_frame
		await get_tree().process_frame

	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, use_borderless_for_presets)

	var was_locked: bool = DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED)
	if was_locked:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, false)

	var screen_idx: int = DisplayServer.window_get_current_screen()
	DisplayServer.window_set_current_screen(screen_idx)
	var work: Rect2i = DisplayServer.screen_get_usable_rect(screen_idx)

	# Desired integer multiple from the preset…
	var want_k_x: int = int(floor(float(target_client.x) / float(BASE.x)))
	var want_k_y: int = int(floor(float(target_client.y) / float(BASE.y)))
	var want_k: int = max(1, min(want_k_x, want_k_y))

	# … and the largest that fits on the screen.
	var fit_k_x: int = int(floor(float(work.size.x) / float(BASE.x)))
	var fit_k_y: int = int(floor(float(work.size.y) / float(BASE.y)))
	var fit_k: int = max(1, min(fit_k_x, fit_k_y))

	var k: int = min(want_k, fit_k)
	var exact_client: Vector2i = BASE * k

	# If decorated, add the decoration delta so the *client* remains exact.
	var total_target: Vector2i = exact_client
	if not use_borderless_for_presets:
		var total_now: Vector2i = DisplayServer.window_get_size()
		var client_now: Vector2i = Vector2i(get_viewport().get_visible_rect().size)
		var deco: Vector2i = total_now - client_now
		total_target += deco

	# Clamp to work area (belt-and-suspenders).
	total_target.x = min(total_target.x, work.size.x)
	total_target.y = min(total_target.y, work.size.y)

	DisplayServer.window_set_size(total_target)
	DisplayServer.window_set_position(work.position + (work.size - total_target) / 2)

	if was_locked:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, true)

	_apply_integer_scale()
