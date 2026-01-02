extends CanvasLayer

@export var score_label_path: NodePath

var _label: Label

func _ready() -> void:
	_label = get_node_or_null(score_label_path) as Label
	GameState.updated.connect(_on_updated)
	GameState.start_run()

func _on_updated(kills: int, best: int) -> void:
	if _label == null:
		return
	_label.text = "KILLS:    %d        BEST:    %d" % [kills, best]
