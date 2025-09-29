extends Control

@onready var question_label: Label = $Question
@onready var btn_o: Button = $BtnO
@onready var btn_x: Button = $BtnX
@onready var options_container: VBoxContainer = $OptionsContainer

var current_q: Dictionary
var on_result: Callable

func _ready() -> void:
	visible = false
	btn_o.pressed.connect(func(): _check_answer(true))
	btn_x.pressed.connect(func(): _check_answer(false))

func show_question(q: Dictionary, result_cb: Callable) -> void:
	visible = true
	current_q = q
	on_result = result_cb
	question_label.text = str(q.get("question", ""))

	# 모든 버튼 숨기기
	btn_o.visible = false
	btn_x.visible = false
	options_container.visible = false
	_clear_children(options_container)

	match q.get("type", "ox"):
		"ox":
			btn_o.visible = true
			btn_x.visible = true
		"multi":
			options_container.visible = true
			var opts: Array = q.get("options", [])
			for i in opts.size():
				var b := Button.new()
				b.text = str(opts[i])
				b.pressed.connect(func(): _check_answer(i))
				options_container.add_child(b)

func _clear_children(c: Node) -> void:
	for ch in c.get_children():
		ch.queue_free()

func _check_answer(choice) -> void:
	var ok := false
	var ans = current_q.get("answer")

	match current_q.get("type", "ox"):
		"ox":
			ok = bool(choice) == bool(ans)
		"multi":
			ok = int(choice) == int(ans)

	visible = false
	if on_result.is_valid():
		on_result.call(ok)
