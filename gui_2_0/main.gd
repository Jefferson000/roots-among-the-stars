extends Node2D

func _input(event):
	if event.is_action_pressed("pause"):
		print("paused")
		get_tree().paused = !get_tree().paused
		if get_tree().paused:
			$SubViewportContainer/UI/PauseMenu.show()
			$SubViewportContainer/UI/HUD.hide()
		else:
			$SubViewportContainer/UI/PauseMenu.hide()
			$SubViewportContainer/UI/HUD.show()
