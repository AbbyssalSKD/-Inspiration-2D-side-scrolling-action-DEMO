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
var run_speed : float = 200.0
var jump_velocity : float = -400.0

var action_state : STATE = STATE.floor
var facing_state : FACING = FACING.R
var can_double_jump : bool = false
var hold_jump : bool = false
@export var jump_impede = -5

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _physics_process(delta: float) -> void:
	
	var dir := Input.get_axis("left", "right")
	velocity.x =dir * run_speed
	velocity.y += gravity * delta
	
	match action_state:
		
		STATE.floor:
			
			if velocity.x:
				animation_player.play("run")
			else:
				animation_player.play("idle")
			
			
			if Input.is_action_just_pressed("jump"):
				animation_player.play("jump_up")
				velocity.y = jump_velocity
				hold_jump = true
				can_double_jump = true
				action_state = STATE.jump
			
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

			if is_on_floor(): 
				action_state = STATE.floor
				can_double_jump = false
			
			if Input.is_action_just_pressed("jump") and can_double_jump:
				do_double_jump()
				
			if hold_jump and velocity.y <= jump_impede:
				velocity.y += jump_impede
	
		
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

func do_double_jump() -> void:
	animation_player.play("jump_up")
	action_state = STATE.jump
	velocity.y = jump_velocity
	can_double_jump = false
