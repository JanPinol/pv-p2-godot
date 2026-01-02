extends Node

signal updated(kills: int, best_score: int)

var kills: int = 0
var best_score: int = 0

func start_run() -> void:
	kills = 0
	_emit()

func stop_run() -> void:
	if kills > best_score:
		best_score = kills
	_emit()

func add_kill() -> void:
	kills += 1
	_emit()

func _emit() -> void:
	updated.emit(kills, best_score)
