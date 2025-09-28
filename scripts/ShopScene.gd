extends Control

# 안전하게 경로로 잡기 (고유이름 % 안 씀)
@onready var sc_value: Label = $RootMargin/VBox/TopBar/SCValue
@onready var grid: GridContainer = $RootMargin/VBox/Scroller/Grid
# 탭 버튼 노드
@onready var tab_employees: Button = $RootMargin/VBox/TabBar/HBoxContainer/EmployeeTabButton
@onready var tab_office: Button = $RootMargin/VBox/TabBar/HBoxContainer/OfficeTabButton
@onready var tab_decor: Button = $RootMargin/VBox/TabBar/HBoxContainer/DecorTabButton

# 오토로드 GameState
@onready var GS: Node = get_node("/root/GameState")

# 프리팹
var ShopItemScene: PackedScene = preload("res://scenes/ShopItem.tscn")

# 현재 선택된 카테고리
var current_category: String = "employees"

func _ready() -> void:
	# SC 변경 시그널
	if GS.has_signal("sc_changed"):
		GS.sc_changed.connect(_refresh_sc)

	# 탭 버튼 이벤트 연결 (람다 X)
	if tab_employees:
		tab_employees.pressed.connect(_on_tab_employees)
	if tab_office:
		tab_office.pressed.connect(_on_tab_office)
	if tab_decor:
		tab_decor.pressed.connect(_on_tab_decor)

	_refresh_sc()
	load_items(current_category)

# ------------------------------
# 탭 버튼 핸들러
# ------------------------------
func _on_tab_employees() -> void:
	load_items("employees")

func _on_tab_office() -> void:
	load_items("office")

func _on_tab_decor() -> void:
	load_items("decor")

# ------------------------------
# SC 표시 갱신
# ------------------------------
func _refresh_sc(_new_sc: int = -1) -> void:
	if sc_value and GS:
		sc_value.text = "보유 SC: %d" % GS.sc
		# SC가 바뀌면 버튼 상태도 새로 반영
		load_items(current_category)

# ------------------------------
# 아이템 카드 로드
# ------------------------------
func load_items(category: String) -> void:
	current_category = category

	# 기존 카드 삭제
	for c in grid.get_children():
		c.queue_free()

	# 탭 스타일 갱신
	_update_tab_styles(category)

	# GameState 데이터
	var items_to_load = GS.SHOP_ITEMS.get(category, [])
	print("[ShopScene] Loading %s items. Size = %d" % [category, items_to_load.size()])

	for it in items_to_load:
		var card := ShopItemScene.instantiate() as PanelContainer

		# it은 Dictionary이므로 []로 접근
		card.item_id = it["id"]
		card.item_name = it["name"]
		card.item_desc = it["desc"]
		card.price = it["price"]

		# TODO: 아이콘 로딩 (필요시)
		# card.icon = load("res://assets/icons/%s.png" % it["id"])

		card.buy_requested.connect(_on_buy_requested)
		grid.add_child(card)

		# 버튼 상태
		if GS.has_item(card.item_id):
			_lock_buy_button(card, "보유중", true)
		elif GS.sc < card.price:
			_lock_buy_button(card, "SC 부족", true)
		else:
			_lock_buy_button(card, "구매하기", false)

# ------------------------------
# 구매 버튼 잠금/문구/색상
# ------------------------------
func _lock_buy_button(card: PanelContainer, text: String, disabled: bool) -> void:
	var btn: Button = card.get_node("ItemVBox/BottomBar/BuyBtn")
	if btn:
		btn.disabled = disabled
		btn.text = text
		btn.add_theme_color_override("font_color", Color(1, 1, 1)) # 흰 글씨
		match text:
			"구매하기":
				btn.modulate = Color("#22c55e")   # green-500
			"SC 부족":
				btn.modulate = Color("#facc15")   # yellow-400
			"보유중":
				btn.modulate = Color("#9ca3af")   # gray-400

# ------------------------------
# 탭 스타일 (간단: 글씨색만)
# ------------------------------
func _update_tab_styles(active_category: String) -> void:
	var tabs := {
		"employees": tab_employees,
		"office": tab_office,
		"decor": tab_decor,
	}

	for cat in tabs:
		var tab_btn: Button = tabs[cat]
		if tab_btn == null:
			continue
		if cat == active_category:
			tab_btn.add_theme_color_override("font_color", Color("#1d4ed8")) # 파랑
		else:
			tab_btn.add_theme_color_override("font_color", Color("#111827")) # 검정

# ------------------------------
# 구매 처리
# ------------------------------
func _on_buy_requested(item_id: String, price: int, card: PanelContainer) -> void:
	if GS.has_item(item_id):
		_show_msg("이미 보유한 아이템이에요.")
		return

	if GS.buy_item(item_id, price):
		_lock_buy_button(card, "보유중", true)
		_show_msg("구매 완료!")
		load_items(current_category)
	else:
		_show_msg("SC가 부족합니다.")

# ------------------------------
# 알림 다이얼로그
# ------------------------------
func _show_msg(text: String) -> void:
	var dlg := AcceptDialog.new()
	add_child(dlg)
	dlg.title = "알림"
	dlg.dialog_text = text
	dlg.popup_centered()
