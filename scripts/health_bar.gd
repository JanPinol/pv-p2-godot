extends Node2D

@onready var bar: TextureProgressBar = $Bar

func setup(max_value: int) -> void:
	bar.max_value = max_value
	bar.value = max_value

func set_value(v: int) -> void:
	bar.value = clamp(v, 0, int(bar.max_value))
