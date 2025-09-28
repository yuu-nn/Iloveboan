extends Node

signal sc_changed(new_sc: int)
signal company_size_changed(new_size: int)

var sc: int = 2000
var owned_items: Array = []
var company_size: int = 0   # 직원 아이템 효과 반영

# 상점 아이템 데이터 (id = 아이콘 파일명과 동일)
var SHOP_ITEMS := {
	"employees": [
		{"id": "intern",   "name": "보안 꿈나무 훈련생", "desc": "매시간 SC를 조금씩 벌어와요.", "price": 200, "effect": {"company_size": 1}},
		{"id": "engineer", "name": "보안 베테랑 엔지니어", "desc": "많은 SC를 벌어오고 회사의 명성을 높여요.", "price": 1000, "effect": {"company_size": 5}},
		{"id": "robot",    "name": "AI 보안 로봇(SC-7)", "desc": "회사 규모를 급성장시키는 최첨단 직원!", "price": 5000, "effect": {"company_size": 50}},
	],
	"office": [
		{"id": "desk",     "name": "업무용 책상", "desc": "가장 기본적인 책상이에요.", "price": 300},
		{"id": "chair",    "name": "편안한 의자", "desc": "직원들의 허리를 보호해 줍니다.", "price": 250},
		{"id": "computer", "name": "보안 강화 컴퓨터", "desc": "해킹을 예방하는 PC입니다.", "price": 800},
	],
	"decor": [
		{"id": "poster",   "name": "보안 수칙 포스터", "desc": "보안 의식을 높여주는 멋진 그림!", "price": 100},
		{"id": "plant",    "name": "공기 정화 화분", "desc": "사무실을 싱그럽게 만들어요.", "price": 150},
		{"id": "tile",     "name": "바닥 타일", "desc": "깔끔한 오피스 타일", "price": 400},
	]
}

func _ready() -> void:
	# 저장된 데이터 불러오기
	SaveManager.load_data()
	sc = int(SaveManager.data.get("sc", sc))
	owned_items = SaveManager.data.get("owned_items", owned_items)
	company_size = int(SaveManager.data.get("company_size", company_size))
	emit_signal("sc_changed", sc)
	emit_signal("company_size_changed", company_size)

func buy_item(item_id: String, price: int) -> bool:
	if sc >= price and not has_item(item_id):
		sc -= price
		owned_items.append(item_id)

		# 아이템 효과 반영
		var effect = _get_item_effect(item_id)
		if effect.has("company_size"):
			company_size += effect["company_size"]
			emit_signal("company_size_changed", company_size)

		emit_signal("sc_changed", sc)

		# 저장 반영
		SaveManager.data["sc"] = sc
		SaveManager.data["owned_items"] = owned_items
		SaveManager.data["company_size"] = company_size
		SaveManager.save()
		return true
	return false

func has_item(item_id: String) -> bool:
	return item_id in owned_items

# 내부 함수: 아이템 효과 가져오기
func _get_item_effect(item_id: String) -> Dictionary:
	for category in SHOP_ITEMS.keys():
		for item in SHOP_ITEMS[category]:
			if item["id"] == item_id and item.has("effect"):
				return item["effect"]
	return {}
