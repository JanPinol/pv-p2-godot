extends Node2D

@export var enemy_scene: PackedScene
@export var tilemap_path: NodePath
@export var tilemap_layer: int = 0
@export var wave_label_path: NodePath
@export var world_path: NodePath

@export var time_between_waves: float = 1.25

var wave: int = 0
var alive: int = 0

var _label: Label
var _tilemap: TileMap
var _cells: Array[Vector2i] = []
var _world: Node

var _fib_a: int = 1
var _fib_b: int = 1

func _ready() -> void:
	randomize()
	_label = get_node_or_null(wave_label_path) as Label
	_tilemap = get_node_or_null(tilemap_path) as TileMap
	_world = get_node_or_null(world_path)

	if _tilemap != null:
		var layers_count := _tilemap.get_layers_count()
		if tilemap_layer < 0 or tilemap_layer >= layers_count:
			tilemap_layer = 0
		_cells = _tilemap.get_used_cells(tilemap_layer)

	call_deferred("_start_next_wave")

func _start_next_wave() -> void:
	wave += 1
	_update_wave_text()

	var to_spawn := _next_fib_count()
	alive = 0

	for i in to_spawn:
		_spawn_enemy()

func _next_fib_count() -> int:
	if wave == 1:
		_fib_a = 1
		_fib_b = 1
		return 1
	if wave == 2:
		return 1

	var n := _fib_a + _fib_b
	_fib_a = _fib_b
	_fib_b = n
	return n

func _spawn_enemy() -> void:
	if enemy_scene == null:
		return
	if _tilemap == null:
		return
	if _cells.is_empty():
		return

	var pos: Vector2 = _random_tile_position()

	var e := enemy_scene.instantiate()

	if _world != null:
		_world.call_deferred("add_child", e)
	else:
		get_tree().current_scene.call_deferred("add_child", e)

	e.global_position = pos

	if e.has_signal("died"):
		e.died.connect(_on_enemy_died)

	alive += 1

func _random_tile_position() -> Vector2:
	var cell: Vector2i = _cells[randi() % _cells.size()]
	return _tilemap.to_global(_tilemap.map_to_local(cell))

func _on_enemy_died() -> void:
	alive -= 1
	if alive <= 0:
		await get_tree().create_timer(time_between_waves).timeout
		_start_next_wave()

func _update_wave_text() -> void:
	if _label == null:
		return
	_label.text = "WAVE    " + str(wave)
