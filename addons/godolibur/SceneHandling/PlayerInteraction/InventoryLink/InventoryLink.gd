extends Area2D
class_name InventoryLink

signal player_used_item(item)

var player_is_in_area = false

var player_inventory : PlayerInventory

func _ready():
	player_inventory = CampaingOverseer.current_campaing.get_player_inventory()

func try_to_use_item(item : Item) -> void:
	player_used_item.emit(item)

func correct_item_used(item_name : String) -> void:
	player_inventory.remove_item(item_name)

func player_entered_area(_area : Node2D ) -> void:

	var _err = player_inventory.try_to_use_item.connect(try_to_use_item)
	player_is_in_area = true
	
func player_exited_area(_area : Node2D ) -> void:
	if player_is_in_area:
		player_inventory.try_to_use_item.disconnect(try_to_use_item)
		player_is_in_area = false
