extends Area2D

@export var speed := 200.0
var passed := false

func _ready():
	add_to_group("obstacle")   # 그룹 등록 → 나중에 속도 조절 가능

func _process(delta):
	position.x -= speed * delta
	
	# 화면 왼쪽 끝으로 나가면 제거
	if position.x < -200:
		queue_free()
