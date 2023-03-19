extends Node3D

@onready var player := $Player
@onready var player_spawn := $PlayerSpawn

@onready var pizza := $SpinningPizza/RigidBody3D
@onready var pizza_spawn := $PizzaSpawn

@onready var finish_line := $FinishLine

func _ready():
	finish_line.finished.connect(go_to_next_scene)
	get_viewport().set_physics_object_picking(true)

func _process(delta):
	if player.position.y < -30:
		player.respawn(player_spawn.position)
	if pizza.position.y < -30:
		pizza.position = pizza_spawn.position
		pizza.linear_velocity = Vector3.ZERO

func go_to_next_scene():
	get_tree().change_scene_to_file("res://Scenes/pizza_level.tscn")
	
