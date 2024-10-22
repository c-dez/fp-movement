extends Node3D

# top_level = true
@onready var player:Node3D = get_node("..")
@export var camera_weight:float = 0.15



func _physics_process(_delta: float) -> void:
	# position == Player.position

	position = lerp(position,player.position,camera_weight)


	
	pass