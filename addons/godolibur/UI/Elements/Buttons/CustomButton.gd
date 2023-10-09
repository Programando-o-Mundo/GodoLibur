extends Button
class_name CustomButton

@export var ui_indicator : Control
@export var sfx_player : AudioStreamPlayer

@export var on_focus_sfx : AudioStream
@export var on_pressed_sfx : AudioStream

func _ready() -> void:
	ui_indicator.modulate.a = 0
	
func grab_button_focus() -> void:
	self.grab_focus()
	ui_indicator.play_animation()

func _on_focus_entered():
	ui_indicator.play_animation()
	if sfx_player:
		sfx_player.stream = on_focus_sfx
		sfx_player.play()

func _on_focus_exited():
	ui_indicator.stop_animation()

func _on_pressed():
	if sfx_player:
		sfx_player.stream = on_pressed_sfx
		sfx_player.play()
