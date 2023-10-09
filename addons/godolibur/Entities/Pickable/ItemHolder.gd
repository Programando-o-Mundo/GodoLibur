extends InteractionArea
class_name ItemHolder

signal item_picked(item)

enum SparkColor {
	White,
	Purple
}

@export var item : GDScript
@export var show_spark: bool     = false

var is_pickable := true : set = set_is_item_pickable
var item_instance : Item

func _ready() -> void:
	
	var current_campaing = CampaingOverseer.current_campaing
	
	var player_inventory = current_campaing.get_player_inventory()
	
	item_instance = item.new()
	item_picked.connect(player_inventory.add_item)
	
	var dialog = current_campaing.get_game_gui().dialog_box_handler
	
	if not dialog:
		printerr("[%s] ERROR! dialog box handler not found!" % self.name)
		return  
		
	if item == null:
		printerr("[%s] ERROR! Item not defined!" % self.name)
		return  
		
	item_picked.connect(dialog.on_item_picked)

func load_data(data: Dictionary) -> void:
	is_pickable = data.is_pickable
	
func save_data() -> Dictionary:
	var data := {}
	
	data["is_pickable"] = is_pickable
	
	return data  

func _on_player_interacted(_motion: Vector2) -> void:

	if not is_pickable:
		return

	item_picked.emit(item_instance)

	is_pickable = false

func set_is_item_pickable(value) -> void:
	self.visible = value
	is_pickable = value
	disabled = not value
