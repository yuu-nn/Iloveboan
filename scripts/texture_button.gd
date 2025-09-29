extends TextureButton

@onready var quit_dialog: ConfirmationDialog = $"../QuitDialog"

func _ready() -> void:
	self.pressed.connect(_on_pressed)
	quit_dialog.confirmed.connect(_on_quit_confirmed)

# 버튼 눌렀을 때 → 다이얼로그 열기
func _on_pressed() -> void:
	quit_dialog.dialog_text = "정말 그만두시겠습니까?"
	quit_dialog.popup_centered()

# 다이얼로그에서 확인 눌렀을 때 → 홈화면으로 이동
func _on_quit_confirmed() -> void:
	get_tree().change_scene_to_file("res://scenes/LoadingScene.tscn")
