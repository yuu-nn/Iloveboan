extends Control

# 안전하게 경로로 잡기
@onready var sc_value: Label = $RootMargin/VBox/TopBar/SCValue
@onready var grid: GridContainer = $RootMargin/VBox/Scroller/Grid

# 탭 버튼
@onready var tab_employees: Button = $RootMargin/VBox/TabBar/HBoxContainer/EmployeeTabButton
@onready var tab_office: Button    = $RootMargin/VBox/TabBar/HBoxContainer/OfficeTabButton
@onready var tab_decor: Button     = $RootMargin/VBox/TabBar/HBoxContainer/DecorTabButton

# 오토로드 GameState
@onready var GS: Node = get_node("/root/GameState")

# 프리팹
var ShopItemScene: PackedScene = preload("res://scenes/ShopItem.tscn")

# 현재 선택된 카테고리
var current_category: String = "employees"

func _ready() -> void:
	# 레이아웃 강제 (웹에서 깨지는 경우 방지)
	set_anchors_preset(Control.PRESET_FULL_RECT)
	$RootMargin.set_anchors_preset(Control.PRESET_FULL_RECT)

	var vbox = $RootMargin/VBox
	var scroller = $RootMargin/VBox/Scroller
	var grid = $RootMargin/VBox/Scroller/Grid

	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroller.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroller.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL

	# SC 변경 시그널 연결
	if GS.has_signal("sc_changed"):
		GS.sc_changed.connect(_refresh_sc)

	# 탭 버튼 이벤트 연결
	if tab_employees: tab_employees.pressed.connect(_on_tab_employees)
	if tab_office: tab_office.pressed.connect(_on_tab_office)
	if tab_decor: tab_decor.pressed.connect(_on_tab_decor)

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
		load_items(current_category)

# ------------------------------
# 아이템 카드 로드
# ------------------------------
func load_items(category: String) -> void:
	current_category = category

	# 기존 카드 삭제
	for c in grid.get_children():
		c.queue_free()

	# GameState 데이터 불러오기
	var items_to_load = GS.SHOP_ITEMS.get(category, [])

	# 디버깅 로그
	print("[ShopScene] Load category =", category)
	print("[ShopScene] Items to load =", items_to_load)

	for it in items_to_load:
		var card := ShopItemScene.instantiate() as PanelContainer
		card.custom_minimum_size = Vector2(240, 280)

		# 기본 정보
		card.item_id = it["id"]
		card.item_name = it["name"]
		card.item_desc = it["desc"]
		card.price = it["price"]

		# 아이콘 로딩
		var icon_path = "res://itemicons/%s.png" % it["id"]
		print("[ShopScene] Try load icon:", icon_path)
		if ResourceLoader.exists(icon_path):
			card.icon = load(icon_path)
			print("[ShopScene] ✅ Icon loaded:", icon_path)
		else:
			print("[ShopScene] ⚠ 아이콘 없음:", icon_path)

		# 구매 시그널
		card.buy_requested.connect(_on_buy_requested)
		grid.add_child(card)

		# 버튼 상태
		if GS.has_item(card.item_id):
			_lock_buy_button(card, "보유중", true)
		elif GS.sc < card.price:
			_lock_buy_button(card, "SC 부족", true)
		else:
			_lock_buy_button(card, "구매하기", false)

	# 레이아웃 강제 갱신
	grid.queue_sort()
	print("[ShopScene] grid children =", grid.get_child_count())

# ------------------------------
# 구매 버튼 잠금/문구/색상
# ------------------------------
func _lock_buy_button(card: PanelContainer, text: String, disabled: bool) -> void:
	var btn: Button = card.get_node("ItemVBox/BottomBar/BuyBtn")
	if btn:
		btn.disabled = disabled
		btn.text = text
		btn.add_theme_color_override("font_color", Color.WHITE)
		match text:
			"구매하기":
				btn.modulate = Color("#22c55e")   # green
			"SC 부족":
				btn.modulate = Color("#facc15")   # yellow
			"보유중":
				btn.modulate = Color("#9ca3af")   # gray

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
