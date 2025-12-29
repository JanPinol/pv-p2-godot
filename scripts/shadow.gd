extends Node2D

@export var base_radius: float = 10.0
@export var shadow_scale: Vector2 = Vector2(2.0, 0.6)
@export var y_offset: float = 10.0
@export var shadow_color: Color = Color(0, 0, 0, 0.4)

func _ready() -> void:
	scale = shadow_scale
	position = Vector2(0, y_offset)

func _draw() -> void:
	draw_circle(Vector2.ZERO, base_radius, shadow_color)
