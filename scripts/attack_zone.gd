extends Area2D

@export var warn_time := 0.9
@export var fire_time := 0.55
@export var damage := 20

@onready var rect: ColorRect = $ColorRect
@onready var col: CollisionShape2D = $CollisionShape2D

var _player_inside := false
var _player: Node = null
var _fire_active := false
var _last_damage_time := -9999.0
@export var damage_tick := 0.2

func setup(size: Vector2, warn: float, fire: float, dmg: int, tick: float) -> void:
	warn_time = warn
	fire_time = fire
	damage = dmg
	damage_tick = tick

	rect.size = size
	rect.position = -size * 0.5

	var shape := RectangleShape2D.new()
	shape.size = size
	col.shape = shape

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	rect.color = Color(0, 0, 0, 0.35)
	_run()

func _run() -> void:
	await get_tree().create_timer(warn_time).timeout
	rect.color = Color(1, 0, 0, 0.45)
	_fire_active = true
	var t := 0.0
	while t < fire_time:
		await get_tree().process_frame
		t += get_process_delta_time()
		if _fire_active and _player_inside and _player != null:
			_try_damage_player()
	queue_free()

func _try_damage_player() -> void:
	var now := Time.get_ticks_msec() / 1000.0
	if now - _last_damage_time < damage_tick:
		return
	_last_damage_time = now
	if _player.has_method("hit"):
		_player.hit(damage, Vector2.ZERO)
	elif _player.has_method("take_damage"):
		_player.take_damage(damage)
	elif _player.has_method("damage"):
		_player.damage(damage)

func _on_body_entered(b: Node) -> void:
	if b.is_in_group("player"):
		_player_inside = true
		_player = b

func _on_body_exited(b: Node) -> void:
	if b == _player:
		_player_inside = false
