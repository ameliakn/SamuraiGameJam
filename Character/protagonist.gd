extends CharacterBody2D

@onready var castRight1 = $CastRight1
@onready var castRight2 = $CastRight2
@onready var castLeft1 = $CastLeft1
@onready var castLeft2 = $CastLeft2
@onready var text = $TextEdit
@onready var StateM = $PlayerSM

@export var MAX_SPEED = 1500.0
@export var BASE_ACCELERATION = 20
@export var MIN_JUMP_ACCELERATION = 120
@export var BASE_DEACCELERATION = 40
@export var JUMP_VELOCITY = -600.0
@export var INITALPOSITION = Vector2(239, 562)
@export var gravity = 900
@export var MIN_WALLJUMP = 50
@export var WalljumpHeight = -200
var leftCollide: bool
var rightCollide: bool
var momentum: float
var jumpStartup: float
var hInputDirection = 0
var hTurnDirection = 0

func _handle_move_input():
	hInputDirection = Input.get_axis("dir_left", "dir_right") 
	
	if(is_on_floor()):
		if(hInputDirection > 0 and velocity.x >= 0 and !rightCollide):
			accelerate(1)
		if(hInputDirection > 0 and velocity.x < 0):
			deaccelerate(1)
		if(hInputDirection < 0 and velocity.x <= 0 and !leftCollide):
			accelerate(-1)
		if(hInputDirection < 0 and velocity.x > 0):
			deaccelerate(-1)
		
		if(hInputDirection == 0 and momentum != 0):
			if(momentum > 0):
				deaccelerate(1)
			else: 
				deaccelerate(-1) 
				
		if(momentum > 0):
			if(rightCollide):
				momentum = 0
			hTurnDirection = 1
		elif(momentum < 0):
			if(leftCollide):
				momentum = 0
			hTurnDirection = -1
		else:
			hTurnDirection = 0
	
func _apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		
func _apply_movement():
	velocity.x = momentum
	move_and_slide()	
	
func accelerate(direction, jump = 0):
	if(direction > 0):
		if(momentum + BASE_ACCELERATION + (jump * MIN_JUMP_ACCELERATION) > MAX_SPEED):
			momentum = MAX_SPEED
		else:
			momentum += BASE_ACCELERATION + (jump * MIN_JUMP_ACCELERATION)
	
	if(direction < 0):
		if(momentum - BASE_ACCELERATION - (jump * MIN_JUMP_ACCELERATION) < -MAX_SPEED):
			momentum = -MAX_SPEED
		else:
			momentum -= (BASE_ACCELERATION + (jump * MIN_JUMP_ACCELERATION))
			
func deaccelerate(direction):
	if(direction > 0):
		if(momentum - BASE_DEACCELERATION < 0):
			momentum = 0
		else:
			momentum -= BASE_DEACCELERATION 
	
	if(direction < 0):
		if(momentum + BASE_DEACCELERATION > 0):
			momentum = 0
		else:
			momentum += BASE_DEACCELERATION
	
func _detect_wall_collision():
	leftCollide = (castLeft1.is_colliding() or castLeft2.is_colliding())
	rightCollide = (castRight1.is_colliding() or castRight2.is_colliding())
	
func wall_jump():
	velocity.y = WalljumpHeight
	if rightCollide:
		momentum = (momentum * -1) - MIN_WALLJUMP
		if momentum < -MAX_SPEED:
			momentum = -MAX_SPEED
	if leftCollide:
		momentum = (momentum * -1) + MIN_WALLJUMP
		if momentum > MAX_SPEED:
			momentum = MAX_SPEED
