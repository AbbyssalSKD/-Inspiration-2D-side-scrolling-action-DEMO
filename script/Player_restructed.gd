extends CharacterBody2D

enum STATE {
	floor,
	jump,
	fall,
	attack,
	wall_slide
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

@onready var graphic: Node2D = $Graphic
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var coyote_timer: Timer = $CoyoteTimer

#function
func tick_physics(s: STATE, delta: float) -> void:
	match s:
		STATE.floor:
			move(delta)
			
			floor_animation() # 这里本来不应该这么写，按理来说动画的处理应当统一放在action_control里处理，但是该函数只在状态更新的时候被调用，而floor状态包含两个情况：站立和移动，
							  # 也就是说如果在action_control里处理floor状态的动画将无法正常起效。在这里处理floor动画只是权宜之计，以后应当将floor状态更细致地拆成idle状态和run状态。
							
			if Input.is_action_just_pressed("jump") and not has_jumped and can_1st_jump():
				hold_jump = true
				can_double_jump = true
				has_jumped = true
				do_jump()

		STATE.jump:
			move(delta)
			
			if hold_jump and velocity.y <= jump_impede:
				velocity.y += jump_impede

			if Input.is_action_just_released("jump"):
				hold_jump = false
			
			if Input.is_action_just_pressed("jump") and can_double_jump:
				can_double_jump = false
				do_double_jump()

		STATE.fall:
			move(delta)

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

		STATE.wall_slide:
			move(delta)
			velocity.y = min(velocity.y, 100)
			graphic.scale.x = get_wall_normal().x
			
	print(velocity.y,  " ", state)
	


func move(delta: float) -> void: 
	var dir := Input.get_axis("left", "right")
	var acc := floor_acc if is_on_floor() else air_acc
	velocity.x =move_toward(velocity.x, dir * run_speed, delta * acc)
	velocity.y += gravity * delta
	facing_control()
	move_and_slide()


func action_control(from: STATE, to: STATE) -> void:
	if from != STATE.floor and to == STATE.floor:
		coyote_timer.stop()

	match to:
		STATE.floor:
			floor_animation()
			
		STATE.jump:
			animation_player.play("jump")

			
		STATE.fall:
			animation_player.play("fall")
			
			if from == STATE.floor:
				coyote_timer.start()
				
		STATE.wall_slide:
			animation_player.play("wall_slide")


func floor_animation() -> void:
	if velocity.x:
		animation_player.play("run")
	else:
		animation_player.play("idle")


func do_double_jump() -> void:
	animation_player.play("jump_up")
	velocity.y = jump_velocity


func do_jump() -> void:
	animation_player.play("jump_up")
	velocity.y = jump_velocity
	coyote_timer.stop()


func can_1st_jump() -> bool:
	return is_on_floor() or coyote_timer.time_left > 0


func state_control(s: STATE) -> STATE:
	match s:
		STATE.floor:
			if not is_on_floor():
				if velocity.y < 0:
					return STATE.jump
				elif velocity.y > 0:
					can_double_jump = true
					return STATE.fall

		STATE.jump:
			if velocity.y > 0: 
				return STATE.fall
		
		STATE.fall:
			if is_on_floor():
				has_jumped = false
				can_double_jump = false
				return STATE.floor
			
			if is_on_wall():
				return STATE.wall_slide
				
		STATE.wall_slide:
			if is_on_floor():
				has_jumped = false
				can_double_jump = false
				return STATE.floor
			
	return s
			

func facing_control() -> void:
	if velocity.x > 0:
		graphic.scale.x = 1
	elif velocity.x < 0:
		graphic.scale.x = -1
