extends CharacterBody2D   # Node2D 대신 CharacterBody2D로 바꿔야 충돌/점프 됨

@onready var sprite1 := $뛰는거지
@onready var sprite2 := $거지

# 점프/중력 관련
@export var gravity := 6000.0
@export var jump_force := -1800.0

# 애니메이션 관련
var timer := 0.0
var frame_time := 0.15
var toggle := true

func _physics_process(delta: float) -> void:
	# 중력
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# 점프 (스페이스바)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_force

	# 이동 적용
	move_and_slide()

	# 달리기 애니메이션 (땅 위일 때만)
	if is_on_floor():
		timer += delta
		if timer >= frame_time:
			timer = 0.0
			toggle = !toggle
			sprite1.visible = toggle
			sprite2.visible = !toggle
	else:
		# 점프 중일 땐 sprite1만 보이게
		sprite1.visible = true
		sprite2.visible = false
