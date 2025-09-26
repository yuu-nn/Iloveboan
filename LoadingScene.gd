extends Control

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var character: Sprite2D = $Sprite2D
@onready var loading_label: Label = $LOADING   # Inspector에서 Label 노드 이름 확인!

var frames: Array[Texture2D] = []
var frame_idx := 0
var change_every := 0.2
var acc := 0.0

var target_box := Vector2(64, 64)   # 캐릭터를 맞출 박스 크기
var extra_scale := 1.5              # 추가 배율 (크기 조절)

# LOADING... 점점점
var dot_timer := 0.0
var dot_interval := 0.5
var dot_count := 0

func _ready():
	frames = [
		load("res://이미지 모아둔 폴더/거지.png") as Texture2D,
		load("res://이미지 모아둔 폴더/뛰는 거지.png") as Texture2D,
	]
	_apply_frame(0)
	progress_bar.value = 0
	loading_label.text = "LOADING"

func _process(delta: float) -> void:
	# 로딩바 진행
	if progress_bar.value < 100:
		progress_bar.value += delta * 20.0
	else:
		progress_bar.value = 100
		get_tree().change_scene_to_file("res://scenes/MainScene.tscn")
		return

	# 캐릭터 위치
	var ratio := progress_bar.value / 100.0
	var x := progress_bar.position.x + progress_bar.size.x * ratio
	character.position = Vector2(x, progress_bar.position.y - 40)

	# 프레임 애니메이션
	acc += delta
	if acc >= change_every:
		frame_idx = (frame_idx + 1) % frames.size()
		_apply_frame(frame_idx)
		acc = 0.0

	# LOADING... 점점점
	dot_timer += delta
	if dot_timer >= dot_interval:
		dot_count = (dot_count + 1) % 4
		loading_label.text = "LOADING" + ".".repeat(dot_count)
		dot_timer = 0.0

# ───────────────────────────────
# 프레임 교체 + 크기 통일
func _apply_frame(i: int) -> void:
	character.texture = frames[i]
	_fit_sprite_to_box(character, target_box)
	character.rotation_degrees = 0

# 캐릭터 크기를 항상 같은 박스 안에 맞추기
func _fit_sprite_to_box(spr: Sprite2D, box: Vector2) -> void:
	var tex := spr.texture
	if tex == null: return
	var sz := tex.get_size()
	if sz.x <= 0 or sz.y <= 0: return
	spr.scale = (box / sz) * extra_scale
