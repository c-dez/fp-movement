extends CharacterBody3D


@onready var player_mesh:Node3D = get_node("MeshInstance3D")

# Move
var speed:float = 7.0
var jump_velocity:float = 7.5
# DASH
var dash_speed:float = 14
var dash_countdown_time:float = 0.3
# INTERNAL
var dash_countdown_time_internal:float = 0
# MISC
var rotate_mesh_weight:float = 0.2

enum MOVE_STATE {NORMAL, DASH}
# move_state usa enum MOVE_STATE para diferenciar entre moverse a velocidad normal, dash
var move_state:int


func _ready() -> void:
	move_state = MOVE_STATE.NORMAL
	pass

func _process(delta: float) -> void:
	change_move_state_to_dash_countdown(delta)
	# QUIERO QUE LA VELOCIDAD DE DASH SE MANTENGA EN EL AIRE AUNQUE YA HALLA EXPIRADO LA CUENTA REGRESIVA DE  change_move_state_to_dash_countdown QUEDA PENDIENTE

	
	pass


func _physics_process(delta: float) -> void:
	move_player_speed_match()
	jump_player()
	gravity_player(delta)
	move_and_slide()
	pass


func change_move_state_to_dash_countdown(_delta:float)->void:
	# esta funcion se encarga de cambiar valor de move_state entre normal y dashing al presionar shift, durante x tiempo move_state == 1, (enum MOVE_STATE.DASH)
	if Input.is_action_just_pressed("shift"):
		dash_countdown_time_internal = dash_countdown_time
	if dash_countdown_time_internal > 0 :
		dash_countdown_time_internal -= _delta
		move_state = MOVE_STATE.DASH
	elif dash_countdown_time_internal < 0:
		dash_countdown_time_internal = 0
		move_state = MOVE_STATE.NORMAL
		pass
	pass

func move_player_speed_match():
	# elige la velocidad de movimiento segun el estado
	match move_state:
		MOVE_STATE.NORMAL:
			move_player(speed)
		MOVE_STATE.DASH:
			move_player(dash_speed)
	pass


func move_player(_speed:float)->void:
	# mueve a el Player segun _speed
	var input_dir : Vector2 = Input.get_vector("left", "right", "forward", "backwards")
	var direction :Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * _speed 
		velocity.z = direction.z * _speed 
	else:
		velocity.x = move_toward(velocity.x, 0, _speed)
		velocity.z = move_toward(velocity.z, 0, _speed)
	rotate_mesh(input_dir)	


func rotate_mesh(input_dir:Vector2)->void:
	# rotate mesh to input_dir
	if input_dir != Vector2.ZERO:	
		player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(-input_dir.x, -input_dir.y), rotate_mesh_weight)
	pass


func jump_player()->void:
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	pass


func gravity_player(delta:float)->void:
	# gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	pass
