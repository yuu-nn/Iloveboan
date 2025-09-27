extends Node

signal sc_changed(new_sc: int)

var sc: int = 2000
var owned_items: Array = []

# 상점 아이템 데이터
var SHOP_ITEMS := {
	"employees": [
		{"id": "employee_01", "name": "보안 꿈나무 훈련생", "desc": "가장 기본이 되는 직원입니다. (규모 +1)", "price": 100},
		{"id": "employee_02", "name": "보안 베테랑 엔지니어", "desc": "업무 능률이 좋은 숙련자입니다. (규모 +5)", "price": 500},
		{"id": "employee_03", "name": "AI 보안 로봇(SC-7)", "desc": "회사를 급성장시키는 최첨단 로봇! (규모 +50)", "price": 5000},
		{"id": "employee_04", "name": "24시간 경비원", "desc": "해킹 사고 발생 확률을 낮춥니다.", "price": 1500},
	],
	"office": [
		{"id": "desk_01", "name": "꼬질꼬질 나무 책상", "desc": "가장 기본적인 책상이에요.", "price": 50},
		{"id": "chair_01", "name": "꿀잠 방지 의자", "desc": "직원들의 허리를 보호해 줍니다.", "price": 150},
		{"id": "pc_01", "name": "보안 강화 컴퓨터", "desc": "해킹을 예방하는 PC입니다.", "price": 300},
	],
	"decor": [
		{"id": "poster_01", "name": "보안 수칙 포스터", "desc": "보안 의식을 높여주는 멋진 그림!", "price": 20},
		{"id": "plant_01", "name": "공기 정화 화분", "desc": "사무실을 싱그럽게 만들어요.", "price": 80},
	]
}

func _ready() -> void:
	# 저장된 데이터 불러오기
	SaveManager.load_data()
	sc = int(SaveManager.data.get("sc", sc))
	owned_items = SaveManager.data.get("owned_items", owned_items)
	emit_signal("sc_changed", sc)

func buy_item(item_id: String, price: int) -> bool:
	if sc >= price and not has_item(item_id):
		sc -= price
		owned_items.append(item_id)
		emit_signal("sc_changed", sc)
		# 저장 반영
		SaveManager.data["sc"] = sc
		SaveManager.data["owned_items"] = owned_items
		SaveManager.save()
		return true
	return false

func has_item(item_id: String) -> bool:
	return item_id in owned_items
