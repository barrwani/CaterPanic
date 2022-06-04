extends KinematicBody2D


##zone 0 is ground
##zone 1 is air
##zone 2 is sea

var upenter = false
export var currentzone = 0
export var validzone = 0
var velocity = Vector2()
var jumpspeed =-500
var forcing = false
var gravity = 1100
var movespeed = 600
var jumping = false
var was_on_floor
var changeable = false
var air = false
var climbtick = 0
var inwater = false
var ground = true
var floating = false
var transition = false
var sea = false
var dash = false
var move_input
var schmin
var dead = false
var upstream = false
onready var animatedsprite = $StateMachine/AnimatedSprite

func _apply_gravity(delta):
	if ! dead:
		velocity.y += delta * gravity

func _ready():
	$StateMachine/AnimationPlayer.play("RESET")
	match validzone:
		0:
			ground = true
			air = false
			sea = false
		1:
			air = true
			sea = false
			ground = false
		2:
			air = false
			sea = true
			ground = false

func _input(event):
	if changeable:
		if event.is_action_pressed("E") && !ground:
			validzone = 0
			_collideset(validzone)
			ground = true
			air = false
			sea = false
			transition = true
			changeable = false
			$Transition.start()
		elif event.is_action_pressed("Q") && !air:
			validzone = 1
			_collideset(validzone)
			air = true
			sea = false
			changeable = false
			ground = false
			transition = true
			$Transition.start()
		elif event.is_action_pressed("R") && !sea:
			validzone = 2
			_collideset(validzone)
			sea = true
			air = false
			changeable = false
			ground = false
			transition = true
			$Transition.start()

func _collideset(zone):
	match zone:
		0:
			##ground
			$CaterCollide.set_deferred("disabled", false)
			$Area2D/CaterCollide.set_deferred("disabled",false)
			$ButterCollide.set_deferred("disabled", true)
			$Area2D/ButterCollide.set_deferred("disabled", true)
			$ButterCollide.set_deferred("disabled", true)
			$Area2D/ButterCollide.set_deferred("disabled", true)
			$FishCollide.set_deferred("disabled", true)
			$Area2D/FishCollide.set_deferred("disabled", true)
		1:
			##air
			$CaterCollide.set_deferred("disabled", true)
			$Area2D/CaterCollide.set_deferred("disabled",true)
			$ButterCollide.set_deferred("disabled", false)
			$Area2D/ButterCollide.set_deferred("disabled", false)
			$FishCollide.set_deferred("disabled", true)
			$Area2D/FishCollide.set_deferred("disabled", true)
		2:
			##sea
			$CaterCollide.set_deferred("disabled", true)
			$Area2D/CaterCollide.set_deferred("disabled",true)
			$ButterCollide.set_deferred("disabled", true)
			$Area2D/ButterCollide.set_deferred("disabled", true)
			$FishCollide.set_deferred("disabled", false)
			$Area2D/FishCollide.set_deferred("disabled", false)



func jump():
	if !dead && currentzone == validzone:
		if !sea:
			velocity.y = jumpspeed
		else:
			velocity.y = jumpspeed+70

func _apply_movement():
	if floating && !air:
		velocity.y = -1000
	elif forcing:
		velocity.y = 500
	elif upstream:
		velocity.y = -600
	was_on_floor = is_on_floor()
	if ! was_on_floor && is_on_floor():
		$StateMachine/Land.play()
	velocity = move_and_slide(velocity, Vector2(0,-1))
	if is_on_floor() and jumping and ground:
		jumping = false
	if transition:
		velocity = Vector2.ZERO

func _handle_move_input():
	if !dead && currentzone == validzone:
		if ground:
			if inwater:
				gravity = 700
			else:
				gravity = 1100
			move_input = -int(Input.is_action_pressed("left")) + int(Input.is_action_pressed("right"))
			if move_input != 0:
				animatedsprite.flip_h = move_input != 1
				velocity.x = lerp(velocity.x, movespeed * move_input,0.1)
			else:
				velocity.x = 0
		elif air:
			if !inwater:
				gravity = 1200
			else:
				gravity = 700
			velocity.x = 500
			if dash:
				velocity.x = lerp(velocity.x, movespeed ,0.1)
		elif sea:
			if inwater:
				gravity = 500
			movespeed = 500
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
				dash()

func dash():
	if $DashTimer.is_stopped():
		climbtick = 0
		dash = true
		if animatedsprite.flip_h:
			velocity.x = -3000
		else:
			velocity.x = 3000
		$DashTimer.start()

func death():
	dead = true
	velocity = Vector2.ZERO
	$Camera2D/ScreenShake.start()
	$DeathTimer.start()

func _on_Transition_timeout():
	transition = false

func _on_DashTimer_timeout():
	$TextureProgress.set_deferred("visible", true)
	dash = false
	climbtick = 0
	$DashCD.start()


func _on_DashCD_timeout():
	climbtick = 0.7
	$TextureProgress.set_deferred("visible", false)


func _process(delta):
	if climbtick != 0.7:
		$TextureProgress.value = climbtick
		climbtick+= 0.01



func _on_Area2D_area_entered(area):
	if area.is_in_group("enemy"):
		if area.is_in_group("bomb"):
			area._explode()
		death()
	elif area.is_in_group("ocean"):
		inwater = true
	elif area.is_in_group("fan"):
		floating = true
	elif area.is_in_group("upstream"):
		if upstream:
			upenter = true
		upstream = true
	elif area.is_in_group("downfan"):
		forcing = true
	elif area.is_in_group("groundpass"):
		changeable = true
		currentzone = 0
	elif area.is_in_group("airpass"):
		currentzone = 1
		changeable = true
	elif area.is_in_group("seapass"):
		currentzone = 2
		changeable = true


func _on_DeathTimer_timeout():
	get_tree().reload_current_scene()


func _on_Area2D_area_exited(area):
	if area.is_in_group("fan"):
		floating = false
	elif area.is_in_group("downfan"):
		forcing = false
	elif area.is_in_group("upstream"):
		if !upenter:
			upstream = false
		else:
			upenter = false
	elif area.is_in_group("ocean"):
		inwater = false
