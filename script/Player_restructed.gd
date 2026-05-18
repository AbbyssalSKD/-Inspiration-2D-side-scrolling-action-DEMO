extends CharacterBody2D

enum STATE {
	floor,
	jump,
	fall,
	attack
	}


#variables & constants
var gravity := ProjectSettings.get("physics/2d/default_gravity") as float 

const run_speed : float = 200.0
const jump_velocity : float = -300.0
const floor_acc : float  = run_speed/0.2
const air_acc : float  = run_speed/0.4
@export var jump_impede = -5

var state : STATE = STATE.floor
var can_double_jump : bool = false
var hold_jump : bool = false
var has_jumped := false
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var coyote_timer: Timer = $CoyoteTimer

#function
func _physics_process(delta: float) -> void:
	
	state = state_control()

	facing_control()

	action_control(delta)
	
	print (coyote_timer.time_left, " ", can_1st_jump(), " ", can_double_jump)
	
func action_control(delta: float) -> void:
	var was_on_floor := is_on_floor()
	var dir := Input.get_axis("left", "right")
	var acc := floor_acc if is_on_floor() else air_acc

	velocity.x =move_toward(velocity.x, dir * run_speed, delta * acc)
	velocity.y += gravity * delta

	match state:
		STATE.floor:
			if velocity.x:
				animation_player.play("run")
			else:
				animation_player.play("idle")
			
			if Input.is_action_just_pressed("jump") and not has_jumped and can_1st_jump():
				hold_jump = true
				can_double_jump = true
				has_jumped = true
				do_jump()
			
		STATE.jump:
			animation_player.play("jump")

			if hold_jump and velocity.y <= jump_impede:
				velocity.y += jump_impede

			if Input.is_action_just_released("jump"):
				hold_jump = false
			
			if Input.is_action_just_pressed("jump") and can_double_jump:
				can_double_jump = false
				do_double_jump()

		STATE.fall:
			animation_player.play("fall")

			if Input.is_action_just_pressed("jump") and has_jumped and can_double_jump:
				can_double_jump = false
				do_double_jump()
			elif Input.is_action_just_pressed("jump") and not has_jumped and coyote_timer.time_left > 0:
				hold_jump = true
				can_double_jump = true
				has_jumped = true
				do_jump()

			if hold_jump and velocity.y <= jump_impede:
				velocity.y += jump_impede

			if Input.is_action_just_released("jump"):
				hold_jump = false

	move_and_slide()
	
	if was_on_floor and !is_on_floor():
		if velocity.y > 0:
			coyote_timer.start()

	elif !was_on_floor and is_on_floor():
		coyote_timer.stop()


func do_double_jump() -> void:
	animation_player.play("jump_up")
	velocity.y = jump_velocity


func do_jump() -> void:
	animation_player.play("jump_up")
	velocity.y = jump_velocity
	coyote_timer.stop()


func can_1st_jump() -> bool:
	return is_on_floor() or coyote_timer.time_left > 0


func state_control() -> STATE:
	match state:
		STATE.floor:
			if not is_on_floor():
				if velocity.y < 0:
					state = STATE.jump
				elif velocity.y > 0:
					can_double_jump = true
					state = STATE.fall

		STATE.jump:
			if velocity.y > 0: 
				state = STATE.fall
		
		STATE.fall:
			if is_on_floor():
				has_jumped = false
				can_double_jump = false
				state = STATE.floor
					 
	return state
			

func facing_control() -> void:
	if velocity.x > 0:
		sprite_2d.flip_h = false
	elif velocity.x < 0:
		sprite_2d.flip_h = true
