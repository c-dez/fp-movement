extends CharacterBody3D


@export var speed:float = 5.0
@export var jump_velocity:float = 4.5


func _physics_process(delta: float) -> void:
	move_player()
	jump_player()
	gravity_player(delta)
	move_and_slide()
	pass


func move_player()->void:
	# Get the input direction and handle the movement/deceleration.
	var input_dir : Vector2 = Input.get_vector("left", "right", "forward", "backwards")
	var direction :Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
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