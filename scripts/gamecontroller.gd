extends Node2D

var score: int = 0
var obstacles_passed: int = 0

@export var step_every_n: int = 1           # N개 넘을 때마다 속도 증가
@export var obstacle_step_multiplier: float = 1.1  # 장애물 속도 배율 
@export var background_step_multiplier: float = 1.1 # 배경 속도 배율 

func on_obstacle_passed() -> void:
	# 하나 넘을 때마다 20점
	score += 20
	obstacles_passed += 1
	print("점수:", score, " / 넘긴 개수:", obstacles_passed)

	# N개 넘을 때마다 속도 올리기
	if obstacles_passed % step_every_n == 0:
		_speed_up()

# 속도 증가 처리
func _speed_up() -> void:
	# 배경 속도 살짝만 증가
	for bg in get_tree().get_nodes_in_group("background"):
		if bg.has_method("set_scroll_speed"):   # 함수로 제어하는 경우
			bg.set_scroll_speed(bg.scroll_speed * background_step_multiplier)
		elif "scroll_speed" in bg:              # 그냥 변수 있는 경우
			bg.scroll_speed *= background_step_multiplier
		print("배경 속도:", bg.scroll_speed)

	# 장애물 속도 크게 증가
	for obs in get_tree().get_nodes_in_group("obstacle"):
		if "speed" in obs:
			obs.speed *= obstacle_step_multiplier
			print("장애물 속도:", obs.speed)
