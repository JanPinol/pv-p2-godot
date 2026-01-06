extends Area2D

signal died

@export var max_health := 300
@export var damage := 20

@export var first_attack_delay := 1.0

@export var attack_interval_min := 1.2
@export var attack_interval_max := 2.4

@export var warn_time_min := 0.6
@export var warn_time_max := 1.1

@export var fire_time_min := 0.35
@export var fire_time_max := 0.75

@export var damage_tick := 0.2

@export var zones_per_attack_min := 4
@export var zones_per_attack_max := 10

@export var zone_size_min := Vector2(32, 32)
@export var zone_size_max := Vector2(72, 72)

@export var world_path: NodePath
@export var attack_zone_scene: PackedScene

@export var arena_tilemap_path: NodePath
@export var arena_layer := 0
@export var margin_pixels := Vector2(16, 16)

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar = $HealthBar

var health := 0
var dead := false

var _side_right := true
var _resume_anim := "idle"
var _in_hit := false

var _arena_tm: TileMap
var _arena_rect_world := Rect2()

func _ready() -> void:
	randomize()
	health = max_health
	if health_bar != null:
		if health_bar.has_method("setup"):
			health_bar.setup(max_health)
		if health_bar.has_method("set_value"):
			health_bar.set_value(health)

	_arena_tm = get_node_or_null(arena_tilemap_path) as TileMap
	if _arena_tm != null:
		var r: Rect2i = _arena_tm.get_used_rect()
		var top_left_world := _arena_tm.to_global(_arena_tm.map_to_local(r.position))
		var bottom_right_world := _arena_tm.to_global(_arena_tm.map_to_local(r.position + r.size))
		_arena_rect_world = Rect2(top_left_world, bottom_right_world - top_left_world)
		_arena_rect_world.position += margin_pixels
		_arena_rect_world.size -= margin_pixels * 2.0
	else:
		_arena_rect_world = get_viewport().get_visible_rect()

	_configure_animation_loops()
	if anim != null:
		anim.animation_finished.connect(_on_anim_finished)

	_play("idle")
	call_deferred("_loop")

func _loop() -> void:
	await get_tree().create_timer(first_attack_delay).timeout
	while not dead:
		await _do_attack()
		var interval := randf_range(attack_interval_min, attack_interval_max)
		await get_tree().create_timer(max(interval, 0.01)).timeout

func _do_attack() -> void:
	if attack_zone_scene == null:
		return

	var warn_t := randf_range(warn_time_min, warn_time_max)
	var fire_t := randf_range(fire_time_min, fire_time_max)

	var zones := randi_range(zones_per_attack_min, zones_per_attack_max)
	zones = max(zones, 0)

	var size := Vector2(
		randf_range(zone_size_min.x, zone_size_max.x),
		randf_range(zone_size_min.y, zone_size_max.y)
	)

	var charge_anim := "charge_right" if _side_right else "charge_left"
	var attack_anim := "attack_right" if _side_right else "attack_left"
	_side_right = not _side_right

	_resume_anim = charge_anim
	_play(charge_anim)

	var world := get_node_or_null(world_path)
	if world == null:
		world = get_tree().current_scene

	var r := _arena_rect_world
	if r.size.x <= 0.0 or r.size.y <= 0.0:
		r = get_viewport().get_visible_rect()

	for i in range(zones):
		var z = attack_zone_scene.instantiate()
		world.add_child(z)
		z.global_position = Vector2(
			randf_range(r.position.x, r.position.x + r.size.x),
			randf_range(r.position.y, r.position.y + r.size.y)
		)
		if z.has_method("setup"):
			z.setup(size, warn_t, fire_t, damage, damage_tick)

	await get_tree().create_timer(max(warn_t, 0.01)).timeout
	_resume_anim = attack_anim
	_play(attack_anim)

	await get_tree().create_timer(max(fire_t, 0.01)).timeout
	_resume_anim = "idle"
	_play("idle")

func take_damage(amount: int) -> void:
	if dead:
		return
	health -= amount
	_play_hit()
	if health_bar != null and health_bar.has_method("set_value"):
		health_bar.set_value(health)
	if health <= 0:
		_die()

func _die() -> void:
	if dead:
		return
	dead = true
	_play("dead")
	died.emit()
	await get_tree().create_timer(0.2).timeout
	queue_free()

func _play_hit() -> void:
	if anim == null or anim.sprite_frames == null:
		return
	if not anim.sprite_frames.has_animation("hit"):
		return
	if _in_hit:
		return
	_in_hit = true
	anim.play("hit")

func _on_anim_finished() -> void:
	if anim == null:
		return
	if anim.animation == "hit":
		_in_hit = false
		_play(_resume_anim if _resume_anim != "" else "idle")

func _play(anim_name: String) -> void:
	if anim == null or anim.sprite_frames == null:
		return
	if not anim.sprite_frames.has_animation(anim_name):
		return
	anim.play(anim_name)

func _configure_animation_loops() -> void:
	if anim == null or anim.sprite_frames == null:
		return
	var sf := anim.sprite_frames
	if sf.has_animation("idle"):
		sf.set_animation_loop("idle", true)
	if sf.has_animation("hit"):
		sf.set_animation_loop("hit", false)
	if sf.has_animation("charge_left"):
		sf.set_animation_loop("charge_left", false)
	if sf.has_animation("charge_right"):
		sf.set_animation_loop("charge_right", false)
	if sf.has_animation("attack_left"):
		sf.set_animation_loop("attack_left", false)
	if sf.has_animation("attack_right"):
		sf.set_animation_loop("attack_right", false)
	if sf.has_animation("dead"):
		sf.set_animation_loop("dead", false)
