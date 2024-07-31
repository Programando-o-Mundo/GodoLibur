extends MarginContainer

func _ready():
	pass # Replace with function body.

func _on_jogar_pressed():
	CampaingOverseer.start_campaing_from_file_path("res://examples/AventuraGodot/Campanha/MinhaCampanha.tscn")
