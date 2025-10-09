class_name SaveSlot
extends Button


var time_text: String:
	set = set_time_text, get = get_time_text
var level_text: String:
	set = set_level_text, get = get_level_text

var _time_text : String
var _level_text : String
var save_id: String
var description: String

@onready var time: Label  = $VBoxContainer/Time
@onready var level: Label = $VBoxContainer/Level

func set_time_text(value: String) -> void:
	_time_text = value
	if is_instance_valid(time):
		time.text = value

func get_time_text() -> String:
	return _time_text

func set_level_text(value: String) -> void:
	_level_text = value
	if is_instance_valid(level):
		level.text = value

func get_level_text() -> String:
	return _level_text

func apply(data: Dictionary) -> SaveSlot:
	if data.has("level_text"): level_text = data.level_text
	if data.has("time_text"):  time_text  = data.time_text
	if data.has("description"): description = data.description
	if data.has("save_id"):    save_id    = data.save_id
	return self
