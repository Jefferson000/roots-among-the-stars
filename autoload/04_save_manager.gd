extends Node

const SAVE_PATH := "user://"
const SAVE_EXT := ".sav"

signal game_loaded
signal game_saved

var current_save : Dictionary = {
	scene_path = "",
	player = {
		hp = 1,
		max_hp = 1,
		pos_x = 0,
		pos_y = 0
	},
	items = [],
	persistence = [],
	quests = []
}

# -------------------
# SAVE / LOAD
# -------------------
func save_game(slot_id: String = "default") -> void:
	_update_before_save()
	var file := FileAccess.open(SAVE_PATH + slot_id + SAVE_EXT, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(current_save))
		file.close()
		game_saved.emit()

func load_game(slot_id: String = "default") -> void:
	var file := FileAccess.open(SAVE_PATH + slot_id + SAVE_EXT, FileAccess.READ)
	if not file:
		push_error("Save file not found: " + slot_id)
		return

	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		push_error("Failed to parse save file: " + slot_id)
		return

	current_save = json.get_data() as Dictionary

	Global.game_manager.change_world_scene(current_save.scene_path, "", Vector2.ZERO)
	await LevelManager.level_load_started

	PlayerManager.set_player_position(Vector2(current_save.player.pos_x, current_save.player.pos_y))
	PlayerManager.set_health(int(current_save.player.hp), int(current_save.player.max_hp))
	PlayerManager.INVENTORY_DATA.parse_save_data(current_save.items)

	await LevelManager.level_loaded
	game_loaded.emit()

# -------------------
# SLOT MANAGEMENT
# -------------------
func list_saves() -> Array:
	var slots: Array = []
	var dir := DirAccess.open(SAVE_PATH)
	if dir:
		for file_name in dir.get_files():
			if file_name.ends_with(SAVE_EXT):
				# strip extension
				var slot_id := file_name.substr(0, file_name.length() - SAVE_EXT.length())
				slots.append(slot_id)
	return slots

func delete_save(slot_id: String) -> void:
	var path := SAVE_PATH + slot_id + SAVE_EXT
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)

func overwrite_save(slot_id: String) -> void:
	# just call save_game with the same slot_id
	save_game(slot_id)

# -------------------
# HELPERS
# -------------------
func _update_before_save() -> void:
	update_player_data()
	update_scene_path()
	update_item_data()

func update_player_data() -> void:
	var p: Player = PlayerManager.player
	current_save.player.hp = p.hp
	current_save.player.max_hp = p.max_hp
	current_save.player.pos_x = p.global_position.x
	current_save.player.pos_y = p.global_position.y

func update_scene_path() -> void:
	current_save.scene_path = Global.game_manager.current_world_scene.scene_file_path

func update_item_data() -> void:
	# current_save.items = PlayerManager.INVENTORY_DATA.get_save_data()
	pass

func add_persistent_value(value: String) -> void:
	if not check_persistent_value(value):
		current_save.persistence.append(value)

func check_persistent_value(value: String) -> bool:
	return current_save.persistence.has(value)
