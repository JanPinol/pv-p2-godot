extends CharacterBody2D

@export var speed: float = 250.0
@export var max_health: int = 100
@export var kunai_damage: int = 10
@export var shoot_cooldown: float = 0.25
@export var kunai_scene: PackedScene
@export var attack_lock_time: float = 0.18
@export var spawn_dist: float = 14.0

@export var hurt_invuln: float = 0.22
@export var knockback_strength: float = 420.0
@export var knockback_decay: float = 2000.0

var health: int
var _is_dead: bool = false
var _is_attacking: bool = false
var _last_shot_time: float = -9999.0
var _facing_dir: Vector2 = Vector2.DOWN

var _invuln_until: float = -9999.0
var _knock_vel: Vector2 = Vector2.ZERO

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hp_bar = $HealthBar
@onready var col: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	health = max_health
	hp_bar.setup(max_health)
	hp_bar.set_value(health)

func _physics_process(delta: float) -> void:
	if _is_dead:
		_stop_movement()
		return

	var input_vector: Vector2 = Vector2.ZERO
	if not _is_attacking:
		input_vector = _read_movement_input()
		_update_facing_from_input(input_vector)

	_apply_movement(input_vector, delta)

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

func _apply_movement(input_vector: Vector2, delta: float) -> void:
	velocity = input_vector * speed + _knock_vel
	move_and_slide()
	_knock_vel = _knock_vel.move_toward(Vector2.ZERO, knockback_decay * delta)

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
	AudioManager.play_shoot()
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
	hit(amount, Vector2.ZERO)

func hit(amount: int, hit_dir: Vector2) -> bool:
	if _is_dead:
		return false

	var now := _time_now_seconds()
	if now < _invuln_until:
		return false
	_invuln_until = now + hurt_invuln

	if hit_dir != Vector2.ZERO:
		_knock_vel = hit_dir.normalized() * knockback_strength

	AudioManager.play_hit()
	health -= amount
	hp_bar.set_value(health)

	var t := create_tween()
	t.tween_property(anim, "modulate:a", 0.35, 0.05)
	t.tween_property(anim, "modulate:a", 1.0, 0.08)

	if health <= 0:
		die()

	return true

func die() -> void:
	if _is_dead:
		return

	_is_dead = true
	if get_node_or_null("/root/GameState") != null:
		GameState.stop_run()

	AudioManager.stop_music()
	AudioManager.play_gameover()
	anim.sprite_frames.set_animation_loop("dead", false)
	anim.play("dead")
	col.set_deferred("disabled", true)
	hp_bar.visible = false

	await anim.animation_finished
	await AudioManager.sfx_player.finished

	get_tree().change_scene_to_file("res://scenes/GameOver.tscn")
	
func heal(amount: int) -> void:
	if _is_dead:
		return
	health = min(max_health, health + amount)
	hp_bar.set_value(health)
