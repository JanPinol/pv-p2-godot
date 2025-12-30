extends CharacterBody2D

@export var speed: float = 250.0
@export var max_health: int = 100
@export var attack_damage: int = 25
@export var attack_duration: float = 0.15

var health: int
var _is_attacking: bool = false
var _attack_dir: Vector2 = Vector2.DOWN

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var attack_shape: CollisionShape2D = $AttackHitbox/CollisionShape2D
@onready var hp_bar = $HealthBar


func _ready() -> void:
	health = max_health
	hp_bar.setup(max_health)
	hp_bar.set_value(health)
	attack_shape.disabled = true

func _physics_process(_delta: float) -> void:
	var input_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	velocity = Vector2.ZERO if _is_attacking else input_vector * speed
	move_and_slide()

	if Input.is_action_just_pressed("attack") and not _is_attacking:
		_attack_dir = _get_attack_direction(input_vector)
		_start_attack()
		return

	if not _is_attacking:
		if input_vector == Vector2.ZERO:
			anim.play("idle")
		else:
			_play_walk_animation(input_vector)

func _get_attack_direction(input_vector: Vector2) -> Vector2:
	if input_vector == Vector2.ZERO:
		return Vector2.DOWN

	if abs(input_vector.x) > abs(input_vector.y):
		return Vector2.RIGHT if input_vector.x > 0.0 else Vector2.LEFT
	else:
		return Vector2.DOWN if input_vector.y > 0.0 else Vector2.UP

func _start_attack() -> void:
	_is_attacking = true
	_play_attack_animation()

	_position_attack_hitbox()
	attack_shape.disabled = false

	await get_tree().process_frame
	_apply_attack_damage()

	await get_tree().create_timer(attack_duration).timeout
	attack_shape.disabled = true
	_is_attacking = false

func _play_walk_animation(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		anim.play("walk_right" if dir.x > 0.0 else "walk_left")
	else:
		anim.play("walk_down" if dir.y > 0.0 else "walk_up")

func _play_attack_animation() -> void:
	if _attack_dir == Vector2.RIGHT:
		anim.play("attack_right")
	elif _attack_dir == Vector2.LEFT:
		anim.play("attack_left")
	elif _attack_dir == Vector2.UP:
		anim.play("attack_up")
	else:
		anim.play("attack_down")

func _position_attack_hitbox() -> void:
	var offset := Vector2.ZERO

	if _attack_dir == Vector2.RIGHT:
		offset = Vector2(38, 0)
	elif _attack_dir == Vector2.LEFT:
		offset = Vector2(-38, 0)
	elif _attack_dir == Vector2.UP:
		offset = Vector2(0, -38)
	else:
		offset = Vector2(0, 38)

	attack_hitbox.position = offset

func _apply_attack_damage() -> void:
	for area in attack_hitbox.get_overlapping_areas():
		if area.is_in_group("enemies") and area.has_method("take_damage"):
			area.take_damage(attack_damage)

func damage(amount: int) -> void:
	health -= amount
	hp_bar.set_value(health)
	print("Player takes damage! Current health:", health)
	if health <= 0:
		die()

func die() -> void:
	print("Player died.")
	queue_free()
