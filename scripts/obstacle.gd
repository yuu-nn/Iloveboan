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

	# 장애물 이동
	position.x -= (speed + bg_speed) * delta

	# 플레이어 통과 체크
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
	var game = get_tree().root.get_node("jumpgame/gamecontroller")
	if game:
		Globals.score = game.score    # 점수 저장
	call_deferred("_go_to_result")    # 물리 루프가 끝난 뒤 실행
	

func _go_to_result() -> void:
	get_tree().change_scene_to_file("res://scenes/ResultScene.tscn")
