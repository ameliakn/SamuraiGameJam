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
	add_state("GroundRecovery")
	call_deferred("set_state", states.Idle)
		
func _input(event):
	if [states.Idle,states.Run,states.Break].has(state):
		if Input.is_action_just_pressed("jump") and parent.is_on_floor():
			parent.audio_jump.play()
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
				parent.ground_recovery_timer.start(parent.GROUND_RECOVERY_TIME)
				return states.GroundRecovery
		states.GroundRecovery:
			if(!parent.isGroundAttacking):
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
	match new_state:
		states.Idle:
			parent.animation_sheet.play('Idle')
		states.Run:
			parent.animation_sheet.play('Run')
		states.Break:
			parent.animation_sheet.play('Walk')
		states.Jump:
			parent.animation_sheet.play('Jump')
		states.Fall:
			parent.animation_sheet.play('Jump')
		states.WallSlide:
			parent.animation_sheet.play('WallSlide')	
		states.WallJump:
			parent.animation_sheet.play('Jump')
		states.GroundPound:
			parent.audio_groundattack.play()
			parent.animation_sheet.play('GroundAtack')
		states.Dash:
			parent.audio_dash.play()
			parent.animation_sheet.play('Dash')
			
	if parent.velocity.x < 0 and !parent.animation_sheet.flip_h:
		parent.animation_sheet.flip_h = true
	
	if parent. velocity.x > 0 and parent.animation_sheet.flip_h:
		parent.animation_sheet.flip_h = false
	
func _exit_state(old_state, new_state):
	if [states.Run,states.Break].has(old_state):
		if parent.audio_walk.playing:
			parent.audio_walk.stop()
