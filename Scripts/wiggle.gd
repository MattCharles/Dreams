extends Node3D

@export
var wiggle_factor := 20.0
var wiggle_speed := 10
var t := 0.0

func _process(delta):
	t += delta
	var new_val = cos(wiggle_speed * deg_to_rad(t)) * wiggle_factor
	global_position.y = new_val
