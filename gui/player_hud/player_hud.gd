extends CanvasLayer

var hearts: Array[HeartGUI] = []
@onready var root_ctrl: Control = $Control

func _ready() -> void:
	# Gather heart widgets (hidden by default)
	for child in $Control/HeartsHFlowContainer.get_children():
		if child is HeartGUI:
			hearts.append(child)
			child.visible = false

	await get_tree().process_frame
	_attach_to_game_viewport()
	_sync_from_player()  # <- ensure hearts show at boot

	# Track scene changes via SceneTree
	get_tree().node_added.connect(_on_node_added)
	get_tree().node_removed.connect(_on_node_removed)

# ---- Viewport wiring -------------------------------------------------------

func _attach_to_game_viewport() -> void:
	var vp := get_node_or_null("/root/Main/GameContainer/GameViewport")
	if vp and custom_viewport != vp:
		custom_viewport = vp
		root_ctrl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _on_node_added(n: Node) -> void:
	if n.name == "Main":
		_attach_to_game_viewport()
		_sync_from_player()  # <- refresh when main scene comes in

func _on_node_removed(n: Node) -> void:
	if n.name == "Main":
		custom_viewport = null

# ---- Public API used by Player --------------------------------------------

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

# ---- Pull current HP if Player already exists -----------------------------

func _sync_from_player() -> void:
	# If you use a PlayerManager autoload, grab the current values and draw once.
	var pm := get_node_or_null("/root/PlayerManager")
	if pm and "player" in pm and pm.player:
		var p = pm.player
		# Defensive: if your Player fields are named differently, adjust here.
		update_hp(p.hp, p.max_hp)
