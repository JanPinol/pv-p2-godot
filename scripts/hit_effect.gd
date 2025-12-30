extends Node2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	anim.play("hit")
	anim.animation_finished.connect(queue_free, CONNECT_ONE_SHOT)
