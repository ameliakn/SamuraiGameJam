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
	add_state("GroundPound")
	add_state("Dash")
	call_deferred("set_state", states.Idle)
		
func _input(event):
	if [states.Idle,states.Run,states.Break].has(state):
		if Input.is_action_just_pressed("jump") and parent.is_on_floor():
			parent.velocity.y = parent.JUMP_VELOCITY
			if(parent.hInputDirection > 0):
				parent.accelerate(1, 1)
			elif(parent.hInputDirection < 0):
				parent.accelerate(-1, 1)
	if [states.Jump].has(state):
		if(Input.is_action_just_released("jump")):
			parent.velocity.y = 0
	if [states.Jump,states.Fall,states.WallJump].has(state):
		if(parent.rightCollide or parent.leftCollide):
			if(parent.rightCollide):
				parent.deaccelerate(1)
			elif(parent.leftCollide):
				parent.deaccelerate(-1)
		if(Input.is_action_just_pressed("ground_atack")):
			parent.ground_attack()
		if(Input.is_action_just_pressed("dash")):
			var enemy = parent.get_closest_enemy()
			if(enemy):
				parent.dash_to(enemy)
	if [states.WallSlide].has(state):
		if Input.is_action_just_pressed("jump"):
			parent.wall_jump()

func _state_logic(delta):
	parent._detect_wall_collision()
	parent._handle_move_input()
	parent.text.text = str(states.find_key(state), ": ", parent.momentum)
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
			if parent.rightCollide or parent.leftCollide:
				return states.WallSlide
			if parent.velocity.y > 0:
				return states.Fall
			if parent.isGroundAttacking:
				return states.GroundPound
			if parent.isDashing:
				return states.Dash
		states.Fall:
			if parent.is_on_floor():
				return states.Idle
			if parent.rightCollide or parent.leftCollide:
				return states.WallSlide
			if parent.isGroundAttacking:
				return states.GroundPound
			if parent.isDashing:
				return states.Dash
		states.WallSlide:
			if parent.is_on_floor():
				return states.Idle
			if !parent.rightCollide and !parent.leftCollide:
				if parent.velocity.y < 0:
					return states.WallJump
				else:
					return states.Fall
		states.WallJump:
			if parent.rightCollide or parent.leftCollide:
				return states.WallSlide
			if parent.velocity.y > 0:
				return states.Fall
			if parent.isGroundAttacking:
				return states.GroundPound
			if parent.isDashing:
				return states.Dash
		states.GroundPound:
			if parent.is_on_floor():
				parent.isGroundAttacking = false
				return states.Idle
		states.Dash:
			if parent.rightCollide or parent.leftCollide:
				parent.isDashing = false
				return states.WallSlide
			if !parent.isDashing:
				if parent.velocity.y > 0:
					return states.Fall
				else:
					return states.Jump
			if parent.is_on_floor():
				parent.isDashing = false
				return states.Idle
			if parent.is_on_ceiling():
				parent.isDashing = false
				return states.Fall

func _enter_state(new_state, old_state):
	parent.text.text = str(states.find_key(new_state), ": ", parent.momentum)
	
func _exit_state(old_state, new_state):
	pass
