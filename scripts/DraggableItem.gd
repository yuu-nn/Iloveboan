extends TextureRect

@export var item_id: String = ""   # "chair", "plant", "cctv", "cabinet" 등
@export var caption: String = ""
@onready var cap: Label = $Caption

var _dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if caption != "":
		if cap != null:
			cap.text = caption

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_dragging = true
			_drag_offset = get_local_mouse_position()
			grab_focus()
		else:
			_dragging = false
	elif event is InputEventMouseMotion and _dragging:
		var target: Vector2 = get_global_mouse_position() - _drag_offset
		_move_inside_parent(target)

func _move_inside_parent(global_target: Vector2) -> void:
	var parent_ctrl: Control = get_parent() as Control
	if parent_ctrl == null:
		return

	# Godot 4.5: get_global_rect() -> Rect2i 이므로 실수 연산 위해 Vector2로 변환
	var p_recti: Rect2i = parent_ctrl.get_global_rect()
	var p_pos: Vector2 = Vector2(p_recti.position)
	var p_size: Vector2 = Vector2(p_recti.size)

	var my_size: Vector2 = size
	var clamped: Vector2 = Vector2(
		clamp(global_target.x, p_pos.x, p_pos.x + p_size.x - my_size.x),
		clamp(global_target.y, p_pos.y, p_pos.y + p_size.y - my_size.y)
	)
	global_position = clamped

func to_dict() -> Dictionary:
	var tex_path: String = ""
	# TextureRect.texture는 Texture2D 타입
	if texture != null:
		var tex2d: Texture2D = texture
		if tex2d != null:
			tex_path = tex2d.resource_path
	return {
		"item_id": item_id,
		"caption": caption,
		"x": float(position.x),
		"y": float(position.y),
		"texture": tex_path
	}

func from_dict(d: Dictionary) -> void:
	item_id = String(d.get("item_id", ""))
	caption = String(d.get("caption", ""))

	var x: float = float(d.get("x", 0.0))
	var y: float = float(d.get("y", 0.0))
	position = Vector2(x, y)

	var tex_path: String = String(d.get("texture", ""))
	if tex_path != "":
		var res: Resource = load(tex_path)
		if res is Texture2D:
			texture = res as Texture2D

	if cap != null:
		cap.text = caption
