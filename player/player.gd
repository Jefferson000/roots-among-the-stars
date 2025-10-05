class_name Player extends CharacterBody2D

const DIR_4: Array[Vector2] = [
	Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP
]
const FACE_BIAS := 0.10

var cardinal_direction : Vector2 = Vector2.DOWN
var direction : Vector2 = Vector2.ZERO

@onready var sprite : Sprite2D = $Sprite2D
@onready var state_machine : PlayerStateMachine = $StateMachine
@onready var animation_player : AnimationPlayer = $AnimationPlayer


signal direction_changed( new_direction: Vector2 )

var invulnerable : bool = false
var hp : int = 6
var max_hp : int = 6

func _ready() -> void:
	PlayerManager.player = self
	state_machine.initialize(self)

func _process(_delta: float) -> void:
	direction = Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	).normalized()

func _physics_process(_delta: float) -> void:
	move_and_slide()
	global_position = global_position.round()  # <- snap AFTER moving

#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action("test"):
#
		### Auto Kill Test
		##update_hp(-99)
		##player_damage.emit( %AttackHurtBox )
#
		### Camara Test
		##PlayerManager.shake_camara()
#
		#pass

func set_direction() -> bool:
	if direction == Vector2.ZERO:
		return false

	var d := (direction + cardinal_direction * FACE_BIAS).normalized()

	var best_i := 0
	var best_dot := -INF
	for i in DIR_4.size():
		var dot := d.dot(DIR_4[i])
		if dot > best_dot:
			best_dot = dot
			best_i = i

	var new_dir: Vector2 = DIR_4[best_i]  # or := if DIR_4 is typed

	if new_dir == cardinal_direction:
		return false

	cardinal_direction = new_dir
	direction_changed.emit(new_dir)
	sprite.scale.x = -1 if new_dir == Vector2.LEFT else 1
	return true

func update_animation(state: String) -> void:
	var animation : String = state + "/" + anim_direction()
	#print( animation )
	animation_player.play( animation )

func anim_direction() -> String:
	if cardinal_direction == Vector2.DOWN:
		return "down"
	elif cardinal_direction == Vector2.UP:
		return "up"
	else:
		return "side"
