class_name WanderEnemyState extends EnemyState

@export var anim_name : String = "walk"
@export var wander_speed : float = 20.0

@export_category("IA")
@export var state_animation_duration : float = 0.5
@export var next_state : EnemyState
@export var state_cycles_min : int = 2
@export var state_cycles_max : int = 4

var _timer : float = 0.0
var _direction : Vector2

## When we initialize this state
func init() -> void:
	pass

## When the enemy enters this state
func enter() -> void:
	_timer = randi_range(state_cycles_min, state_cycles_max) * state_animation_duration
	var rand = randi_range(0, 3)
	_direction = enemy.DIR_4[rand]
	enemy.velocity = _direction * wander_speed
	enemy.set_direction(_direction)
	enemy.update_animation( anim_name)
	pass

## When the enemy leaves this state
func exit() -> void:
	enemy.position = enemy.position.round()
	pass

## During the _process update in this State
func process(_delta: float) -> EnemyState:
	_timer -= _delta
	if _timer <= 0:
		return next_state
	return null

## During the _physics_process update in this State
func physics(_delta: float) -> EnemyState:
	return null
