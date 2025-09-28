extends Control

@onready var prev_btn: Button = $PrevPageBtn
@onready var next_btn: Button = $NextPageBtn
@onready var main_btn: Button = $MainBtn

@onready var page_container: Node = $PageContainer
var pages: Array = []
var current_page: int = 0   # 왼쪽 페이지만 가리킴 (0, 2, 4...)

func _ready() -> void:
	pages = page_container.get_children()

	prev_btn.pressed.connect(_on_prev_page)
	next_btn.pressed.connect(_on_next_page)
	main_btn.pressed.connect(_on_back_to_main)

	_update_pages()


func _update_pages() -> void:
	for i in range(pages.size()):
		pages[i].visible = false

	if current_page < pages.size():
		pages[current_page].visible = true    # 왼쪽 면
	if current_page + 1 < pages.size():
		pages[current_page + 1].visible = true  # 오른쪽 면


func _on_next_page() -> void:
	if current_page + 2 < pages.size():
		current_page += 2   # 다음 두 면
		_update_pages()


func _on_prev_page() -> void:
	if current_page - 2 >= 0:
		current_page -= 2   # 이전 두 면
		_update_pages()


func _on_back_to_main() -> void:
	get_tree().change_scene_to_file("res://scenes/MainScene.tscn")
