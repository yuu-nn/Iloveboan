extends Control

func _on_button_pressed():
	# MainScene이 아니라 LoadingScene으로 먼저 전환
	get_tree().change_scene_to_file("res://scenes/LoadingScene.tscn")
