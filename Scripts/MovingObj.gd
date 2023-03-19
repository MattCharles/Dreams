extends Node3D

class_name MovingObj
var isVisible = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if Input.is_action_pressed("forward") and isVisible:
		transform.origin.z = transform.origin.z - .08
	pass
	
func _on_visible_on_screen_notifier_3d_screen_entered():
	isVisible = true
	pass # Replace with function body.


func _on_visible_on_screen_notifier_3d_screen_exited():
	isVisible = false
	pass # Replace with function body.

