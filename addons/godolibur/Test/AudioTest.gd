extends Node2D

@onready var audio_manager = $AudioManager

func _ready():
	
	#audio_manager.play_music(preload("res://Assets/audio/BGM/ao_oni_chase.wav"))
	pass
	
	await get_tree().create_timer(1).timeout
	
	#audio_manager.crossfade_music(preload("res://Assets/audio/BGM/mansion.ogg"))
	pass
