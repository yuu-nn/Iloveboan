# ParallaxBackground.gd
extends ParallaxBackground

@export var scroll_speed: float = 200.0

func _ready() -> void:
	add_to_group("background")  # GameController가 찾아서 속도 올림

func _process(delta: float) -> void:
	scroll_offset.x -= scroll_speed * delta
