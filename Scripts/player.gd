extends CharacterBody3D

@export 
var SPEED = 5.0
@export
var JUMP_VELOCITY = 4.5
@export 
var SPRINT_SPEED = 10.0

signal isSprinting(bool)

@onready var chain_link := preload("res://Scenes/rope.tscn")
const GRAPPLE_DISTANCE := 500
@onready var grapple_cast := $Neck/Camera3D/GrappleHand/RayCast3D

class VectorPair:
	var start:Vector3 = Vector3.ZERO
	var end:Vector3 = Vector3.ZERO
	
	func get_distance() -> float:
		return (end - start).length()
		
	func get_line() -> Vector3:
		return end - start
	
	func get_normalized_line() -> Vector3:
		return (end - start).normalized()

var grapple_line:=VectorPair.new()
var chain_links:=[]
var hooking := false
var link_height := 1 #TODO: The chain itself should be able to provide this info. Hard coding for now

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var neck := $Neck
@onready var camera := $Neck/Camera3D
@onready var interaction = $Neck/Camera3D/Interaction
@onready var hand = $Neck/Camera3D/Hand
@onready var joint = $Neck/Camera3D/Generic6DOFJoint3D
@onready var staticBody = $Neck/Camera3D/StaticBody3D
@onready var grapple_hand := $Neck/Camera3D/GrappleHand

var picked_object
var pull_power = 7
var rotation_power =0.05
var jump_count = 0
var lockedCam = false
#player has x/z movement but no y velocity
var groundedMovementThisFrame = false
@export
var lastWalkingSfxPosition = 0;


func _ready():
	grapple_cast.target_position *= GRAPPLE_DISTANCE
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
	grapple_line.start = grapple_hand.global_position
	var links_in_chain = chain_links.size()
	for i in links_in_chain:
		position_link(chain_links[i], i+1, links_in_chain)
		pass
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
		velocity.x = move_toward(velocity.x, 0, SPEED) 
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	if picked_object != null:
		var a = picked_object.global_transform.origin
		var b = hand.global_transform.origin
		picked_object.set_linear_velocity((b-a)*pull_power)

	if Input.is_action_just_pressed("shoot"):
		if hooking:
			while not chain_links.is_empty():
				chain_links.pop_front().queue_free()
			hooking = false
			return
		#var this_pizza := chain_link.instantiate()
		#get_parent().add_child(this_pizza)
		#this_pizza.position = grapple_hand.global_position
		#var launch_vector = (interaction.target_position - interaction.position).normalized()
		#var launch_vector = camera.get_global_transform().basis
		if grapple_cast.is_colliding():
			grapple_line.end = grapple_cast.get_collision_point()
			print(grapple_line.get_distance())
			hooking = true
			shoot_hook()
		#this_pizza.shoot(-launch_vector.z, camera.get_global_rotation_degrees())
	

	if(velocity.y == 0 and (velocity.x != 0 or velocity.z != 0)):
		if (not $WalkingFxPlayer.playing):
			var walkingFxLength = $WalkingFxPlayer.stream.get_length()
			if (lastWalkingSfxPosition == walkingFxLength):
					lastWalkingSfxPosition = 0;
			
			if (not $WalkingFxPlayer.has_stream_playback()):
				$WalkingFxPlayer.play()
					
			print(lastWalkingSfxPosition)
			$WalkingFxPlayer.stream_paused = false
	else:
		lastWalkingSfxPosition = $WalkingFxPlayer.get_playback_position()
		print("stopping playingback at " + str(lastWalkingSfxPosition))
		$WalkingFxPlayer.stream_paused = true
		
		
	move_and_slide()

func shoot_hook():
	print("shooting hook from " + str(grapple_line.start) + " to " + str(grapple_line.end))
	var num_links = num_links_necessary()
	for n in range(1, num_links):
		var new_link := chain_link.instantiate()
		get_tree().get_root().add_child(new_link)
		chain_links.push_back(new_link)
		#new_link.global_position = (grapple_line.end - grapple_line.start) * (float(n) / num_links) + grapple_hand.global_position
		position_link(new_link, n, num_links)
		new_link.global_rotate(grapple_line.get_normalized_line(), 90)

func num_links_necessary() -> int:
	var distance = grapple_line.get_distance()
	print("distance: " + str(distance))
	print("link_height: " + str(link_height))
	var result = ceil(distance / link_height)
	print("resulting divide: " + str(result))
	return result
	
func position_link(link, index:int, num_links_in_chain:int):
	link.global_position = grapple_line.get_line() * (float(index) / num_links_in_chain) + grapple_hand.global_position
	link.global_rotate(grapple_line.get_normalized_line(), 0)

func respawn(spawn_point:Vector3):
	velocity = Vector3.ZERO
	position = spawn_point
