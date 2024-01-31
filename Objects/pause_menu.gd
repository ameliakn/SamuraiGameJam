extends CanvasLayer
@onready var confirm_sound = $confirm_sound
@onready var quit_sound = $quit_sound


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("pause"):
		toggle_pause()

func _on_quit_pressed():
	quit_sound.play()
	get_tree().quit()

func _on_resume_pressed():
	toggle_pause()

func toggle_pause():
	confirm_sound.play()
	visible = !visible
	get_tree().paused = !get_tree().paused


func _on_title_pressed():
	quit_sound.play()
	get_tree().change_scene_to_file('res://Levels/Menu.tscn')
