extends Node
const SAVE_PATH := "user://save_data.json"

var data := {
	"sc": 1000,                 # 시작 SC (원하면 변경)
	"owned_items": {}           # 구매한 아이템 기록
}

func _ready() -> void:
	load_data()

func save() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))
		f.close()

func load_data() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if f:
			var txt := f.get_as_text()
			f.close()
			var parsed = JSON.parse_string(txt)
			if typeof(parsed) == TYPE_DICTIONARY:
				data = parsed

func reset_all() -> void:
	data = {"sc": 1000, "owned_items": {}}
	save()
