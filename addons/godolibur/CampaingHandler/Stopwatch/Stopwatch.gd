@icon("res://addons/godolibur/Assets/components_icons/stopwatch.png")
extends Node
class_name Stopwatch
## A utility node for counting time

@export_enum("Idle", "Physics") var process_callback : String = "Idle" ## Determines weather the processing of elapsed time is calculated during process(_process) or during physics frames(_physics_process)
@export var autostart := false ## If **true**, the Stopwatch should start after the node is ready
@export var starting_time := 0.0 ## Specify a time when the stopwatch should start at

var time := 0.0
var paused := true : set = _set_stopwatch_status

var __process_time_in_the_physics_engine := false

func _ready():
	paused = not autostart
	time = starting_time
	
	if process_callback == "Physics":
		__process_time_in_the_physics_engine = true

func _set_stopwatch_status(is_active: bool) -> void:
	paused = is_active
	set_process(is_active)

func get_time() -> float:
	return time
	
func set_time(new_time) -> void:
	time = new_time

func get_current_time_as_string() -> String:
	return Stopwatch.time_to_hours(time)

func _process(delta: float) -> void:
	time += (delta * int(not __process_time_in_the_physics_engine))
	
func _physics_process(delta: float) -> void:
	time += (delta * int(__process_time_in_the_physics_engine))
	
static func time_to_hours(total_time: float) -> String:
	
	var total_seconds = int(total_time)
	
	@warning_ignore("integer_division")
	var hours : int = total_seconds / 3600
	
	@warning_ignore("integer_division")
	var minutes : int = (total_seconds % 3600) / 60
	
	var seconds : int = total_seconds % 60
	
	return "%02d:%02d:%02d" % [hours, minutes, seconds]
