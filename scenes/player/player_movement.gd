extends CharacterBody3D


@onready var player_mesh:MeshInstance3D = get_node("MeshInstance3D")


# move/normal
var speed:float = 7.0
var jump_velocity:float = 10
const GRAVITY:float = -18
enum MOVE_STATE {NORMAL, DASH}
# move_state usa enum MOVE_STATE para diferenciar entre moverse a velocidad normal, dash
var move_state:int

# move/DASH
var speed_dash:float = 14
var dash_countdown_time:float = 0.5
var dash_countdown_time_internal:float = 0
var dash_cooldown:float = 1
var dash_coolddown_internal:float = 0

# MISC
var last_position:Vector3 # Respawn after falling
var rotate_mesh_weight:float = 0.2

#coyote time
var coyote_time_time:float = 0.3
var coyote_time_time_internal:float = 0
var can_jump:bool = true

# Wall Jump
enum WALL_JUMP_STATE {OUT_WALL, IN_WALL}
var wall_state: int
var wall_jump_cooldown: float = 0.5
var wall_jump_cooldown_internal: float = 0


func _ready() -> void:
	move_state = MOVE_STATE.NORMAL
	wall_state = WALL_JUMP_STATE.OUT_WALL
	pass

func _process(delta: float) -> void:
	change_move_state_to_dash_countdown(delta)
	
	pass


func _physics_process(delta: float) -> void:
	move_player_speed_state()
	coyote_time(delta)
	jump_player()
	gravity_player(delta)
	player_last_position()
	wall_jump(delta)
	move_and_slide()

	pass

func coyote_time(_delta:float)->void:
	if is_on_floor():
		coyote_time_time_internal = coyote_time_time
	else:
		coyote_time_time_internal -= _delta
	
	if coyote_time_time_internal > 0:
		can_jump = true
	elif coyote_time_time_internal < 0:
		can_jump = false
		coyote_time_time_internal = 0


func move_player_speed_state()->void:
	# elige la velocidad de movimiento segun el estado
	match move_state:
		MOVE_STATE.NORMAL:
			move_player(speed)
		MOVE_STATE.DASH:
			move_player(speed_dash)
	pass


func change_move_state_to_dash_countdown(_delta:float)->void:
	# esta funcion se encarga de cambiar valor de move_state entre normal y dashing al presionar shift, durante x tiempo move_state == 1, (enum MOVE_STATE.DASH)

	# tambien se hace cargo de su propio cooldown para que Player no pueda spamearla
	if Input.is_action_just_pressed("shift") and dash_coolddown_internal == 0:
		dash_countdown_time_internal = dash_countdown_time
		dash_coolddown_internal = dash_cooldown
	if dash_countdown_time_internal > 0 :
		dash_countdown_time_internal -= _delta
		move_state = MOVE_STATE.DASH
	elif dash_countdown_time_internal < 0:
		dash_countdown_time_internal = 0
		move_state = MOVE_STATE.NORMAL
	# Cooldown	
	if dash_coolddown_internal > 0:
		dash_coolddown_internal -= _delta
	elif dash_coolddown_internal < 0:
		dash_coolddown_internal = 0


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
	if Input.is_action_just_pressed("jump") and can_jump:
		velocity.y = jump_velocity
	pass


func gravity_player(delta:float)->void:
	# gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	pass


func _on_fall_zone_body_entered(_body:Node3D) -> void:
	# senal de nodo FallZone
	if _body.is_in_group("player"):
		call_deferred("change_player_to_last_position")


func change_player_to_last_position()->void:
	# Se encarga de respwn Player al entrar a FallZone
	position = player_last_position()


func player_last_position()->Vector3:
	# regresa la ultima posicion de el Player mientras este tocando el suelo

	# Uso este valor para regresar a Player a esa posicion al entrar en  nodo FallZone en func change_player_to_last_position()

	# TODO QUE TAMBIEN GUARDE LA DIRECCION A LA QUE MIRA PLAYER
	if is_on_floor():
		last_position = position
		# last_position = grid.local_to_map(position)
	return last_position

# WALL JUMP
func _on_wall_area_body_entered(body:Node3D) -> void:
	# senal mandada desde nodo WallArea cuando entra en body con nombre "GridMap" y cambia el wall_state
	if body.name == "GridMap":
		wall_state = WALL_JUMP_STATE.IN_WALL


func _on_wall_area_body_exited(body:Node3D) -> void:
	# senal cuando sale de un body
	if body.name == "GridMap":
		wall_state = WALL_JUMP_STATE.OUT_WALL


func wall_jump(_delta:float)->void:
	# este match se encarga de permitir brincar cuando esta en contacto con un muro segun sea el wall_state
	match wall_state:
		WALL_JUMP_STATE.IN_WALL:
			if Input.is_action_just_pressed("jump") and not is_on_floor() and wall_jump_cooldown_internal == 0:
				velocity.y = jump_velocity
				wall_jump_cooldown_internal = wall_jump_cooldown
		WALL_JUMP_STATE.OUT_WALL:
			# Se hace cargo de un cooldown para evitar spamear brinco
			if not is_on_floor():
				wall_jump_cooldown_internal -= _delta
			if wall_jump_cooldown_internal < 0:
				wall_jump_cooldown_internal = 0
			pass
			
			

		
