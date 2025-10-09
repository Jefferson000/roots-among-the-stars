class_name GameManager extends Node

@export var world : Node2D
@export var gui : Control

var current_world_scene : Node
var current_gui_scene : Control

var overlay_stack: Array[Node] = []

func _ready() -> void:
	Global.game_manager = self
	current_gui_scene = $GUI/MainMenu
	current_world_scene = $World/DummyLevel

# ---------  UI Manager ---------
func change_gui_scene(new_scene: String, delete: bool = true, keep_running: bool = false) -> void:
	if current_gui_scene != null:
		if delete:
			current_gui_scene.queue_free() # Removes node entirely
		elif keep_running:
			current_gui_scene.visible = false # Keeps in memory and running
		else:
			gui.remove_child(current_gui_scene) # Keeps in memory, does not run
	var new = load(new_scene).instantiate()
	gui.add_child(new)
	current_gui_scene = new

# ---------  World Manager ---------
func change_world_scene(new_scene: String,
	_target_transition : String = "",
	_position_offset : Vector2 = Vector2.ZERO,
	delete: bool = true,
	keep_running: bool = false
	) -> void:
	if current_gui_scene != null:
		if delete:
			current_world_scene.queue_free() # Removes node entirely
		elif keep_running:
			current_world_scene.visible = false # Keeps in memory and running
		else:
			gui.remove_child(current_world_scene) # Keeps in memory, does not run
	#await SceneTransition.fade_out()
	var new : Level = await LevelManager.load_new_level(new_scene, _target_transition, _position_offset)
	#await SceneTransition.fade_in()
	world.add_child(new)
	current_world_scene = new
