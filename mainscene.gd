extends Control

# ───────────────────────────────
# 노드 참조
# ───────────────────────────────
@onready var nickname_label = $NICKNAME
@onready var coin_label = $COIN
@onready var study_button = $STUDY
@onready var store_button = $STORE
@onready var game_button = $GAME
@onready var profile_button = $PROFILE

# ───────────────────────────────
# 초기화
# ───────────────────────────────
func _ready() -> void:
	# 닉네임 / 코인 표시
	nickname_label.text = "NICKNAME: " + Globals.nickname
	coin_label.text = "COIN: 0 sc"   # 나중에 Globals.coin 추가 가능

	# 버튼 시그널 연결
	study_button.pressed.connect(_on_study_pressed)
	store_button.pressed.connect(_on_store_pressed)
	game_button.pressed.connect(_on_game_pressed)
	profile_button.pressed.connect(_on_profile_pressed)

	# Globals의 닉네임 변경 이벤트 연결 (Autoload 등록 필수!)
	if Globals.has_signal("nickname_changed"):
		Globals.nickname_changed.connect(_on_nickname_changed)
	else:
		push_warning("Globals.nickname_changed 시그널을 찾을 수 없습니다.")

# ───────────────────────────────
# 버튼 콜백
# ───────────────────────────────
func _on_study_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/LearningScene.tscn")
	
func _on_store_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ShopScene.tscn")

func _on_game_pressed() -> void:
	# 🎮 게임하기 버튼 → 로딩씬으로 이동
	get_tree().change_scene_to_file("res://scenes/jumpgame.tscn")

func _on_profile_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ProfileScene.tscn")

# ───────────────────────────────
# 닉네임 변경 시 실행
# ───────────────────────────────
func _on_nickname_changed(new_name: String) -> void:
	nickname_label.text = "NICKNAME: " + new_name
