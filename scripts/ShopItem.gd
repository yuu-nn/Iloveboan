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
	# 카드 패널 스타일 (흰 배경 + 둥근 모서리 + 그림자)
	self.add_theme_stylebox_override("panel", _make_card_style())
	
	if name_label:
		name_label.text = item_name
		name_label.add_theme_color_override("font_color", Color("#1f2937")) # text-gray-800
		name_label.add_theme_font_size_override("font_size", 20)

	if desc_label:
		desc_label.text = item_desc
		desc_label.add_theme_color_override("font_color", Color("#6b7280")) # text-gray-500
		desc_label.add_theme_font_size_override("font_size", 14)

	if price_label:
		price_label.text = "%d SC" % price
		price_label.add_theme_color_override("font_color", Color("#f59e0b")) # amber-500
		price_label.add_theme_font_size_override("font_size", 18)

	if icon_rect and icon:
		icon_rect.texture = icon
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.custom_minimum_size = Vector2(64, 64)

	if buy_btn:
		buy_btn.text = "구매하기"
		buy_btn.add_theme_color_override("font_color", Color.WHITE)
		buy_btn.add_theme_color_override("font_pressed_color", Color.WHITE)
		buy_btn.add_theme_color_override("font_hover_color", Color.WHITE)
		buy_btn.custom_minimum_size = Vector2(120, 40)
		buy_btn.add_theme_stylebox_override("normal", _make_button_style(Color("#3b82f6")))
		buy_btn.add_theme_stylebox_override("hover", _make_button_style(Color("#2563eb")))
		buy_btn.add_theme_stylebox_override("pressed", _make_button_style(Color("#1d4ed8")))

		if not buy_btn.is_connected("pressed", Callable(self, "_on_buy_pressed")):
			buy_btn.pressed.connect(_on_buy_pressed)

func _on_buy_pressed() -> void:
	emit_signal("buy_requested", item_id, price, self)

# ------------------------------
# 스타일 헬퍼
# ------------------------------
func _make_card_style() -> StyleBoxFlat:
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color.WHITE
	sb.corner_radius_top_left = 12
	sb.corner_radius_top_right = 12
	sb.corner_radius_bottom_left = 12
	sb.corner_radius_bottom_right = 12
	sb.shadow_color = Color(0, 0, 0, 0.1)
	sb.shadow_size = 8
	sb.content_margin_left = 16
	sb.content_margin_right = 16
	sb.content_margin_top = 12
	sb.content_margin_bottom = 12
	return sb

func _make_button_style(c: Color) -> StyleBoxFlat:
	var sb = StyleBoxFlat.new()
	sb.bg_color = c
	sb.corner_radius_top_left = 8
	sb.corner_radius_top_right = 8
	sb.corner_radius_bottom_left = 8
	sb.corner_radius_bottom_right = 8
	return sb
	
	self.custom_minimum_size = Vector2(240, 280)
