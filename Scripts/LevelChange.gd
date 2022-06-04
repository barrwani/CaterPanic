extends Area2D


export var next_level = "res://Scenes/Level_One.tscn"


func _on_LevelChange_area_entered(area):
	if area.is_in_group("player"):
		$AudioStreamPlayer.play()
		SceneChanger.change_scene(next_level)
