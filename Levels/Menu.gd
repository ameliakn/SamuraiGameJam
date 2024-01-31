extends CanvasLayer
@onready var confirm_sound = $confirm_sound
@onready var quit_sound = $quit_sound


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_game_pressed():
	confirm_sound.play()
	get_tree().change_scene_to_file('res://Levels/fase_1.tscn')


func _on_quit_game_pressed():
	quit_sound.play()
	get_tree().quit()
