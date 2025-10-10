class_name PauseMenu extends CanvasLayer

signal shown
signal hidden

@onready var load_button: Button = $Control/NinePatchRect/HBoxContainer/LoadButton
@onready var save_button: Button = $Control/NinePatchRect/HBoxContainer/SaveButton
@onready var animation_player: AnimationPlayer = $AnimationPlayer
#@onready var item_description: Label = $Control/ItemDescription
#@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var is_paused : bool = false

func _ready() -> void:
	Global.pause_menu = self
	hide_pause_menu()
	save_button.pressed.connect( _on_save_pressed )
	load_button.pressed.connect( _on_load_pressed )

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if is_paused == false:
			#if DialogSystem.is_active:
				#return
			show_pause_menu()
		else:
			hide_pause_menu()
		get_viewport().set_input_as_handled()

func show_pause_menu() -> void:
	get_tree().paused = true
	animation_player.play("show_pause_menu")
	await animation_player.animation_finished
	is_paused = true
	shown.emit()

func hide_pause_menu() -> void:
	get_tree().paused = false
	animation_player.play("hide_pause_menu")
	await animation_player.animation_finished
	is_paused = false
	hidden.emit()

func _on_save_pressed() -> void:
	if not is_paused:
		return
	SaveManager.save_game("slot1")
	hide_pause_menu()


func _on_load_pressed() -> void:
	if not is_paused:
		return
	hide_pause_menu()
	await get_tree().process_frame
	print("trying to load")
	#SaveManager.load_game()
	#await LevelManager.level_load_started
	pass

#func update_item_description( new_text : String ) -> void:
	#item_description.text = new_text
#
#func play_audio( sound : AudioStream  ) -> void:
	#audio_stream_player.stream = sound
	#audio_stream_player.play()
