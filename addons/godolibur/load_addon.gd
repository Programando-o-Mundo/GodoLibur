@tool
extends EditorPlugin

var campaing_overseer_autoload_name := "CampaingOverseer"
var campaing_overseer_autoload_path := "res://addons/godolibur/Campaing/CampaingOverseer.gd"

var game_settings_autoload_name := "GameSettings"
var game_settings_autoload_path := "res://addons/godolibur/GameSettings/GameSettings.gd"

func _enter_tree():
	add_autoload_singleton(campaing_overseer_autoload_name, campaing_overseer_autoload_path)
	add_autoload_singleton(game_settings_autoload_name, game_settings_autoload_path)


func _exit_tree():
	remove_autoload_singleton(campaing_overseer_autoload_name)
	remove_autoload_singleton(game_settings_autoload_name)
