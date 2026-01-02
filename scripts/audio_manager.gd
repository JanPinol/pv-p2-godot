extends Node

var TITLE_MUSIC := preload("res://audio/title_screen.ogg")
var GAME_MUSIC  := preload("res://audio/play.wav")
var SFX_GAMEOVER := preload("res://audio/game_over.wav")
var SFX_IMPACT   := preload("res://audio/kunai_impact.wav")
var DUNGEON_MUSIC := preload("res://audio/dungeon.ogg")
var SFX_HIT := preload("res://audio/hit.wav")
var END_THEME := preload("res://audio/end_theme.ogg")
var SFX_SHOOT := preload("res://audio/shoot.wav")
var HEAL := preload("res://audio/heal.wav")
var POWERUP := preload("res://audio/power_up.wav")

var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	sfx_player = AudioStreamPlayer.new()
	add_child(music_player)
	add_child(sfx_player)

func _set_loop(stream: AudioStream, loop: bool) -> void:
	if stream is AudioStreamOggVorbis:
		stream.loop = loop
	elif stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD if loop else AudioStreamWAV.LOOP_DISABLED

func play_title_music() -> void:
	_play_music(TITLE_MUSIC, true)

func play_game_music() -> void:
	_play_music(GAME_MUSIC, true)

func stop_music() -> void:
	if music_player.playing:
		music_player.stop()

func play_gameover() -> void:
	stop_music()
	play_sfx(SFX_GAMEOVER)

func play_impact() -> void:
	play_sfx(SFX_IMPACT)

func _play_music(stream: AudioStream, loop: bool) -> void:
	if music_player.stream == stream and music_player.playing:
		return
	music_player.stop()
	_set_loop(stream, loop)
	music_player.stream = stream
	music_player.play()

func play_sfx(stream: AudioStream) -> void:
	sfx_player.stream = stream
	sfx_player.play()
	
func play_dungeon_music() -> void:
	_play_music(DUNGEON_MUSIC, true)

func play_hit() -> void:
	play_sfx(SFX_HIT)
	
func play_play_click() -> void:
	play_sfx(GAME_MUSIC)
	
func play_end_theme() -> void:
	_play_music(END_THEME, true)
	
func play_shoot() -> void:
	play_sfx(SFX_SHOOT)
	
func play_heal() -> void:
	play_sfx(HEAL)

func play_powerup() -> void:
	play_sfx(POWERUP)
