extends Area2D



func _on_Timer_timeout():
	$AnimationPlayer.play("move")
