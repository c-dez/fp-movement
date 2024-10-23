extends Node3D

# top_level = false
@onready var player:Node3D = get_node("..")
@onready var player_mesh:MeshInstance3D = get_node("../MeshInstance3D")

@export var x_sens:float = 0.10
@export var y_sens:float = 0.12
# @export var camera_weight:float = 0.1

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pass

func _physics_process(_delta: float) -> void:
	# position = lerp(position,player.position,camera_weight)
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if event.relative:
			var mouse_relative:Vector2 = event.relative
			# rotates player in horizontal
			player.rotate_y(deg_to_rad(-mouse_relative.x * x_sens))
			# rotate camera vertical / clamp
			var max_deg:float = deg_to_rad(-45)
			var min_deg:float = deg_to_rad(45)
			rotate_x(deg_to_rad(-mouse_relative.y * y_sens))
			rotation.x = clamp(rotation.x,max_deg, min_deg)
			rotation.z = clamp(rotation.z,0,0)
	pass
