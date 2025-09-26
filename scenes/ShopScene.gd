extends Control

# 안전하게 경로로 잡기 (고유이름 % 안 씀)
@onready var sc_value: Label = $RootMargin/VBox/TopBar/SCValue
@onready var grid: GridContainer = $RootMargin/VBox/Scroller/Grid

# 오토로드 GameState를 명시적으로 참조
@onready var GS: Node = get_node("/root/GameState")

# ShopItem 프리팹
var ShopItemScene: PackedScene = preload("res://scenes/ShopItem.tscn")

# 상점 카드 목록 (원하는 만큼 추가 가능)
var items = [
	{"id":"employee_01", "name":"직원 고용",    "price":100},
	{"id":"desk_01",     "name":"책상",        "price":50},
	{"id":"chair_01",    "name":"의자",        "price":30},
	{"id":"poster_01",   "name":"보안 포스터", "price":20},
]

func _ready() -> void:
	_refresh_sc()
	_populate_items()

# 현재 SC 표시
func _refresh_sc() -> void:
	if sc_value and GS:
		sc_value.text = "보유 SC: %d" % GS.sc

# 아이템 카드 생성
func _populate_items() -> void:
	# 기존 카드 정리
	for c in grid.get_children():
		c.queue_free()

	print("[ShopScene] items.size = ", items.size())
	for it in items:
		var card := ShopItemScene.instantiate()
		card.item_id = it["id"]
		card.item_name = it["name"]
		card.price = it["price"]

		# 필요하면 아이콘 지정 (임시: 프로젝트 기본 아이콘)
		# card.icon = load("res://icon.svg")

		card.buy_requested.connect(_on_buy_requested)
		grid.add_child(card)

		# 이미 구매된 아이템이면 버튼 잠금
		if GS.has_item(card.item_id):
			var btn: Button = card.get_node("ItemVBox/BottomBar/BuyBtn")
			if btn:
				btn.disabled = true
				btn.text = "보유중"

# 구매 처리
func _on_buy_requested(item_id: String, price: int, card: Node) -> void:
	if GS.has_item(item_id):
		_show_msg("이미 보유한 아이템이에요.")
		return

	if GS.buy_item(item_id, price):
		_refresh_sc()
		var btn: Button = card.get_node("ItemVBox/BottomBar/BuyBtn")
		if btn:
			btn.disabled = true
			btn.text = "보유중"
		_show_msg("구매 완료!")
	else:
		_show_msg("SC가 부족합니다.")

# 간단 알림 다이얼로그
func _show_msg(text: String) -> void:
	var dlg := AcceptDialog.new()
	add_child(dlg)
	dlg.title = "알림"
	dlg.dialog_text = text
	dlg.popup_centered()
