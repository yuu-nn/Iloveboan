extends Node2D

@export var obstacle_scenes: Array[PackedScene]

@export var min_interval := 0.7
@export var max_interval := 1.5

var timer := 0.0
var next_spawn_time := 0.0

func _ready():
	set_next_spawn_time()

func _process(delta):
	timer += delta
	if timer >= next_spawn_time:
		timer = 0
		spawn_obstacle()
		set_next_spawn_time()

func spawn_obstacle():
	if obstacle_scenes.is_empty():
		return
	var scene = obstacle_scenes.pick_random()
	var obs = scene.instantiate()
	add_child(obs)
	obs.position = Vector2(1250, 525)  # 오른쪽에서 등장

func set_next_spawn_time():
	next_spawn_time = randf_range(min_interval, max_interval)
