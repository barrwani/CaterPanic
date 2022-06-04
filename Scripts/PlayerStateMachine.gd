extends "res://Scripts/StateMachine.gd"


func _ready():
	add_state("idle")
	add_state("run")
	add_state("dash")
	add_state("fly")
	add_state("jump")
	add_state("dead")
	add_state("fall")
	add_state("transition")
	call_deferred("set_state",states.idle)

func _input(event):
	if [states.idle, states.run, states.jump, states.fall].has(state):
		if event.is_action_pressed("up") && (! parent.jumping || ( parent.air || parent.sea)):
			if parent.air:
				$Fly.play()
			elif parent.sea:
				$Swim.play()
			parent.jumping = true
			parent.jump()



func _state_logic(delta):
	parent._apply_movement()

	parent._handle_move_input()
	parent._apply_gravity(delta)


func _get_transition(delta):
	match state:
		states.idle:
			if parent.dead:
				return states.dead
			elif parent.dash:
				return states.dash
			elif parent.transition:
				return states.transition
			elif ! parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y >= 0 && ! parent.is_on_floor():
					parent.jumping = false
					return states.fall
			elif abs(parent.velocity.x) > 50:
				parent.jumping = false
				return states.run
		states.run:
			if parent.dead:
				return states.dead
			elif parent.dash:
				return states.dash
			elif parent.transition:
				return states.transition
			elif !parent.is_on_floor():
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y > 0:
					parent.jumping = false
					return states.fall
			elif abs(parent.velocity.x) == 0:
				parent.jumping = false
				return states.idle
		states.jump:
			if parent.dead:
				return states.dead
			elif parent.dash:
				return states.dash
			elif parent.transition:
				return states.transition
			elif parent.velocity.y >= 0 and ! parent.is_on_floor():
				return states.fall
			elif parent.is_on_floor():
				parent.jumping = false
				return states.idle
		states.fall:
			if parent.dead:
				return states.dead
			elif parent.dash:
				return states.dash
			elif (parent.air|| parent.sea) && parent.jumping && parent.velocity.y <0 :
				return states.jump
			elif parent.transition:
				return states.transition
			elif parent.is_on_floor():
				parent.jumping = false
				return states.idle
		states.dead:
			if !parent.dead:
				return states.idle
		states.transition:
			if parent.dead:
				return states.dead
			elif !parent.transition:
				return states.idle
		states.dash:
			if !parent.dash:
				return states.idle

			

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			if parent.ground:
				if ! parent.was_on_floor:
					$Land.play()
				$AnimatedSprite.play("Idle")
			elif parent.sea:
				$AnimatedSprite.play("Fish")
			elif parent.air:
				$AnimatedSprite.play("Bidle")
		states.run:
			if parent.ground:
				$AnimatedSprite.play("Run")
			elif parent.sea:
				$AnimatedSprite.play("Fish")
		states.jump:
			if parent.ground:
				$Jump.play()
				$AnimatedSprite.play("Jump")
			elif parent.air:
				$AnimatedSprite.play("Bjump")

		states.dead:
			$AnimationPlayer.play("Death")
			$Death.play()
		states.fall:
			if parent.ground:
				$AnimatedSprite.play("Fall")
			elif parent.air:
				$AnimatedSprite.play("Bidle")
		states.transition:
			$Change.play()
		states.dash:
			if parent.air:
				$AnimatedSprite.play("Bjump")
			elif parent.sea:
				$AnimatedSprite.play("FastFish")
				$Dash.play()


func _exit_state(old_state, new_state):
	pass


