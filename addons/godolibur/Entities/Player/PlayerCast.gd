extends Area2D
class_name PlayerCast

var closest_object = null

var direction = Vector2.UP : set = update_direction

@export var reference_vector := Vector2.LEFT

func _ready():
	update_direction(direction)

func update_direction(vector: Vector2) -> void:	
	
	direction = vector
	
	vector.x = -vector.x
	
	var radian = vector.angle_to(reference_vector)
	
	rotation = radian

func _process(_delta: float) -> void:

	if has_overlapping_areas():
		var areas: Array[Area2D] = get_overlapping_areas()
		
		for area in areas:
			
			if valid_area(area):
				closest_object = area
				return
			
	else:
		closest_object = null


func valid_area(area: Area2D) -> bool:
	return area is InteractionArea and not area.disabled
