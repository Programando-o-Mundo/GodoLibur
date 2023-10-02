extends InteractionArea

signal show_cutcene(cutcene, cutcene_name)
signal give_item_to_cutcene(cutcene, cutcene_name, item)

@export var cutcene : PackedScene
@export var cutcene_name : String = "cutcene_name"

@export var inventory_link : InventoryLink

func _ready():
	var hud = get_tree().current_scene.get_node("HUD")
	if not hud:
		printerr("ERROR! HUD not found!\n")
		get_tree().quit(1)
	
	show_cutcene.connect(hud.show_custom_cutcene)
	give_item_to_cutcene.connect(hud.use_item_on_cutcene)
	hud.correct_item_used.connect(correct_item_used)

func _on_player_interacted(_motion: Vector2):
	show_cutcene.emit(cutcene, cutcene_name)

func _on_inventory_link_player_used_item(item: Item) -> void:
	give_item_to_cutcene.emit(cutcene, cutcene_name, item)
	
func correct_item_used(_cutcene_name: String, item: Item) -> void:
	inventory_link.correct_item_used(item.name)

