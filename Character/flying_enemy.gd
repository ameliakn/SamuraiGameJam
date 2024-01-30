extends Area2D


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
			self.queue_free()

