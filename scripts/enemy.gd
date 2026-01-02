extends Area2D

signal died

@export var speed: float = 80.0
@export var damage_amount: int = 10
@export var damage_interval: float = 0.6
@export var max_health: int = 50
@export var death_remove_delay: float = 0.6
@export var stop_distance: float = 1.0

@export var loot_table: Array[LootEntry] = []
@export_range(0.0, 100.0, 0.1) var no_drop_weight: float = 70.0
@export var drop_offset: Vector2 = Vector2.ZERO

var health: int
var player: CharacterBody2D
var _is_dead: bool = false
var _last_damage_time: float = -9999.0
var _player_in_range: bool = false

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hp_bar = $HealthBar
@onready var col: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	_rng.randomize()
	player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	health = max_health
	hp_bar.setup(max_health)
	hp_bar.set_value(health)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

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

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player_in_range = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_in_range = false

func _try_damage_player() -> void:
	if not _player_in_range:
		return
	if _damage_on_cooldown():
		return
	if player == null:
		return

	var dir: Vector2 = (player.global_position - global_position).normalized()
	var applied: bool = false

	if player.has_method("hit"):
		applied = player.hit(damage_amount, dir)
	elif player.has_method("damage"):
		player.damage(damage_amount)
		applied = true

	if applied:
		_last_damage_time = _time_now_seconds()

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

	_try_drop_loot()

	queue_free()

func _try_drop_loot() -> void:
	var entry := _roll_loot_entry()
	if entry == null:
		return
	if entry.scene == null:
		return

	var item := entry.scene.instantiate()
	item.global_position = global_position + drop_offset

	var world := get_tree().current_scene.get_node_or_null("World")
	if world != null:
		world.call_deferred("add_child", item)
	else:
		get_tree().current_scene.call_deferred("add_child", item)

func _roll_loot_entry() -> LootEntry:
	var total: float = max(0.0, no_drop_weight)

	for e in loot_table:
		if e == null:
			continue
		if e.scene == null:
			continue
		if e.weight <= 0.0:
			continue
		total += e.weight

	if total <= 0.0:
		return null

	var r: float = _rng.randf() * total
	var acc: float = max(0.0, no_drop_weight)

	if r <= acc:
		return null

	for e in loot_table:
		if e == null:
			continue
		if e.scene == null:
			continue
		if e.weight <= 0.0:
			continue
		acc += e.weight
		if r <= acc:
			return e

	return null

func _play_walk_animation(dir: Vector2) -> void:
	anim.play("walk_" + _direction_suffix(dir))

func _direction_suffix(dir: Vector2) -> String:
	if abs(dir.x) > abs(dir.y):
		return "right" if dir.x > 0.0 else "left"
	return "down" if dir.y > 0.0 else "up"
