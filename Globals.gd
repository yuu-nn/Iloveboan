extends Node

signal nickname_changed(new_name)

var nickname: String = "플레이어":
	set(value):
		nickname = value
		emit_signal("nickname_changed", value)
		
var score: int = 0          # 점수용
