# res://scripts/OfficeDecorScene.gd
extends Control

# ===== 노드 참조 =====
@onready var canvas_area: Control = $RootMargin/VBox/Content/CanvasPanel/CanvasMargin/CanvasArea
@onready var hint_label: Label = $RootMargin/VBox/Content/CanvasPanel/CanvasMargin/CanvasArea/Hint

@onready var save_btn: Button  = $RootMargin/VBox/Content/Sidebar/SideVBox/SaveRow/SaveBtn
@onready var load_btn: Button  = $RootMargin/VBox/Content/Sidebar/SideVBox/LoadRow/LoadBtn
@onready var reset_btn: Button = $RootMargin/VBox/Content/Sidebar/SideVBox/ResetRow/ResetBtn

@onready var btn_chair: Button    = $RootMargin/VBox/Content/Sidebar/SideVBox/ItemGrid/BtnChair
@onready var btn_computer: Button = $RootMargin/VBox/Content/Sidebar/SideVBox/ItemGrid/BtnComputer
@onready var btn_desk: Button     = $RootMargin/VBox/Content/Sidebar/SideVBox/ItemGrid/BtnDesk

# ===== 프리팹 =====
var DraggableItemScene: PackedScene = preload("res://scenes/DraggableItem.tscn")

# ===== 저장 경로 =====
const SAVE_PATH := "user://decor_layout.json"

# ===== 아이콘 폴더 =====
const ICON_DIR := "res://itemicons/Officeicons/"

# ===== 아이템 DB =====
var ITEM_DB := {
	"chair":    { "caption": "의자",   "texture": ICON_DIR + "chair.png" },
	"computer": { "caption": "컴퓨터", "texture": ICON_DIR + "computer.png" },
	"desk":     { "caption": "책상",   "texture": ICON_DIR + "desk.png" }
}

func _ready() -> void:
	randomize()

	# (선택) 마진 강제
	var m: MarginContainer = $RootMargin as MarginContainer
	if m:
		m.add_theme_constant_override("margin_left", 16)
		m.add_theme_constant_override("margin_right", 16)
		m.add_theme_constant_override("margin_top", 16)
		m.add_theme_constant_override("margin_bottom", 16)

	# 버튼 연결
	save_btn.pressed.connect(_on_save_pressed)
	load_btn.pressed.connect(_on_load_pressed)
	reset_btn.pressed.connect(_on_reset_pressed)

	btn_chair.pressed.connect(func(): _spawn_item("chair"))
	btn_computer.pressed.connect(func(): _spawn_item("computer"))
	btn_desk.pressed.connect(func(): _spawn_item("desk"))

	_update_hint_visibility()

func _spawn_item(key: String) -> void:
	if not ITEM_DB.has(key):
		return
	var d: Dictionary = ITEM_DB[key]
	var node: TextureRect = DraggableItemScene.instantiate() as TextureRect
	node.item_id = key
	node.caption = String(d.get("caption", ""))

	var tex_path: String = String(d.get("texture", ""))
	var tex: Texture2D = load(tex_path) as Texture2D
	if tex:
		node.texture = tex

	node.position = _get_spawn_position()
	canvas_area.add_child(node)
	_bring_trophy_to_front()
	_update_hint_visibility()

func _get_spawn_position() -> Vector2:
	var offset: Vector2 = Vector2(randi() % 80, randi() % 80)
	return Vector2(24, 24) + offset

func _update_hint_visibility() -> void:
	var has_item: bool = false
	for c: Node in canvas_area.get_children():
		if c is TextureRect and c.has_method("to_dict"):
			has_item = true
			break
	hint_label.visible = not has_item

func _bring_trophy_to_front() -> void:
	if canvas_area.has_node("TrophyBtn"):
		var t: CanvasItem = canvas_area.get_node("TrophyBtn") as CanvasItem
		if t:
			t.move_to_front()

# ===== 저장 / 불러오기 / 초기화 =====
func _on_save_pressed() -> void:
	var arr: Array = []
	for c: Node in canvas_area.get_children():
		if c is TextureRect and c.has_method("to_dict"):
			arr.append((c as TextureRect).to_dict())
	var json_str: String = JSON.stringify({ "items": arr }, "\t")
	var f: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(json_str)
		f.close()
		_notify("배치를 저장했어요.")

func _on_load_pressed() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		_notify("저장된 배치가 없어요.")
		return

	_clear_canvas_items()

	var f: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return
	var txt: String = f.get_as_text()
	f.close()

	# ★ JSON.parse_string는 Variant를 반환 → 타입 명시 & 검사
	var parsed_v: Variant = JSON.parse_string(txt)
	if typeof(parsed_v) != TYPE_DICTIONARY:
		_notify("저장 파일이 올바르지 않습니다.")
		return
	var parsed: Dictionary = parsed_v

	var items: Array = parsed.get("items", []) as Array
	for it_v: Variant in items:
		var it: Dictionary = it_v
		var node: TextureRect = DraggableItemScene.instantiate() as TextureRect
		node.from_dict(it)
		canvas_area.add_child(node)

	_bring_trophy_to_front()
	_update_hint_visibility()
	_notify("불러왔어요.")

func _on_reset_pressed() -> void:
	_clear_canvas_items()
	_update_hint_visibility()
	_notify("초기화했어요.")

func _clear_canvas_items() -> void:
	for c: Node in canvas_area.get_children():
		if c.name in ["Hint", "TrophyBtn"]:
			continue
		c.queue_free()

func _notify(msg: String) -> void:
	print(msg)
