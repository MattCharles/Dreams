extends Node3D

@onready var player := $Player
@onready var player_spawn := $PlayerSpawn

@onready var pizza_body := $SpinningPizza/RigidBody3D
@onready var pizza_spawn := $PizzaSpawn

func _ready():
	$"/root/GameData".current_level = 3
	get_viewport().set_physics_object_picking(true)

func _process(_delta):
	if player.position.y < -20:
		player.respawn(player_spawn.position)
	if pizza_body.position.y < -20:
		pizza_body.global_position = pizza_spawn.position
		pizza_body.linear_velocity = Vector3.ZERO
		pizza_body.angular_velocity = Vector3.ZERO

func go_to_next_scene():
	get_tree().change_scene_to_file("res://Scenes/maaaaaaaaaaaaaaaaaaaaaaaatttest.tscn")
	
