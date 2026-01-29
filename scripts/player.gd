extends CharacterBody3D

# TODO: Have separate animation player so scene isn't too large


const JUMP_VELOCITY = 4.5
const WALKING_SPEED = 3.0
const RUNNING_SPEED = 5.0

var speed = 3.0
var running = false
var is_locked = false

@export var sens_horizontal = 0.5
@export var sens_vertical = 0.5

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x*sens_horizontal))
		%CameraMount.rotate_x(deg_to_rad(-event.relative.y*sens_vertical))
		%Visuals.rotate_y(deg_to_rad(event.relative.x*sens_horizontal))

func _physics_process(delta: float) -> void:
	if !%AnimationPlayer.is_playing():
		is_locked = false
	
	if Input.is_action_just_pressed("kick"):
		if %AnimationPlayer.current_animation != "kick":
			%AnimationPlayer.play("kick")
			is_locked = true
	
	if Input.is_action_pressed("run"):
		speed = RUNNING_SPEED
		running = true
	else:
		speed = WALKING_SPEED
		running = false
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if !is_locked:
			if !running:
				if %AnimationPlayer.current_animation != "walking":
					%AnimationPlayer.play("walking")
			else:
				if %AnimationPlayer.current_animation != "running" && running:
					%AnimationPlayer.play("running")
		
			%Visuals.look_at(position + direction)
		
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		if !is_locked:
			if %AnimationPlayer.current_animation != "idle":
				%AnimationPlayer.play("idle")
	
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	if !is_locked:
		move_and_slide()
