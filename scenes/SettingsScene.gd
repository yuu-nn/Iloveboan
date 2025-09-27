extends Control

# ─────────────────────────────────────────
# 유틸: 안전하게 노드 찾기 (경로 → 재귀 검색)
# ─────────────────────────────────────────
func _find_line_edit(name: String, path: NodePath) -> LineEdit:
	var n: Node = get_node(path) if has_node(path) else find_child(name, true, false)
	if n == null:
		push_error("노드를 찾을 수 없습니다 (LineEdit): " + name + " / " + str(path))
	return n as LineEdit

func _find_button(name: String, path: NodePath) -> Button:
	var n: Node = get_node(path) if has_node(path) else find_child(name, true, false)
	if n == null:
		push_error("노드를 찾을 수 없습니다 (Button): " + name + " / " + str(path))
	return n as Button

func _find_hslider(name: String, path: NodePath) -> HSlider:
	var n: Node = get_node(path) if has_node(path) else find_child(name, true, false)
	if n == null:
		push_error("노드를 찾을 수 없습니다 (HSlider): " + name + " / " + str(path))
	return n as HSlider


# ─────────────────────────────────────────
# 노드 경로(현재 트리 기준) + 이름
# (트리가 바뀌어도 아래 이름 그대로면 자동 재검색)
# ─────────────────────────────────────────
const P_NICK_LINE_EDIT  := NodePath("RootVBox/NicknamePanel/NicknameVBox/NickInputRow/NickLineEdit")
const P_NICK_APPLY_BTN  := NodePath("RootVBox/NicknamePanel/NicknameVBox/NickInputRow/NickApplyButton")
const P_RESET_BUTTON    := NodePath("RootVBox/ResetPanel/ResetVBox/ResetButton")
const P_BGM_SLIDER      := NodePath("RootVBox/AudioPanel/AudioVBox/BgmRow/BgmSlider")
const P_SFX_SLIDER      := NodePath("RootVBox/AudioPanel/AudioVBox/SfxRow/SfxSlider")

var nick_line_edit: LineEdit
var nick_apply_button: Button
var reset_button: Button
var bgm_slider: HSlider
var sfx_slider: HSlider


func _ready() -> void:
	# 1) 노드 안전 획득
	nick_line_edit     = _find_line_edit("NickLineEdit", P_NICK_LINE_EDIT)
	nick_apply_button  = _find_button("NickApplyButton", P_NICK_APPLY_BTN)
	reset_button       = _find_button("ResetButton", P_RESET_BUTTON)
	bgm_slider         = _find_hslider("BgmSlider", P_BGM_SLIDER)
	sfx_slider         = _find_hslider("SfxSlider", P_SFX_SLIDER)

	# 2) 시그널 연결 (존재할 때만)
	if nick_apply_button and nick_line_edit:
		nick_apply_button.pressed.connect(_on_nick_apply_pressed)
	else:
		push_warning("닉네임 변경 UI를 찾지 못해 버튼 연결을 생략했습니다.")

	if reset_button:
		reset_button.pressed.connect(_on_reset_pressed)
	else:
		push_warning("리셋 버튼을 찾지 못해 연결을 생략했습니다.")

	if bgm_slider:
		bgm_slider.value_changed.connect(_on_bgm_volume_changed)
	else:
		push_warning("BGM 슬라이더를 찾지 못해 연결을 생략했습니다.")

	if sfx_slider:
		sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	else:
		push_warning("SFX 슬라이더를 찾지 못해 연결을 생략했습니다.")


# ─────────────────────────────────────────
# 콜백
# ─────────────────────────────────────────
func _on_nick_apply_pressed() -> void:
	var new_name := nick_line_edit.text if nick_line_edit else ""
	print("닉네임 변경:", new_name)

func _on_reset_pressed() -> void:
	print("게임 초기화!")

func _on_bgm_volume_changed(value: float) -> void:
	print("배경음 볼륨:", value)

func _on_sfx_volume_changed(value: float) -> void:
	print("효과음 볼륨:", value)
