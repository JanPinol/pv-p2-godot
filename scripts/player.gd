extends CharacterBody2D

@export var speed: float = 250.0
@export var max_health: int = 100
@export var kunai_damage: int = 10
@export var shoot_cooldown: float = 0.25
@export var kunai_scene: PackedScene
@export var attack_lock_time: float = 0.18
@export var spawn_dist: float = 14.0

var health: int
var _is_dead: bool = false
var _is_attacking: bool = false
var _last_shot_time: float = -9999.0
var _facing_dir: Vector2 = Vector2.DOWN

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hp_bar = $HealthBar
@onready var col: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	health = max_health
	hp_bar.setup(max_health)
	hp_bar.set_value(health)

func _physics_process(_delta: float) -> void:
	if _is_dead:
		_stop_movement()
		return

	var input_vector: Vector2 = Vector2.ZERO
	if not _is_attacking:
		input_vector = _read_movement_input()
		_update_facing_from_input(input_vector)

	_apply_movement(input_vector)

	if Input.is_action_just_pressed("attack"):
		_try_throw_kunai()

	if _is_attacking:
		return

	_update_movement_animation(input_vector)

func _read_movement_input() -> Vector2:
	return Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

func _update_facing_from_input(input_vector: Vector2) -> void:
	if input_vector != Vector2.ZERO:
		_facing_dir = _to_4dir(input_vector)

func _apply_movement(input_vector: Vector2) -> void:
	velocity = input_vector * speed
	move_and_slide()

func _stop_movement() -> void:
	velocity = Vector2.ZERO
	move_and_slide()

func _update_movement_animation(input_vector: Vector2) -> void:
	if input_vector == Vector2.ZERO:
		anim.play("idle")
		return
	anim.play("walk_" + _direction_suffix(_facing_dir))

func _try_throw_kunai() -> void:
	if kunai_scene == null:
		return
	if _throw_on_cooldown():
		return

	_last_shot_time = _time_now_seconds()
	_start_attack_animation()

	_spawn_kunai()

	get_tree().create_timer(attack_lock_time).timeout.connect(_end_attack)

func _throw_on_cooldown() -> bool:
	return _time_now_seconds() - _last_shot_time < shoot_cooldown

func _start_attack_animation() -> void:
	_is_attacking = true
	anim.play("attack_" + _direction_suffix(_facing_dir))

func _end_attack() -> void:
	_is_attacking = false

func _spawn_kunai() -> void:
	var kunai = kunai_scene.instantiate()
	get_tree().current_scene.add_child(kunai)

	kunai.global_position = global_position + _facing_dir * spawn_dist
	kunai.setup(_facing_dir)
	kunai.damage = kunai_damage

func _to_4dir(v: Vector2) -> Vector2:
	if abs(v.x) > abs(v.y):
		return Vector2.RIGHT if v.x > 0.0 else Vector2.LEFT
	return Vector2.DOWN if v.y > 0.0 else Vector2.UP

func _direction_suffix(dir: Vector2) -> String:
	if dir == Vector2.RIGHT:
		return "right"
	if dir == Vector2.LEFT:
		return "left"
	if dir == Vector2.UP:
		return "up"
	return "down"

func _time_now_seconds() -> float:
	return Time.get_ticks_msec() / 1000.0

func damage(amount: int) -> void:
	if _is_dead:
		return

	health -= amount
	hp_bar.set_value(health)

	if health <= 0:
		die()

func die() -> void:
	_is_dead = true
	anim.play("dead")
	col.set_deferred("disabled", true)
	hp_bar.visible = false
