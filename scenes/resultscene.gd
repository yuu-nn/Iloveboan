extends Control

@onready var score_label: Label = $Background/Score
@onready var retry_button: TextureButton = $Background/Retry
@onready var mainmenu_button: TextureButton = $Background/MainMenu

func _ready():
	score_label.text = "SCORE: " + str(Globals.score)

	retry_button.pressed.connect(_on_retry_pressed)
	mainmenu_button.pressed.connect(_on_mainmenu_pressed)

func _on_retry_pressed():
	print("Retry pressed!")  # 디버깅용
	get_tree().reload_current_scene()  # 현재 씬 다시 로드

func _on_mainmenu_pressed():
	get_tree().change_scene_to_file("res://scenes/MainScene.tscn")
