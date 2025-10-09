class_name PlayerHud extends CanvasLayer


var hearts: Array[HeartGUI] = []

func _ready():
	Global.player_hud = self
	for child in $Control/HeartsHFlowContainer.get_children():
		if child is HeartGUI:
			hearts.append(child)
			child.visible = false

func update_hp(hp:int, max_hp:int) -> void:
	update_max_hp(max_hp)
	var heart_count := int(ceil(max_hp / 2.0))
	for i in heart_count:
		update_heart(i, hp)

func update_heart(index:int, hp:int) -> void:
	if index >= hearts.size():
		return
	var value := clampi(hp - index * 2, 0, 2)
	hearts[index].value = value

func update_max_hp(max_hp:int) -> void:
	var heart_count := int(ceil(max_hp / 2.0))
	for i in hearts.size():
		hearts[i].visible = i < heart_count
