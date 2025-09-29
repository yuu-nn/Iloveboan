extends Control

@onready var score_label: Label = $Background/Score
@onready var retry_button: TextureButton = $Background/Retry
@onready var mainmenu_button: TextureButton = $Background/MainMenu

func _ready() -> void:
	# 점수 표시 (Globals.score에 저장되어 있다고 가정)
	if score_label:
		score_label.text = str(Globals.score)

	# 버튼 연결
	if retry_button:
		retry_button.pressed.connect(_on_retry_pressed)
	if mainmenu_button:
		mainmenu_button.pressed.connect(_on_mainmenu_pressed)

# "다시하기" 버튼 → jumpgame 씬 재시작
func _on_retry_pressed() -> void:
	print("Retry pressed!")  # 디버깅 로그
	get_tree().change_scene_to_file("res://scenes/jumpgame.tscn")

# "메인메뉴" 버튼 → StartScene 으로 이동
func _on_mainmenu_pressed() -> void:
	print("Main Menu pressed!")  # 디버깅 로그
	get_tree().change_scene_to_file("res://scenes/LoadingScene.tscn")
