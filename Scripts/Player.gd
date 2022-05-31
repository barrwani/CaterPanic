extends KinematicBody2D


var velocity = Vector2()
var jumpspeed =-500
var gravity = 1100
var movespeed = 600
var jumping = false
var air = false
var climbtick = 0
var ground = true
var transition = false
var sea = false
var dash = false
var move_input
var schmin
var dead = false
onready var animatedsprite = $StateMachine/AnimatedSprite

func _apply_gravity(delta):
	velocity.y += delta * gravity

func _input(event):
	if event.is_action_pressed("E") && !ground:
		ground = true
		air = false
		sea = false
		transition = true
		$Transition.start()
	elif event.is_action_pressed("Q") && !air:
		air = true
		sea = false
		ground = false
		transition = true
		$Transition.start()
	elif event.is_action_pressed("R") && !sea:
		sea = true
		air = false
		ground = false
		transition = true
		$Transition.start()

func jump():
	velocity.y = jumpspeed

func _apply_movement():
	var was_on_floor = is_on_floor()
	velocity = move_and_slide(velocity, Vector2(0,-1))
	if is_on_floor() and jumping and ground:
		jumping = false
	if transition:
		velocity = Vector2.ZERO

func _handle_move_input():
	if !dead:
		if ground:
			move_input = -int(Input.is_action_pressed("left")) + int(Input.is_action_pressed("right"))
			if move_input != 0:
				animatedsprite.flip_h = move_input != 1
				velocity.x = lerp(velocity.x, movespeed * move_input,0.1)
			else:
				velocity.x = 0
		elif air:
			gravity = 1200
			velocity.x = 500
		elif sea:
			gravity = 700
			movespeed = 300
			move_input = -int(Input.is_action_pressed("left")) + int(Input.is_action_pressed("right"))

			if dash:
				if animatedsprite.flip_h:
					schmin = -1
				else:
					schmin = 1
				velocity.x = lerp(velocity.x, movespeed * schmin,0.1)
			if move_input != 0:
				animatedsprite.flip_h = move_input != 1
				velocity.x = lerp(velocity.x, movespeed * move_input,0.1)
			else:
				velocity.x = 0
			if Input.is_action_pressed("shift") && $DashCD.is_stopped():
				waterdash()

func waterdash():
	if $DashTimer.is_stopped():
		climbtick = 0
		dash = true
		if animatedsprite.flip_h:
			velocity.x = -2000
		else:
			velocity.x = 2000
		$DashTimer.start()

func death():
	get_tree().reload_current_scene()

func _on_Transition_timeout():
	transition = false


func _on_DashTimer_timeout():
	$TextureProgress.set_deferred("visible", true)
	dash = false
	$climber.start()
	$DashCD.start()


func _on_DashCD_timeout():
	climbtick = 0.7
	$TextureProgress.set_deferred("visible", false)


func _on_climber_timeout():
	if climbtick != 0.7:
		$TextureProgress.value = climbtick
		climbtick+= 0.02
		$climber.start()
