extends CanvasLayer


signal scene_changed()

onready var animation_player = $AnimationPlayer

func same_scene():
	animation_player.play("Idle")
	
func change_scene(path, delay = 0.5):
	yield(get_tree().create_timer(delay), "timeout")
	animation_player.play("SceneTransition")
	yield(animation_player, "animation_finished")
	assert(get_tree().change_scene(path)== OK)
	animation_player.play_backwards("SceneTransition")
	emit_signal("scene_changed")
