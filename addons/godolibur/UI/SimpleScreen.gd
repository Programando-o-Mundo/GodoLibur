# A generic model for making a simple user interface

extends Control
class_name SimpleScreen

signal exit_screen()
signal enter_screen()
signal open_screen()
signal force_quit()

@export var show_screen_animation_name := "show_screen"
@export var hide_screen_animation_name : = "hide_screen"

@onready var animation : AnimationPlayer = $Animation

# If correctly implemented, show the screen through the help of an
# animation player
func show_screen() -> void:
	
	if not __animation_player_and_animation_exist(show_screen_animation_name):
		return
		
	enter_screen.emit()
	animation.play(show_screen_animation_name)
	
# If correctly implemented, hide the screen through the help of an
# animation player
func hide_screen() -> void:
	
	if not __animation_player_and_animation_exist(hide_screen_animation_name):
		return

	exit_screen.emit()
	animation.play(hide_screen_animation_name)
	
# Check if the animation player, and the animation specified exist 
# in the animation player
func __animation_player_and_animation_exist(animation_name : String) -> bool:
	var result : bool = true
	
	if animation == null:
		printerr("Error! No AnimationPlayer was implemented")
		result = false
		
	if not animation.has_animation(animation_name):
		printerr("Error! The \"%s\" animation was not implemented" % animation_name)	
		result = false
		
	return result

