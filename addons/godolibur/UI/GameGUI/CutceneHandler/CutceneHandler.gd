extends Control
class_name CutceneHandler

signal cutcene_started()
signal cutcene_ended()

@export var static_cutcene : StaticCutcene 

var custom_cutcenes_instances := {}
var current_campaing : Campaing

# Called when the node enters the scene tree for the first time.
func _ready():
	current_campaing = CampaingOverseer.current_campaing
	static_cutcene.visible = false

func get_cutcene_instance(cutcene: PackedScene, cutcene_name: String) -> CutceneInterface:
	
	var cutcene_instance : CutceneInterface = null
	
	if custom_cutcenes_instances.has(cutcene_name):
		cutcene_instance = custom_cutcenes_instances[cutcene_name]
		
	else:
		
		cutcene_instance = cutcene.instantiate()
		add_child(cutcene_instance)
		custom_cutcenes_instances[cutcene_name] = cutcene_instance
		
	return cutcene_instance
	
func show_custom_cutcene(cutcene: PackedScene, cutcene_name: String) -> void:

	if current_campaing.in_cutcene:
		return
		
	var cutcene_instance = get_cutcene_instance(cutcene, cutcene_name)
		
	cutcene_started.emit()
	cutcene_instance.play_cutcene()
	
	await cutcene_instance.cutcene_ended
	
	cutcene_ended.emit()

func show_static_cutcene(background_texture : CompressedTexture2D, script : GDScript ) -> void:
	
	if current_campaing.in_cutcene:
		return
	
	cutcene_started.emit()
	static_cutcene.play_cutcene(background_texture, script)
	
	await static_cutcene.cutcene_ended
	
	cutcene_ended.emit()

func use_item_on_cutcene(cutcene: PackedScene, cutcene_name: String, item: Item):
	
	if current_campaing.in_cutcene:
		return
	
	var cutcene_instance = get_cutcene_instance(cutcene, cutcene_name)
	
	var success = cutcene_instance.use_item(item)

	if success:
		item.correctly_used.emit()
		cutcene_started.emit()
		
		cutcene_instance.play_cutcene()
		await cutcene_instance.cutcene_ended
		cutcene_ended.emit()
