extends CharacterBody2D

enum STATE {
	floor,
	jump,
	fall,
	attack
	}
 
enum FACING {
	R,
	L
}

var gravity := ProjectSettings.get("physics/2d/default_gravity") as float 
const run_speed : float = 200.0
const jump_velocity : float = -300.0
const floor_acc : float  = run_speed/0.2
const air_acc : float  = run_speed/0.4
var action_state : STATE = STATE.floor
var facing_state : FACING = FACING.R
var can_double_jump : bool = false
var hold_jump : bool = false
var has_jumped := false
@export var jump_impede = -5

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var coyote_timer: Timer = $CoyoteTimer


func _physics_process(delta: float) -> void:
	
	var was_on_flool := is_on_floor()
	var dir := Input.get_axis("left", "right")
	var acc := floor_acc if is_on_floor() else air_acc	
	velocity.x =move_toward(velocity.x, dir * run_speed, delta * acc)
	velocity.y += gravity * delta
	
	match action_state:
		
		STATE.floor:
			
			if velocity.x:
				animation_player.play("run")
			else:
				animation_player.play("idle")
			
			
			if Input.is_action_just_pressed("jump") and not has_jumped and can_1st_jump():
				do_jump()
			
			if not is_on_floor():
				can_double_jump = true
				action_state = STATE.fall
			
		STATE.jump:
			if hold_jump and velocity.y <= jump_impede:
				velocity.y += jump_impede
			
			if Input.is_action_just_released("jump"):
				hold_jump = false
			
			if Input.is_action_just_pressed("jump") and can_double_jump:
				do_double_jump()

				
			if velocity.y > 0:
				action_state = STATE.fall

				
		STATE.fall:
			animation_player.play("fall")
			
			if not is_on_floor():
				velocity.y += gravity * delta
			else: 
				action_state = STATE.floor
				can_double_jump = false
				has_jumped = false
			
			if Input.is_action_just_pressed("jump") and has_jumped and can_double_jump:
				do_double_jump()
			elif Input.is_action_just_pressed("jump") and not has_jumped and coyote_timer.is_stopped():
				do_jump()	
				
			if hold_jump and velocity.y <= jump_impede:
				velocity.y += jump_impede
				
			
			
			if Input.is_action_just_released("jump"):
				hold_jump = false
				
	match facing_state:
		FACING.R:
			sprite_2d.flip_h = false
		FACING.L:
			sprite_2d.flip_h = true
	
	if velocity.x > 0:
		facing_state = FACING.R
	elif velocity.x < 0:
		facing_state = FACING.L

	# print (Input.is_action_just_pressed("jump"))
	print (can_double_jump, action_state,' ', velocity.y)
	
	move_and_slide()
	
	if is_on_floor() != was_on_flool: 
		if was_on_flool and action_state == STATE.fall:
			coyote_timer.start()
		else:
			coyote_timer.stop()
		

func do_double_jump() -> void:
	animation_player.play("jump_up")
	action_state = STATE.jump
	velocity.y = jump_velocity
	can_double_jump = false

func do_jump() -> void:
	animation_player.play("jump_up")
	velocity.y = jump_velocity
	hold_jump = true
	can_double_jump = true
	action_state = STATE.jump
	coyote_timer.stop()
	has_jumped = true
	
func can_1st_jump() -> bool:
	return is_on_floor() or  coyote_timer.time_left > 0
