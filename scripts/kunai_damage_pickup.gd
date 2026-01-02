extends Area2D

@export var amount: int = 5

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	if body.has_method("add_kunai_damage"):
		AudioManager.play_powerup()
		body.add_kunai_damage(amount)
	queue_free()
