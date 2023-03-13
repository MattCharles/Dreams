extends Node3D
class_name GrowingObject

@onready var meshBody = StaticBody3D
var count =2
var isVisible = false



# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if Input.is_action_pressed("forward") and isVisible:
		transform.basis.z = transform.basis.z + Vector3(0,0,.008)
	pass
	
func _input(event):
	
	if event.is_action_pressed("Grow"):
		transform.basis.z = transform.basis.z +Vector3(0,0,1)
	
		
		

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Grow"):
		print("trying to grow")
		


func _on_visible_on_screen_notifier_3d_screen_entered():
	isVisible = true
	print("visible")
	pass # Replace with function body.


func _on_visible_on_screen_notifier_3d_screen_exited():
	isVisible = false
	print("NOT visible")
	pass # Replace with function body.
