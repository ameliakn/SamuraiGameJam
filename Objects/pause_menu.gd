extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("pause"):
		toggle_pause()




func _on_quit_pressed():
	get_tree().quit()


func _on_resume_pressed():
	toggle_pause()

func toggle_pause():
	visible = !visible
	get_tree().paused = !get_tree().paused


func _on_title_pressed():
	get_tree().change_scene_to_file('res://Levels/Menu.tscn')
