extends Area2D

var attacked = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_entered(area):
	pass # Replace with function body.


func _on_body_entered(body):
	if body.is_in_group("Character"):
		var enemy_attack = body.enemy_collision()
	
		if enemy_attack:
			collision_layer = 0
			collision_mask = 0
			disable_mode = DISABLE_MODE_REMOVE
			attacked = true
			self.hide()

func respawn_enemy():
	attacked = false
	set_collision_layer_value(3,true)
	set_collision_mask_value(1, true) 
	disable_mode = CollisionObject2D.DISABLE_MODE_MAKE_STATIC
	show()
