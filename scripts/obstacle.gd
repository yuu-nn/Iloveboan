# Obstacle.gd
extends Area2D

@export var speed: float = 200.0
var passed := false

func _ready() -> void:
	add_to_group("obstacle")
	connect("body_entered", Callable(self, "_on_body_entered"))

func _process(delta: float) -> void:
	# 배경 속도 가져오기
	var bg = get_tree().get_first_node_in_group("background")
	var bg_speed = 0.0
	if bg and "scroll_speed" in bg:
		bg_speed = bg.scroll_speed

	# 장애물 이동 = 기본 속도 + 배경 속도
	position.x -= (speed + bg_speed) * delta

	# 플레이어를 지나쳤는지 체크
	var player = get_tree().get_first_node_in_group("player")
	if player and not passed and (position.x + 50.0) < player.position.x:
		passed = true
		var game = get_tree().root.get_node("jumpgame/gamecontroller")
		if game:
			game.on_obstacle_passed()

	if position.x < -200.0:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		game_over()

func game_over() -> void:
	get_tree().reload_current_scene()
