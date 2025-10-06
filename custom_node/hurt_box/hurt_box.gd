class_name HurtBox extends Area2D

signal damaged( hit_box : HitBox )


func take_damage( hit_box : HitBox ) -> void:
	#print("hurt_box receiving damage: ", self.damaged)
	damaged.emit( hit_box )
