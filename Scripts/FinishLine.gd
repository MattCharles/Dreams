extends Node3D

signal finished()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_3d_body_entered(body):
	print("logging collision with " + str(body))
	if body is Pizza:
		print(" Pizza O_O ")
		emit_signal("finished")
