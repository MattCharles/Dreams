extends Node3D
class_name FinishLine

signal finished()

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("finish_lines")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_area_3d_body_entered(body):
	if body is Pizza:
		emit_signal("finished")
