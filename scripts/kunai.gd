extends Area2D

@export var speed: float = 400.0
@export var damage: int = 10
@export var lifetime: float = 1.5

var _direction: Vector2 = Vector2.DOWN
var _has_hit: bool = false

func setup(direction: Vector2) -> void:
	_set_direction(direction)

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	get_tree().create_timer(lifetime).timeout.connect(_despawn)

func _physics_process(delta: float) -> void:
	_move_forward(delta)

func _set_direction(direction: Vector2) -> void:
	_direction = direction.normalized()
	if _direction == Vector2.ZERO:
		_direction = Vector2.DOWN
	rotation = _direction.angle()

func _move_forward(delta: float) -> void:
	global_position += _direction * speed * delta

func _on_area_entered(area: Area2D) -> void:
	if _has_hit:
		return
	if not area.is_in_group("enemies"):
		return
	if not area.has_method("take_damage"):
		return

	_has_hit = true
	area.take_damage(damage)
	_despawn()

func _despawn() -> void:
	queue_free()
