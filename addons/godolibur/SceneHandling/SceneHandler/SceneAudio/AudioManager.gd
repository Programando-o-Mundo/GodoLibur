extends Node
class_name GameAudioManager

@onready var music = $SceneTheme
@onready var sfx = $SFXPlayer

var is_music_paused : bool = false : set = pause_music
var is_sfx_paused : bool = false : set = pause_sfx

func pause_music(value) -> void:
	music.stream_paused = value
	
func pause_sfx(value) -> void:
	sfx.stream_paused = value

func crossfade_music(music_stream: AudioStream) -> void:
	
	if music.stream == null:
		return
	
	await fade_out_current_music()
	
	play_music(music_stream)
	
	await fade_in_current_music(false)

func fade_out_current_music(wait_to_finish: bool = true) -> void:
	var tween = create_tween()
	tween.tween_property(
		music,
		"volume_db",
		-80,
		1.5,
	).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)

	tween.play()
	
	if wait_to_finish:
		await tween.finished
		
func fade_in_current_music(wait_to_finish: bool = true) -> void:

	var tween = create_tween()
	tween.tween_property(
		music,
		"volume_db",
		0,
		1,
	).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)

	tween.play()
	
	if wait_to_finish:
		await tween.finished
		
func play_music(music_stream: AudioStream) -> void:
	if music.stream != music_stream:
		music.stream = music_stream
		
		music.play()

func play_sfx(sound: AudioStream) -> void:

	sfx.stream = sound
	sfx.play()
