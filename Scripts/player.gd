extends CharacterBody3D

@export 
var SPEED = 5.0
@export
var JUMP_VELOCITY = 9
@export 
var SPRINT_SPEED = 10.0

signal isSprinting(bool)

@onready var chain_link := preload("res://Scenes/rope.tscn")
const GRAPPLE_DISTANCE := 500
const GRAPPLE_ACCELERATION := .5
@onready var grapple_cast := $Neck/Camera3D/GrappleHand/RayCast3D

# A pair of vectors that defines a line.
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
var grapple_chain_is_out := false
var link_height := .2 #TODO: The chain itself should be able to provide this info. Hard coding for now
var original_hook_distance := 0.0
var grapple_chain_fully_extended := false
var num_air_jumps := 2

# Used to smooth velocity when the user is at the edge of the grappling hook.
var slerping_velocity := false
var slerp_start := Vector3.ZERO
var slerp_target := Vector3.ZERO
var slerp_ms_counter := 0
const TIME_TO_SLERP := .5 # funniest unironic variable name i've made in a while

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
var noise:= false


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
				camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89.9), deg_to_rad(89.9))
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

func try_jump() -> bool:
	if not is_on_floor():
		if num_air_jumps > 0:
			num_air_jumps -= 1
			return true
		else:
			return false
	return true
	

func _physics_process(delta: float) -> void:
	grapple_line.start = grapple_hand.global_position
	if grapple_chain_is_out: 
		resize_chain()
	var links_in_chain = chain_links.size()
	grapple_chain_fully_extended = grapple_chain_is_out and original_hook_distance <= grapple_line.get_distance()
	for i in links_in_chain:
		position_link(chain_links[i], i+1, links_in_chain)
	# Add the gravity.
	if not is_on_floor() and not slerping_velocity:
		velocity.y -= gravity * delta
	else:
		num_air_jumps = 1

	if Input.is_action_just_pressed("cancel_hook"):
		if grapple_chain_is_out:
			while not chain_links.is_empty():
				chain_links.pop_front().queue_free()
			grapple_chain_is_out = false
			original_hook_distance = 0
	# Handle Jump.
	if Input.is_action_just_pressed("jump"):
		if grapple_chain_is_out:
			while not chain_links.is_empty():
				chain_links.pop_front().queue_free()
			grapple_chain_is_out = false
			original_hook_distance = 0
		if try_jump():
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
	if is_on_floor():	
		velocity.x = move_toward(velocity.x, 0, SPEED * delta) 
		velocity.z = move_toward(velocity.z, 0, SPEED * delta)
	if grapple_chain_fully_extended:
		var point_to_hook = global_position.direction_to(grapple_line.end)
		var original_magnitude = velocity.length()
		var new_rotation_axis = velocity.normalized().cross(point_to_hook)
		new_rotation_axis = new_rotation_axis.normalized()
		var rotated_velocity = velocity.rotated(new_rotation_axis, deg_to_rad(90))
		rotated_velocity *= .9
		velocity = rotated_velocity
		
	if picked_object != null:
		var a = picked_object.global_transform.origin
		var b = hand.global_transform.origin
		picked_object.set_linear_velocity((b-a)*pull_power)

	if Input.is_action_just_pressed("shoot") and not grapple_chain_is_out:
		if grapple_cast.is_colliding():
			grapple_line.end = grapple_cast.get_collision_point()
			original_hook_distance = grapple_line.get_distance()
			grapple_chain_is_out = true
			shoot_hook()
	if Input.is_action_pressed("shoot") and grapple_chain_is_out:
		velocity += (velocity + 20 * global_position.direction_to(grapple_line.end)).normalized() * GRAPPLE_ACCELERATION
		original_hook_distance = grapple_line.get_distance()
		
	
	if(noise):
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
	num_air_jumps = 2
	var num_links = num_links_necessary()
	for n in range(1, num_links):
		add_link_to_chain(n, num_links)

func resize_chain() -> void:
	var necessary_links := num_links_necessary()
	if chain_links.size() == necessary_links:
		return
	while chain_links.size() > necessary_links:
		chain_links.pop_back().queue_free()
	var num_links_added := 0
	while chain_links.size() < necessary_links:
		add_link_to_chain(chain_links.size() + num_links_added, necessary_links)
		num_links_added += 1
		

func add_link_to_chain(link_index, num_links) -> void:
	var new_link := chain_link.instantiate()
	get_tree().get_root().add_child(new_link)
	chain_links.push_back(new_link)
	position_link(new_link, link_index, num_links)

func num_links_necessary() -> int:
	var distance = grapple_line.get_distance()
	var result = ceil(distance / link_height)
	return result
	
func position_link(link, index:int, num_links_in_chain:int):
	var new_position = grapple_line.get_line() * (float(index) / num_links_in_chain) + grapple_hand.global_position
	link.global_position = new_position
	if (link.global_position - grapple_line.end).length() < .5: return
	link.look_at(grapple_line.end)

func respawn(spawn_point:Vector3):
	velocity = Vector3.ZERO
	position = spawn_point
