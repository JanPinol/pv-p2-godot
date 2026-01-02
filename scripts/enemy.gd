extends Area2D

signal died

@export var speed: float = 80.0
@export var damage_amount: int = 10
@export var damage_interval: float = 0.6
@export var max_health: int = 50
@export var death_remove_delay: float = 0.6
@export var stop_distance: float = 1.0

@export var player_knockback: float = 420.0

var health: int
var player: CharacterBody2D = null
var _is_dead: bool = false
var _last_damage_time: float = -9999.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hp_bar = $HealthBar
@onready var col: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	health = max_health
	hp_bar.setup(max_health)
	hp_bar.set_value(health)

func _physics_process(delta: float) -> void:
	if _is_dead:
		return
	if player == null:
		return

	_follow_player(delta)
	_try_damage_player()

func _follow_player(delta: float) -> void:
	var to_player: Vector2 = player.global_position - global_position
	if to_player.length() <= stop_distance:
		return

	var move_dir: Vector2 = to_player.normalized()
	global_position += move_dir * speed * delta
	_play_walk_animation(move_dir)

func _try_damage_player() -> void:
	if _damage_on_cooldown():
		return

	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			var dir := (body.global_position - global_position).normalized()
			var applied := false

			if body.has_method("hit"):
				applied = body.hit(damage_amount, dir) if body.hit is Callable else false
			elif body.has_method("damage"):
				body.damage(damage_amount)
				applied = true

			if applied:
				_last_damage_time = _time_now_seconds()
			return

func _damage_on_cooldown() -> bool:
	return _time_now_seconds() - _last_damage_time < damage_interval

func _time_now_seconds() -> float:
	return Time.get_ticks_msec() / 1000.0

func take_damage(amount: int) -> void:
	if _is_dead:
		return

	health -= amount
	hp_bar.set_value(health)

	if health <= 0:
		die()

func die() -> void:
	if _is_dead:
		return

	_is_dead = true
	died.emit()

	if get_node_or_null("/root/GameState") != null:
		GameState.add_kill()

	anim.play("dead")
	hp_bar.visible = false

	col.set_deferred("disabled", true)
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)

	await get_tree().create_timer(death_remove_delay).timeout
	queue_free()

func _play_walk_animation(dir: Vector2) -> void:
	anim.play("walk_" + _direction_suffix(dir))

func _direction_suffix(dir: Vector2) -> String:
	if abs(dir.x) > abs(dir.y):
		return "right" if dir.x > 0.0 else "left"
	return "down" if dir.y > 0.0 else "up"
