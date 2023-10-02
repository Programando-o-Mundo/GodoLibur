# A generic model for making a simple user interface

extends Control
class_name SimpleUI

signal exit_screen()
signal enter_screen()
signal open_screen()
signal force_quit()

const SHOW_SCREEN_ANIMATION : = "show_screen"
const HIDE_SCREEN_ANIMATION : = "hide_screen"

@onready var animation : AnimationPlayer = $Animation

@export var main_screen: bool = false

# If correctly implemented, show the screen through the help of an
# animation player
func show_screen() -> void:
	
	if not animation_player_and_animation_exist(SHOW_SCREEN_ANIMATION):
		return
		
	enter_screen.emit()
	animation.play(SHOW_SCREEN_ANIMATION)
	
# If correctly implemented, hide the screen through the help of an
# animation player
func hide_screen() -> void:
	
	if not animation_player_and_animation_exist(HIDE_SCREEN_ANIMATION):
		return

	exit_screen.emit()
	animation.play(HIDE_SCREEN_ANIMATION)
	
# Check if the animation player, and the animation specified exist 
# in the animation player
func animation_player_and_animation_exist(animation_name : String) -> bool:
	var result : bool = true
	
	if animation == null:
		printerr("Error! No AnimationPlayer was implemented")
		result = false
		
	if not animation.has_animation(animation_name):
		printerr("Error! The \" " + str(animation_name) + " \" animation was not implemented")	
		result = false
		
	return result

