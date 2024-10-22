extends Area3D

@export var rot_speed_deg:int = 90


func _process(delta: float) -> void:
	rotate_y(deg_to_rad(rot_speed_deg * delta))


	

	pass

func _on_body_entered(_body:Node3D) -> void:
	queue_free()
	pass # Replace with function body.
