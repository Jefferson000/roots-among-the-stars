extends Control

const FIRST_LEVEL := preload("res://levels/environment/grassland/01.tscn")

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var load_button: Button = $MainMenu/VBoxContainer/Load
@onready var back_to_main_menu: Button = $LoadMenu/BackToMainMenu
@onready var new_game_button: Button = $MainMenu/VBoxContainer/New
@onready var quit_button: Button = $MainMenu/VBoxContainer/Quit
@onready var save_slots: VBoxContainer = $LoadMenu/SaveSlots
@onready var confirmation_dialog: ConfirmationDialog = $ConfirmationDialog

func _ready() -> void:
	new_game_button.grab_focus()
	new_game_button.pressed.connect(new_game)
	load_button.pressed.connect(show_load_menu)
	back_to_main_menu.pressed.connect(hide_load_menu)
	quit_button.pressed.connect(_on_quit_pressed)
	confirmation_dialog.confirmed.connect(_on_quit_confirmed)

func new_game() -> void:
	print("starting new game")
	animation_player.play("hide_main_menu")
	await animation_player.animation_finished

	get_tree().change_scene_to_packed(FIRST_LEVEL)

func show_load_menu() -> void:
	if save_slots and save_slots.get_child_count() > 0:
		(save_slots.get_child(0) as Control).grab_focus()
	animation_player.play("hide_main_menu")
	await animation_player.animation_finished
	animation_player.play("show_load_menu")
	await animation_player.animation_finished

func hide_load_menu() -> void:
	new_game_button.grab_focus()
	animation_player.play("hide_load_menu")
	await animation_player.animation_finished
	animation_player.play("show_main_menu")
	await animation_player.animation_finished

func _on_quit_pressed() -> void:
	confirmation_dialog.popup_centered()

func _on_quit_confirmed() -> void:
	if OS.has_feature("web"):
		return
	get_tree().quit()
