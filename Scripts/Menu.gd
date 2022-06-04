extends Panel

func _on_Play_pressed():
	$Select.play()
	get_tree().change_scene("res://Scenes/Level_One.tscn")

func _on_Exit_pressed():
	get_tree().quit()
