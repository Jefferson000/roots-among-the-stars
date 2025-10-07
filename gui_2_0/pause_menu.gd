extends Control

@onready var resume_button = $VBoxContainer/ResumeButton
@onready var quit_button = $VBoxContainer/QuitButton

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	resume_button.pressed.connect(_on_resume_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	setup_pixel_buttons()
	hide()

func setup_pixel_buttons():
	var buttons = [resume_button, quit_button]
	for button in buttons:
		button.add_theme_font_size_override("font_size", 16)

func _on_resume_pressed():
	print("resume pressed")
	get_tree().paused = false
	hide()
	# Force the HUD to show
	get_parent().show()

func _on_quit_pressed():
	print("quit pressed")
	get_tree().paused = false
	#SceneManager.load_menu()

# Add this function to properly show the menu
func show_menu():
	show()
	# Ensure buttons are visible and interactive
	resume_button.disabled = false
	quit_button.disabled = false
