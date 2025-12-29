extends Node2D

func _ready():
	scale = Vector2(1.8, 0.6)
	position.y = 30

func _draw():
	var color := Color(0.0, 0.0, 0.0, 0.4)
	var radius := 12
	draw_circle(Vector2.ZERO, radius, color)
