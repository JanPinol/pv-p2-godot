extends Control

@onready var retry_button: Button = $CenterContainer/VBoxContainer/RetryButton
@onready var menu_button: Button = $CenterContainer/VBoxContainer/MainMenuButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton

func _ready() -> void:
	AudioManager.play_end_theme()
	retry_button.pressed.connect(_on_retry)
	menu_button.pressed.connect(_on_menu)
	quit_button.pressed.connect(_on_quit)

func _on_retry() -> void:
	AudioManager.stop_music()
	AudioManager.play_play_click()
	await get_tree().create_timer(1).timeout
	AudioManager.play_dungeon_music()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_menu() -> void:
	AudioManager.play_title_music()
	get_tree().change_scene_to_file("res://scenes/TitleScreen.tscn")

func _on_quit() -> void:
	get_tree().quit()
