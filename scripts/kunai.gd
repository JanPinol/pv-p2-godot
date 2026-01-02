extends Area2D

@export var speed: float = 400.0
@export var damage: int = 10
@export var lifetime: float = 1.5
@export var hit_effect_scene: PackedScene
@export var hit_effect_offset: Vector2 = Vector2.ZERO

var piercing: int = 0
var _direction: Vector2 = Vector2.DOWN

func setup(direction: Vector2) -> void:
	_set_direction(direction)

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	global_position += _direction * speed * delta

func _set_direction(direction: Vector2) -> void:
	_direction = direction.normalized()
	if _direction == Vector2.ZERO:
		_direction = Vector2.DOWN
	rotation = _direction.angle()

func _on_area_entered(area: Area2D) -> void:
	if not area.is_in_group("enemies"):
		return
	if not area.has_method("take_damage"):
		return

	AudioManager.play_impact()
	_spawn_hit_effect(global_position + hit_effect_offset)
	area.take_damage(damage)

	if piercing > 0:
		piercing -= 1
	else:
		queue_free()

func _spawn_hit_effect(pos: Vector2) -> void:
	if hit_effect_scene == null:
		return
	var fx = hit_effect_scene.instantiate()
	get_tree().current_scene.add_child(fx)
	fx.global_position = pos
