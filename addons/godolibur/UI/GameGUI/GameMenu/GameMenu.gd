@tool
extends MenuController
class_name GameMenu

var campaing : Campaing

func _ready() -> void:
	super._ready()
	
	if Engine.is_editor_hint():
		return
		
	campaing = CampaingOverseer.current_campaing

func _input(event : InputEvent ) -> void:

	if event.is_action_pressed(open_gui_command) and campaing.gui_available_to_show():
		
		if current_ui != null:
			current_ui.hide_screen()
			
		else:
			
			if get_tree().paused:
		
				menu_closed.emit()
				play_menu_animation(close_menu_animation)
			else:
				
				menu_opened.emit()
				play_menu_animation(open_menu_animation)
				main_screen.show_screen()
