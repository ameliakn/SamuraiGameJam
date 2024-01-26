extends StateMachine

func _ready():
	add_state("Idle")
	add_state("Run")
	add_state("Turn")
	add_state("Break")
	add_state("Jump")
	add_state("WallSlide")
	add_state("WallJump")
	add_state("Fall")
	call_deferred("set_state", states.Idle)
		
func _input(event):
	if [states.Idle,states.Run,states.Break].has(state):
		if event.is_action("jump") and parent.is_on_floor():
			parent.velocity.y = parent.JUMP_VELOCITY
			if(parent.hInputDirection > 0):
				parent.accelerate(1, 1)
			elif(parent.hInputDirection < 0):
				parent.accelerate(-1, 1)
			
	if Input.is_action_just_pressed("reset"):
		parent.velocity = Vector2(0,0)
		parent.position = parent.INITALPOSITION
		set_state(states.Idle)

func _state_logic(delta):
	parent._detect_wall_collision()
	parent._handle_move_input()
	parent._apply_gravity(delta)
	parent._apply_movement()

func _get_transition(delta):
	match state:
		states.Idle:
			if parent.velocity.x != 0:
				return states.Run
			if parent.velocity.y != 0:
				return states.Jump
		states.Run:
			if parent.velocity.x == 0:
				return states.Idle
			if parent.velocity.x != 0 and parent.hTurnDirection != parent.hInputDirection:
				return states.Break
			if parent.velocity.y != 0:
				return states.Jump
		states.Break:
			if parent.velocity.x == 0:
				return states.Idle
			if parent.velocity.y != 0:
				return states.Jump
		states.Jump:
			if parent.velocity.y > 0:
				return states.Fall
		states.Fall:
			if parent.is_on_floor():
				return states.Idle

func _enter_state(new_state, old_state):
	parent.text.text = states.find_key(new_state)
	
func _exit_state(old_state, new_state):
	pass
