extends Node2D
@onready var audio_death = $audio_death

@export var next_stage_file: String

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
		
func _stage_finish():
	get_tree().change_scene_to_file(next_stage_file)
#
func _on_character_body_2d_player_dead():
	audio_death.play()
