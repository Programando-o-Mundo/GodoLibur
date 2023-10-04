@icon("res://Assets/components_icons/cinematic_cutcene.png")
extends AnimationPlayer
class_name CinematicCutcene
## A node for creating cutcenes that contains a variety of action
signal current_step_finished(result)

signal show_dialog_box(text, dialog_background)
signal change_background_color_visibility(visible, color)

signal set_cutcene_state(in_cutcene)
signal change_map(destination, door_name, player_y)

signal is_music_paused(status)
signal fade_out_music()
signal fade_in_music()

@export var first_cutcene_name: String = "main"
@export var enabled := true

@export var destination_door : Node2D
@export var player_camera : PlayerCamera
@export var sfx_player : AudioStreamPlayer

@onready var cinematic_camera = $CinematicCamera

var cutcene_played_at_least_once : bool = false

func _ready():
	
	self.animation_finished.connect(on_animation_finished)

	var campaing : Campaing = CampaingOverseer.current_campaing
	
	var campaing_audio : GameAudioManager = campaing.get_campaing_audio_manager()
	
	is_music_paused.connect(campaing_audio.pause_music)
	fade_out_music.connect(campaing_audio.fade_out_current_music)
	fade_in_music.connect(campaing_audio.fade_in_current_music)
	
	# Campaing signal
	set_cutcene_state.connect(campaing.change_cutcene_status)
	
	# HUD signals
	show_dialog_box.connect(campaing.hud.show_dialog_box_text)
	change_background_color_visibility.connect(campaing.hud.show_background_color)
	campaing.hud.dialog_closed.connect(dialog_closed)
	
	# SceneHandler signals
	change_map.connect(campaing.scene_handler.new_scene)
	
	if player_camera == null:
		printerr("ERRO! Camera nao encontrada!")
		get_tree().quit(1)
	
func dialog_closed(option) -> void:
	current_step_finished.emit(option)
	
func end_cutcene(new_scene_path: String = "") -> void:

	set_cutcene_state.emit(false)
	player_camera.activate()
	
	if not new_scene_path.is_empty():
		
		var door_name = destination_door.name
		var spawn_information := {
						"type" : SceneHandler2D.SpawnType.AT_DOOR,
						"door_name" : door_name,
						"player_y" : 0,
					}
		change_map.emit(new_scene_path, spawn_information)

func start_cutcene_mode():
	
	cutcene_played_at_least_once = true
	set_cutcene_state.emit(true)
	cinematic_camera.call_deferred("make_current")
	
func on_animation_finished(anim_name):
	current_step_finished.emit(anim_name)

func play_sfx(audio: AudioStream) -> void:
	
	sfx_player.stream = audio
	sfx_player.play()
