@icon("res://addons/godolibur/Assets/components_icons/backpack.png")
class_name PlayerInventory
extends Node


@export_category("Player Information")
@export var character_information: Character
@export var icon : CompressedTexture2D

signal item_removed(item)
signal new_item_acquired(item)
signal try_to_use_item(item_name)

signal inventory_cleared()

"""
Stores all the players items, the items itself are arrays
with three variables:
'0': The enum of the item
'1': The name of the item 
'2': The description of the item
'3': it's texture
"""
var items : Array = []
var items_indexes : Dictionary = {}

func get_json():
	return {
		"player_info" : get_player_information(),
		"items" : get_items_as_json()
	}

func get_player_information() -> Dictionary:
	return character_information.to_json()
	
func get_items() -> Array:
	return items.duplicate()
	
func get_items_as_json() -> Array:
	var array := []
	
	for item in items:
		array.append(item.to_json())
		
	return array
	
func clear():
	items.clear()
	items_indexes.clear()
	inventory_cleared.emit()
	
func set_items_from_json(items_json) -> void:
	
	for item_json in items_json:
		
		var item = load(item_json["script_path"]).new()
		item.from_json(item_json)
		
		add_item(item)
		
	
func get_item(item_name) -> Item:
	return items[items_indexes.get(item_name)[-1]]
	
func get_item_description(item_name) -> String:
	return get_item(item_name).description

func add_item(item: Item):
	
	var item_position = items.size()
	
	items.append(item)
	
	if not items_indexes.has(item.name):
		items_indexes[item.name] = []
		
	items_indexes[item.name].append(item_position)
		
	new_item_acquired.emit(item)
	
func has_item(item: Item) -> bool:
	return items_indexes.has(item.name)
	
func use_item(item_name: String) -> void:
	
	if not items_indexes.has(item_name):
		printerr("ERROR! Inventory does not have item: ", item_name)
		return
		
	var item : Item = get_item(item_name)
	item.use(try_to_use_item)
	
func remove_item(item_name: String) -> void:
	
	if not items_indexes.has(item_name):
		printerr("No \"%s\" item name was found!" % item_name)
		get_tree().quit(1)
		
	var item = items_indexes[item_name].pop_back()
	items.remove_at(item)
	
	if not item:
		items_indexes.erase(item_name)
		
	item_removed.emit(item_name)
