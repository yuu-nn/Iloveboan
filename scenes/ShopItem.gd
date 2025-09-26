extends PanelContainer
signal buy_requested(item_id: String, price: int, card: PanelContainer)

@export var item_id: String = "desk_01"
@export var item_name: String = "책상"
@export var price: int = 50
@export var icon: Texture2D

# ※ 고유이름(%) 대신 "경로"로 정확히 잡습니다.
@onready var name_label: Label      = $ItemVBox/ItemName
@onready var price_label: Label     = $ItemVBox/BottomBar/PriceLabel
@onready var icon_rect: TextureRect = $ItemVBox/Icon
@onready var buy_btn: Button        = $ItemVBox/BottomBar/BuyBtn

func _ready() -> void:
	if name_label:
		name_label.text = item_name
	if price_label:
		price_label.text = "%d SC" % price
	if icon_rect and icon:
		icon_rect.texture = icon

	if buy_btn:
		buy_btn.pressed.connect(_on_buy_pressed)

func _on_buy_pressed() -> void:
	emit_signal("buy_requested", item_id, price, self)
