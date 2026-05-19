extends CharacterBody2D

enum STATE {
	idle,
    move,
	jump,
	fall,
    dash
	}

#variables & constants
var gravity := ProjectSettings.get("physics/2d/default_gravity") as float 

const move_speed : float = 200.0
const jump_velocity : float = -250.0
const wait_duration : float = 5.0

var state : STATE = STATE.idle
var wait_timer : float = 0.0

@onready var graphic: Node2D = $Graphic
@onready var animation_player: AnimationPlayer = $AnimationPlayer

#function
func tick_physics(s: STATE, delta: float) -> void:
	match s:
		STATE.idle:
            if action_timer < action_period:
                action_timer += delta
            else:


        STATE.move:
            pass

        STATE.jump:
            pass
        
        STATE.dash:
            pass

	

# 处理且仅处理角色移动
func move(delta: float) -> void: 
    #!!!


# 处理且仅处理动作执行
func action_control(from: STATE, to: STATE) -> void:
	#!!!

# 处理且仅处理状态切换
func state_control(s: STATE) -> STATE:
    match s:
        STATE.idle:
            if velocity.x:
                return STATE.move

            if velocity.y < 0: 
                return  STATE.jump
            elif velocity > 0:
                return STATE.fall
            
        STATE.jump:
            if velocity > 0:
               return STATE.fall

        STATE.fall:
            if is_on_floor():
                return STATE.idle

        STATE.move:
            if not velocity.x:
                return STATE.idle

        STATE.dash:
            if not velocity.x:
                return STATE.idle 
			

func facing_control() -> void:
	if velocity.x > 0:
		graphic.scale.x = 1
	elif velocity.x < 0:
		graphic.scale.x = -1
