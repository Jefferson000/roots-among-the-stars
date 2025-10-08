extends VBoxContainer

const SAVE_SLOT := preload("res://gui/menu/save_slot/save_slot.tscn")
const SAVE_DATA := [
	{"save_id":"slot_1","level_text":"Level 1","time_text":"00:42","description":"Simple description of save on Level 1"},
	{"save_id":"slot_2","level_text":"Level 2","time_text":"01:10","description":"Simple description of save on Level 2"},
]

@onready var description: Label = $"../SaveDescription/Description"
@onready var load_game_button: Button = $"../LoadGame"

var load_buttons_group := ButtonGroup.new()

func _ready() -> void:
	load_game_button.pressed.connect(load_game)
	for i in SAVE_DATA.size():
		create_save_slot(SAVE_DATA[i])

func create_save_slot(data: Dictionary) -> SaveSlot:
	var save_slot: SaveSlot = SAVE_SLOT.instantiate()
	add_child(save_slot)
	save_slot.apply(data)

	save_slot.focus_entered.connect(_on_slot_focus.bind(save_slot))
	return save_slot

func load_game() -> void:
	var focus := get_viewport().gui_get_focus_owner()
	if focus is SaveSlot:
		var save_slot := focus as SaveSlot
		print("starting_game:", save_slot.level_text, ", time: ", save_slot.time_text, ", id: ", save_slot.save_id)
	else:
		print("No focused save slot")

func _on_slot_focus(slot: SaveSlot) -> void:
	description.text = slot.description
