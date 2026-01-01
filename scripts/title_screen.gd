extends Control

@export var gameplay_scene: PackedScene

@onready var main_menu: VBoxContainer = $CenterContainer/MainMenu
@onready var controls_menu: VBoxContainer = $CenterContainer/ControlsMenu

@onready var play_button: Button = $CenterContainer/MainMenu/PlayButton
@onready var controls_button: Button = $CenterContainer/MainMenu/ControlsButton
@onready var exit_button: Button = $CenterContainer/MainMenu/ExitButton
@onready var back_button: Button = $CenterContainer/ControlsMenu/BackButton

func _ready() -> void:
	AudioManager.play_title_music()
	play_button.pressed.connect(_on_play_pressed)
	controls_button.pressed.connect(_on_controls_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	back_button.pressed.connect(_on_back_pressed)

func _on_play_pressed() -> void:
	AudioManager.stop_music()
	AudioManager.play_play_click()
	gameplay_scene = load("res://scenes/Main.tscn") as PackedScene
	await get_tree().create_timer(1).timeout
	AudioManager.play_dungeon_music()
	get_tree().change_scene_to_packed(gameplay_scene)

func _on_controls_pressed() -> void:
	main_menu.visible = false
	controls_menu.visible = true

func _on_back_pressed() -> void:
	controls_menu.visible = false
	main_menu.visible = true

func _on_exit_pressed() -> void:
	get_tree().quit()
