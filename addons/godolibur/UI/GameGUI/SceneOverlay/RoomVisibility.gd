extends Control
class_name RoomVisibility

signal room_visible()
signal room_is_dark()
signal player_is_using_light_source()

@export var darkness : Control
@export var light_source : Control
		
func make_room_visible():
	self.visible = false
	room_visible.emit()
		
func make_room_dark():
	self.visible = true
	darkness.visible = true
	light_source.visible = false 
	room_is_dark.emit()
	
func create_light_source():
	self.visible = true
	darkness.visible = false
	light_source.visible = true 
	player_is_using_light_source.emit()
	
