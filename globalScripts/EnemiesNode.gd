extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_character_body_2d_floor_hit():
	for child in self.get_children():
		if child.attacked:
			child.respawn_enemy()

