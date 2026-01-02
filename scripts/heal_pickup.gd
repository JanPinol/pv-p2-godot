extends Area2D

@export var heal_amount: int = 10

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	if body.has_method("heal"):
		body.heal(heal_amount)
	AudioManager.play_heal()
	queue_free()
