extends Button
class_name CustomButton

@onready var ui_arrow = $UiArrow
@onready var sfx = $SFX

@export var on_focus_sfx : AudioStream
@export var on_pressed_sfx : AudioStream

func _ready() -> void:
	ui_arrow.modulate.a = 0
	
func grab_button_focus() -> void:
	self.grab_focus()
	ui_arrow.play_animation()

func _on_focus_entered():
	ui_arrow.play_animation()
	sfx.stream = on_focus_sfx
	sfx.play()

func _on_focus_exited():
	ui_arrow.stop_animation()

func _on_pressed():
	sfx.stream = on_pressed_sfx
	sfx.play()
