extends PanelContainer

signal buy_requested(item_id: String, price: int, card: PanelContainer)

@export var item_id: String = "default_id"
@export var item_name: String = "아이템 이름"
@export var item_desc: String = "아이템 설명이 표시됩니다."
@export var price: int = 50
@export var icon: Texture2D

@onready var name_label: Label      = $ItemVBox/ItemName
@onready var desc_label: Label      = $ItemVBox/DescLabel
@onready var icon_rect: TextureRect = $ItemVBox/Icon
@onready var price_label: Label     = $ItemVBox/BottomBar/PriceLabel
@onready var buy_btn: Button        = $ItemVBox/BottomBar/BuyBtn

func _ready() -> void:
	if name_label:
		name_label.text = item_name
	if desc_label:
		desc_label.text = item_desc
	if price_label:
		price_label.text = "%d SC" % price
	if icon_rect and icon:
		icon_rect.texture = icon

	if buy_btn and not buy_btn.is_connected("pressed", Callable(self, "_on_buy_pressed")):
		buy_btn.pressed.connect(_on_buy_pressed)

func _on_buy_pressed() -> void:
	emit_signal("buy_requested", item_id, price, self)
