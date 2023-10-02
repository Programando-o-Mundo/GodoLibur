extends AudioStreamPlayer

@export_enum("Music:1", "SFX:2") var audio_bus: int = 2

func _ready():
	AudioServer.bus_layout_changed.connect(bus_layout_changed)

func bus_layout_changed() -> void:
	print(AudioServer.get_bus_volume_db(audio_bus))
	self.volume_db = AudioServer.get_bus_volume_db(audio_bus)
