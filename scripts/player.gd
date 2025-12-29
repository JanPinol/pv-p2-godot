extends CharacterBody2D

@export var speed: float = 250.0

@export var max_health: int = 100
var health: int

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	health = max_health


func _physics_process(_delta: float) -> void:
	var input_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	velocity = input_vector * speed
	move_and_slide()

	if input_vector == Vector2.ZERO:
		anim.play("idle")
		return

	if abs(input_vector.x) > abs(input_vector.y):
		if input_vector.x > 0.0:
			anim.play("walk_right")
		else:
			anim.play("walk_left")
	else:
		if input_vector.y > 0.0:
			anim.play("walk_down")
		else:
			anim.play("walk_up")

func damage(amount: int) -> void:
	health -= amount
	print("Player damaged! Current HP:", health)

	if health <= 0:
		die()

func die() -> void:
	print("PLAYER DEAD")
