class_name DestroyEnemyState extends EnemyState

#const PICKUP = preload("item_") #TODO

@export var anim_name : String = "destroy"
@export var knockback_speed : float = 150.0
@export var decelerate_speed : float = 10.0

@export_category("IA")

@export_category("Item Drops")
@export var drops : Array[ DropData ]


var _direction : Vector2
var _damage_position : Vector2

## When we initialize this state
func init() -> void:
	enemy.enemy_destroyed.connect(_on_enemy_destroyed)

## When the enemy enters this state
func enter() -> void:
	enemy.invulnerable = true

	_direction = enemy.global_position.direction_to( enemy.player.global_position )

	enemy.set_direction(_direction)
	enemy.velocity = _direction * -knockback_speed

	enemy.update_animation( anim_name )
	enemy.animation_player.animation_finished.connect( _on_animation_finished )
	disable_hit_box()
	#drop_items() TODO

## When the enemy leaves this state
func exit() -> void:
	enemy.invulnerable = false
	enemy.animation_player.animation_finished.disconnect( _on_animation_finished )

## During the _process update in this State
func process(_delta: float) -> EnemyState:
	enemy.velocity -= enemy.velocity * decelerate_speed * _delta
	return null

## During the _physics_process update in this State
func physics(_delta: float) -> EnemyState:
	return null

func _on_enemy_destroyed( hit_box : HitBox ) -> void:
	_damage_position = hit_box.global_position
	state_machine.change_state(self)

func _on_animation_finished( _a : String) -> void:
	enemy.queue_free()

func disable_hit_box() -> void:
	var hit_box : HitBox = enemy.get_node_or_null("HitBox")
	if hit_box:
		hit_box.monitoring = false

# TODO
#func drop_items() -> void:
	#if drops.size() == 0:
		#return
#
	#for i in drops.size():
		#if drops[ i ] == null or drops[ i ].item == null:
			#continue
		#var drop_count : int = drops[ i ].get_drop_count()
		#for j in drop_count:
			#var drop : ItemPickup = PICKUP.instantiate() as ItemPickup
			#drop.item_data = drops[ i ].item
			#enemy.get_parent().call_deferred( "add_child", drop )
			#drop.global_position = enemy.global_position
			#drop.velocity = 0.5 * enemy.velocity.rotated( randf_range( -1.5, 1.5 ) ) * randf_range( 0.9 , 1.5 )
