extends MarginContainer

@export var campaing : PackedScene

func _ready():
	pass # Replace with function body.

func _on_jogar_pressed():
	CampaingOverseer.start_campaing_from_packed_scene(campaing)
