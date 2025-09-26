# res://scripts/GameState.gd
extends Node

var sc: int = 200          # 시작 코인(원하면 바꿔)
var inventory := {}        # 간단한 인벤토리 (구매여부 기록용)

func _ready() -> void:
	# 저장된 값 불러오기 (SaveManager 오토로드 필요)
	if SaveManager and SaveManager.data:
		sc = SaveManager.data.get("sc", sc)
		inventory = SaveManager.data.get("owned_items", inventory)

func _flush_save() -> void:
	if not SaveManager:
		return
	if not SaveManager.data.has("owned_items"):
		SaveManager.data["owned_items"] = {}
	SaveManager.data["sc"] = sc
	SaveManager.data["owned_items"] = inventory
	SaveManager.save()

func has_item(id: String) -> bool:
	return inventory.get(id, false)

func buy_item(id: String, price: int) -> bool:
	if sc >= price and not has_item(id):
		sc -= price
		inventory[id] = true
		_flush_save()   # 구매 성공 시 저장
		return true
	return false
