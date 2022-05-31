extends "res://Scripts/StateMachine.gd"

signal ground()
signal air()
signal sea()

func _ready():
	add_state("ground")
	add_state("air")
	add_state("sea")
	call_deferred("set_state", states.ground)

func _get_transition(delta):
	match state:
		states.ground:
			if parent.air:
				return states.air
			elif parent.sea:
				return states.sea
		states.air:
			if parent.ground:
				return states.ground
			elif parent.sea:
				return states.sea
		states.sea:
			if parent.air:
				return states.air
			elif parent.ground:
				return states.ground

func _enter_state(new_state, old_state):
	match new_state:
		states.ground:
			emit_signal("ground")
			$Label.text = "Ground"
			##Animation Player effect
			pass
		states.air:
			emit_signal("air")
			$Label.text = "Air"
			##Animation Player effect
			pass
		states.sea:
			emit_signal("sea")
			$Label.text = "Sea"
			##Animation Player effect
			pass

func _exit_state(old_state, new_state):
	pass
