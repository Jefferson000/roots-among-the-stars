extends Node2D

func _input(event):
	if event.is_action_pressed("pause"):
		print("paused")
		get_tree().paused = !get_tree().paused
		if get_tree().paused:
			$UI/PauseMenu.show()
			$UI/HUD.hide()
		else:
			$UI/PauseMenu.hide()
			$UI/HUD.show()
