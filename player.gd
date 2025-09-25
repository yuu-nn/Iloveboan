extends Node2D   # player 노드에 붙이는 스크립트

@onready var sprite1 := $뛰는거지1
@onready var sprite2 := $뛰는거지2

var timer := 0.0
var frame_time := 0.15  # 0.15초마다 이미지 교체
var toggle := true

func _process(delta: float) -> void:
	timer += delta
	if timer >= frame_time:
		timer = 0.0
		toggle = !toggle
		sprite1.visible = toggle
		sprite2.visible = !toggle
