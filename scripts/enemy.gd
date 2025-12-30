extends Area2D

@export var speed: float = 80.0
@export var damage_amount: int = 10
@export var damage_interval: float = 0.6
@export var max_health: int = 50

var health: int
var player: CharacterBody2D
var _last_damage_time: float = 0.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	health = max_health

func _physics_process(delta: float) -> void:
	if player == null:
		return

	var dir: Vector2 = player.global_position - global_position

	if dir.length() > 1.0:
		dir = dir.normalized()
		global_position += dir * speed * delta
		_update_animation(dir)

	_check_damage()

func _check_damage() -> void:
	var now: float = Time.get_ticks_msec() / 1000.0

	for body in get_overlapping_bodies():
		if body.is_in_group("player") and body.has_method("damage"):
			if now - _last_damage_time >= damage_interval:
				body.damage(damage_amount)
				_last_damage_time = now
				break

func take_damage(amount: int) -> void:
	health -= amount
	print("Enemy takes damage! Current health:", health)
	if health <= 0:
		die()

func die() -> void:
	print("Enemy died.")
	queue_free()

func _update_animation(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0.0:
			anim.play("walk_right")
		else:
			anim.play("walk_left")
	else:
		if dir.y > 0.0:
			anim.play("walk_down")
		else:
			anim.play("walk_up")
