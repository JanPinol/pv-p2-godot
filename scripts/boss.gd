extends Area2D

signal died

@export var max_health: int = 500
var health: int

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar = $HealthBar

var _hit_fx_cd := false

func _ready() -> void:
	health = max_health
	add_to_group("enemies")
	if health_bar:
		health_bar.setup(max_health)
	if anim:
		anim.play("idle")

func take_damage(amount: int) -> void:
	if health <= 0:
		return

	health = max(health - amount, 0)

	if health_bar:
		health_bar.set_value(health)

	if anim and anim.sprite_frames and anim.sprite_frames.has_animation("hit"):
		_play_hit_fx()

	if health == 0:
		die()

func _play_hit_fx() -> void:
	if _hit_fx_cd:
		return
	_hit_fx_cd = true
	anim.play("hit")
	await get_tree().create_timer(1).timeout
	if health > 0 and is_instance_valid(anim):
		anim.play("idle")
	_hit_fx_cd = false

func die() -> void:
	emit_signal("died")
	queue_free()
