class_name StunState extends State

@export var knockback_speed: float = 100.0
@export var decelerate_speed: float = 10.0
@export var invulnerable_duration: float = 1.0

var hit_box : HitBox
var direction : Vector2

var next_state : State = null

@onready var idle: State = $"../Idle"
#@onready var death: State = $"../Death" TODO

func init() -> void:
	player.player_damage.connect( _player_damaged )

func enter() -> void:
	player.animation_player.animation_finished.connect( _animation_finished )

	direction = player.global_position.direction_to( hit_box.global_position )
	player.velocity = direction * -knockback_speed
	player.set_direction()
	player.update_animation("stun")

	player.make_invulnerable( invulnerable_duration )
	#PlayerManager.shake_camara( 1.5 )

func exit() -> void:
	next_state = null
	player.animation_player.animation_finished.disconnect( _animation_finished )

func process(_delta: float) -> State:
	player.velocity -= player.velocity * decelerate_speed * _delta
	return next_state

func physics(_delta: float) -> State:
	return null

func handle_input(_event: InputEvent) -> State:
	return null

func _player_damaged( _hit_box : HitBox ) -> void:
	hit_box = _hit_box
	#if state_machine.current_state != death: TODO
		#state_machine.change_state(self)
	state_machine.change_state(self)


func _animation_finished( _a : String ) -> void:
	next_state = idle
	#if player.hp <= 0: TODO
		#next_state = death
