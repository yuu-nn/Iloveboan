extends Node2D

var score: int = 0
var obstacles_passed: int = 0
@onready var score_label: Label = get_node("../UI/ScoreLabel")
@onready var quiz_ui: Control = get_node("../UI/QuizUI")

# 난이도/속도
@export var step_every_n: int = 1
@export var obstacle_step_multiplier: float = 1.1
@export var background_step_multiplier: float = 1.1

# 퀴즈 관련
@export var quiz_min_gap_passes := 4
@export var quiz_chance_per_pass := 0.25
var quiz_active := false
var _passes_since_quiz := 0

func _ready() -> void:
	randomize()
	if quiz_ui:
		quiz_ui.visible = false
	if score_label:
		score_label.text = str(score)

func on_obstacle_passed() -> void:
	if quiz_active:
		return
	score += 20
	obstacles_passed += 1
	_passes_since_quiz += 1
	if score_label:
		score_label.text = str(score)

	if obstacles_passed % step_every_n == 0:
		_speed_up()

	if _passes_since_quiz >= quiz_min_gap_passes and randf() < quiz_chance_per_pass:
		_show_quiz()

func _speed_up() -> void:
	for bg in get_tree().get_nodes_in_group("background"):
		if bg.has_method("set_scroll_speed"):
			bg.set_scroll_speed(bg.scroll_speed * background_step_multiplier)
		elif "scroll_speed" in bg:
			bg.scroll_speed *= background_step_multiplier

	for obs in get_tree().get_nodes_in_group("obstacle"):
		if "speed" in obs:
			obs.speed *= obstacle_step_multiplier

func _show_quiz() -> void:
	quiz_active = true
	_passes_since_quiz = 0
	_pause_spawning()
	_clear_obstacles()

	var q = _quiz_pool.pick_random() as Dictionary
	quiz_ui.call("show_question", q, Callable(self, "_on_quiz_result"))

func _on_quiz_result(correct: bool) -> void:
	if correct:
		quiz_active = false
		_resume_spawning()
		score += 10
		if score_label:
			score_label.text = str(score)
	else:
		_game_over()

func _pause_spawning() -> void:
	for s in get_tree().get_nodes_in_group("spawner"):
		s.set_process(false)
		s.set_physics_process(false)

func _resume_spawning() -> void:
	for s in get_tree().get_nodes_in_group("spawner"):
		s.set_process(true)
		s.set_physics_process(true)

func _clear_obstacles() -> void:
	for obs in get_tree().get_nodes_in_group("obstacle"):
		obs.queue_free()

func _game_over() -> void:
	get_tree().reload_current_scene()

# -----------------------
#  퀴즈 데이터
# -----------------------
var _quiz_pool := [
	{"question":"내 이름·학교·학년을 합친 닉네임은 안전하다.", "type":"ox", "answer":false},
	{"question":"더 위험한 정보는?", "type":"multi", "options":["내가 좋아하는 만화","우리 집 주소"], "answer":1},

	{"question":"비밀번호는 길기만 하면 안전하다.", "type":"ox", "answer":false},
	{"question":"더 안전한 비밀번호는?", "type":"multi", "options":["abcd1234","Abcd!1234"], "answer":1},

	{"question":"급하게 돈이나 계좌를 요구하면 의심해야 한다.", "type":"ox", "answer":true},
	{"question":"피싱일 가능성이 더 높은 메시지는?", "type":"multi", "options":["오늘 뭐 먹을래?","엄마인데 빨리 돈 보내"], "answer":1},

	{"question":"친구 사진은 허락 없이 올려도 괜찮다.", "type":"ox", "answer":false},
	{"question":"저작권을 지키는 행동은?", "type":"multi", "options":["인터넷 노래 그냥 올리기","허락받고 올리기"], "answer":1},

	{"question":"올린 글·사진은 지워도 흔적이 남을 수 있다.", "type":"ox", "answer":true},
	{"question":"더 문제가 될 행동은?", "type":"multi", "options":["여행 사진 올리기","욕설 글 올리기"], "answer":1},

	{"question":"필요 없는 권한을 요구하는 앱은 위험할 수 있다.", "type":"ox", "answer":true},
	{"question":"앱 설치 전 가장 안전한 방법은?", "type":"multi", "options":["부모님께 먼저 물어본다","그냥 설치한다"], "answer":0},

	{"question":"PC방에서 자동 로그인은 위험하다.", "type":"ox", "answer":true},
	{"question":"공용 컴퓨터 사용 후 올바른 행동은?", "type":"multi", "options":["그냥 전원 끄기","로그아웃하기"], "answer":1},

	{"question":"휴대폰에 잠금이 없으면 다른 사람이 내 정보를 볼 수 있다.", "type":"ox", "answer":true},
	{"question":"더 안전한 잠금은?", "type":"multi", "options":["1111","지문 인식"], "answer":1},

	{"question":"집이 보이는 사진은 올려도 된다.", "type":"ox", "answer":false},
	{"question":"올려도 비교적 안전한 사진은?", "type":"multi", "options":["집 현관문 사진","내가 먹은 음식 사진"], "answer":1},

	{"question":"온라인 친구에게 개인정보를 말하면 안 된다.", "type":"ox", "answer":true},
	{"question":"더 위험한 질문은?", "type":"multi", "options":["좋아하는 색 뭐야?","너네 집 어디야?"], "answer":1},
	
	{"question":"'아이템 줄게, 계정 알려줘'는 사기다.", "type":"ox", "answer":true},
	{"question":"더 안전한 습관은?", "type":"multi", "options":["무료 아이템 사이트 로그인","공식 방법으로 거래"], "answer":1},

	{"question":"내가 안 보낸 메시지가 갔으면 해킹일 수 있다.", "type":"ox", "answer":true},
	{"question":"해킹 의심 시 해야 할 일은?", "type":"multi", "options":["비밀번호 변경","그냥 무시"], "answer":0},

	{"question":"모르는 사람이 보낸 파일은 열면 위험하다.", "type":"ox", "answer":true},
	{"question":"더 안전한 행동은?", "type":"multi", "options":["부모님께 먼저 보여준다","그냥 다운로드"], "answer":0},

	{"question":"모든 사이트에 같은 비밀번호는 안전하다.", "type":"ox", "answer":false},
	{"question":"더 안전한 습관은?", "type":"multi", "options":["사이트마다 다르게 쓰기","같은 비번 반복 사용"], "answer":0},

	{"question":"출처 모르는 USB는 위험할 수 있다.", "type":"ox", "answer":true},
	{"question":"더 안전한 행동은?", "type":"multi", "options":["그냥 꽂아본다","부모님께 보여준다"], "answer":1},

	{"question":"'무료 영화' 사이트는 대부분 안전하다.", "type":"ox", "answer":false},
	{"question":"불법 다운로드의 위험은?", "type":"multi", "options":["바이러스 감염","무료 아이템 받기"], "answer":0},

	{"question":"'당첨되셨습니다!'는 대부분 사기일 수 있다.", "type":"ox", "answer":true},
	{"question":"광고 메시지를 받았을 때 더 안전한 행동은?", "type":"multi", "options":["부모님께 보여준다","개인정보 입력"], "answer":0},

	{"question":"모르는 사람이 개인정보를 물어보면 알려줘도 된다.", "type":"ox", "answer":false},
	{"question":"올바른 행동은?", "type":"multi", "options":["부모님께 보여준다","바로 대답한다"], "answer":0},

	{"question":"공용 컴퓨터에 개인정보 저장은 안전하다.", "type":"ox", "answer":false},
	{"question":"학교 컴퓨터 사용 후 더 안전한 행동은?", "type":"multi", "options":["로그아웃·기록삭제","그냥 끈다"], "answer":0},

	{"question":"닉네임에 이름·학교·학년을 넣는 건 위험하다.", "type":"ox", "answer":true},
	{"question":"더 안전한 닉네임은?", "type":"multi", "options":["민지2005서울초","블루드래곤77"], "answer":1},

	{"question":"사진 속에 학교 간판이 찍혀 있어도 올려도 된다.", "type":"ox", "answer":false},
	{"question":"사진 올리기 전 더 안전한 방법은?", "type":"multi",
	 "options":["그냥 올린다","부모님께 먼저 보여준다"], "answer":1},

	{"question":"비밀번호 없는 무료 와이파이는 항상 안전하다.", "type":"ox", "answer":false},
	{"question":"안전하게 인터넷을 쓰는 방법은?", "type":"multi",
	 "options":["중요 로그인은 피한다","아무 와이파이나 그냥 쓴다"], "answer":0},

	{"question":"게임을 업데이트하지 않으면 해킹 위험이 커진다.", "type":"ox", "answer":true},
	{"question":"더 안전한 습관은?", "type":"multi",
	 "options":["업데이트를 미룬다","최신 버전으로 업데이트한다"], "answer":1},

	{"question":"유튜브 댓글에 내 전화번호를 써도 된다.", "type":"ox", "answer":false},
	{"question":"댓글에 써도 안전한 것은?", "type":"multi",
	 "options":["전화번호","내가 좋아하는 음식"], "answer":1},

	{"question":"누군지 모르는 사람이 친구 추가를 해도 수락하면 된다.", "type":"ox", "answer":false},
	{"question":"모르는 사람이 친구 추가하면?", "type":"multi",
	 "options":["무조건 수락한다","부모님께 물어본다"], "answer":1},
]
