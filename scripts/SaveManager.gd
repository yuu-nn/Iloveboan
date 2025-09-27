extends Node

const SAVE_PATH := "user://save_data.json"

var data: Dictionary = {
	"sc": 1000,        # 시작 SC
	"owned_items": []  # 보유 아이템 기록 (Array)
}

func _ready() -> void:
	load_data()

# 저장
func save() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data, "\t")) # 보기 좋게 들여쓰기
		f.close()
		print("[SaveManager] Saved:", data)

# 불러오기
func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("[SaveManager] No save file, using defaults.")
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f:
		var txt := f.get_as_text()
		f.close()
		var parsed = JSON.parse_string(txt)
		if typeof(parsed) == TYPE_DICTIONARY:
			if parsed.has("sc"):
				data["sc"] = parsed["sc"]
			if parsed.has("owned_items"):
				data["owned_items"] = parsed["owned_items"]
			print("[SaveManager] Loaded:", data)
		else:
			print("[SaveManager] Invalid save, resetting.")
			reset_all()

# 전체 초기화
func reset_all() -> void:
	data = {"sc": 1000, "owned_items": []}
	save()
