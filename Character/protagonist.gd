extends CharacterBody2D

signal floor_hit()

@onready var castRight1 = $CastRight1
@onready var castRight2 = $CastRight2
@onready var castLeft1 = $CastLeft1
@onready var castLeft2 = $CastLeft2
@onready var text = $TextEdit
@onready var StateM = $PlayerSM
@onready var dash_range = $dash_range
@onready var ground_recovery_timer = $GroundRecoveryTimer
@onready var animation_sheet = $AnimatedSprite2D


@export var MAX_SPEED = 1500.0
@export var BASE_ACCELERATION = 20
@export var MIN_JUMP_ACCELERATION = 120
@export var BASE_DEACCELERATION = 40
@export var JUMP_VELOCITY = -600.0
@export var INITALPOSITION = Vector2(239, 562)
@export var GROUND_PUND = 2000
@export var gravity = 900
@export var MIN_WALLJUMP = 50
@export var WalljumpHeight = -200
@export var DASH_SPEED = 1800
@export var DASH_DISTANCE = 100
@export var GROUND_RECOVERY_TIME = 0.1

var leftCollide: bool
var rightCollide: bool
var momentum: float
var jumpStartup: float
var hInputDirection = 0
var hTurnDirection = 0
var isGroundAttacking = false
var isDashing = false
var dashingPosition = Vector2(0,0)
var closestEnemy = Area2D

func _process(delta):
	
	if is_on_floor():
		floor_hit.emit()

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
	if not is_on_floor() and !isDashing:
		velocity.y += gravity * delta
		
func _apply_movement():
	if(isDashing):
		if(is_position_reached(dashingPosition)):
			isDashing = false
	
	if(!isDashing and !isGroundAttacking):
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
			
func get_closest_enemy() -> Area2D:
	var enemies = dash_range.get_overlapping_areas()
	if(enemies):
		var closest_distance = 0
		var closest_enemy = null
		for enemy in enemies:
			var distance = position.distance_to(enemy.position)
			if closest_distance == 0 or distance < closest_distance:
				closest_distance = distance
				closest_enemy = enemy
		return closest_enemy
	else:
		return null
	
func dash_to(enemy: Area2D):
	isDashing = true
	var direction = position.direction_to(enemy.position)
	if((direction.x < 0 and momentum > 0) or (direction.x > 0 and momentum < 0)):
		momentum = momentum * -1
	var afterMovement = direction * DASH_DISTANCE
	var newPosition = enemy.position + afterMovement
	dashingPosition = newPosition
	velocity = direction * DASH_SPEED
	
func is_position_reached(target_position):
	if(velocity.x >= 0):
		if velocity.y >= 0:
			if(position.x >= target_position.x and position.y >= target_position.y):
				return true
			else:
				return false
		else:
			if(position.x >= target_position.x and position.y < target_position.y):
				return true
			else:
				return false
	else:
		if velocity.y >= 0:
			if(position.x < target_position.x and position.y >= target_position.y):
				return true
			else:
				return false
		else:
			if(position.x < target_position.x and position.y < target_position.y):
				return true
			else:
				return false
	
func ground_attack():
	velocity.y = GROUND_PUND
	velocity.x = 0
	isGroundAttacking = true

func enemy_collision():
	if(isDashing or isGroundAttacking):
#		if(isDashing):
#			isDashing = false
		return true
	else:
		death()
		return false
	
func death():
	self.queue_free()


func _on_ground_recovery_timer_timeout():
	isGroundAttacking = false
