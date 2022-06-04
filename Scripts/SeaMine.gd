extends Area2D


func _explode():
	$AnimatedSprite.play("Explode")
	$AudioStreamPlayer.play()
	$AnimationPlayer.stop()
	$AnimTimer.start()


func _on_AnimTimer_timeout():
	queue_free()
