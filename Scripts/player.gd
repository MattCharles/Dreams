extends CharacterBody3D

@export 
var SPEED = 5.0
@export
var JUMP_VELOCITY = 4.5
@export 
var SPRINT_SPEED = 10.0

signal isSprinting(bool);

@onready var pizza := preload("res://Scenes/rope.tscn")

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var neck := $Neck
@onready var camera := $Neck/Camera3D
@onready var interaction = $Neck/Camera3D/Interaction
@onready var hand = $Neck/Camera3D/Hand
@onready var joint = $Neck/Camera3D/Generic6DOFJoint3D
@onready var staticBody = $Neck/Camera3D/StaticBody3D

var picked_object
var pull_power = 7
var rotation_power =0.05
var jump_count = 0
var lockedCam = false

func _ready():
	set_process_unhandled_input(true)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if !lockedCam:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			if event is InputEventMouseMotion:
				neck.rotate_y(-event.relative.x * 0.01)
				camera.rotate_x(-event.relative.y * 0.01)
				camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(60))
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var this_pizza := pizza.instantiate()
		get_parent().add_child(this_pizza)
		this_pizza.position = interaction.global_position
		var launch_vector = (interaction.target_position - interaction.position).normalized()
		launch_vector = launch_vector.rotated(Vector3(1, 0, 0), camera.rotation.x).rotated(Vector3(0, 1, 0), neck.rotation.y)
		this_pizza.shoot(launch_vector)
		if picked_object == null:
			pick_object()
		elif picked_object != null:
			drop_object()
			
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		lockedCam = true
		rotate_object(event)
	else:
		lockedCam = false
			
func rotate_object(event):
	if picked_object != null:
		if event is InputEventMouseMotion:
			staticBody.rotate_x(deg_to_rad(event.relative.y * rotation_power))
			staticBody.rotate_y(deg_to_rad(event.relative.x * rotation_power))

func pick_object():
	var collider = interaction.get_collider()
	if collider != null and collider is Pizza:
		picked_object = collider
		joint.set_node_b(picked_object.get_path())
		
		
func drop_object():
	if picked_object != null:
		picked_object = null
		joint.set_node_b(joint.get_path())
		


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		var movementSpeedThisFrame = SPEED
		var sprinting = false;
		if (Input.is_action_pressed("sprint")):	
			movementSpeedThisFrame = SPRINT_SPEED
			sprinting = true;
			
		velocity.x = direction.x * movementSpeedThisFrame
		velocity.z = direction.z * movementSpeedThisFrame
		isSprinting.emit(sprinting) # Player sprinted this frame
	else:	
		# 
		velocity.x = move_toward(velocity.x, 0, SPEED) 
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	if picked_object != null:
		var a = picked_object.global_transform.origin
		var b = hand.global_transform.origin
		picked_object.set_linear_velocity((b-a)*pull_power)

	move_and_slide()
	
func respawn(spawn_point:Vector3):
	velocity = Vector3.ZERO
	position = spawn_point
	
