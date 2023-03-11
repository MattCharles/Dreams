extends Node3D

@onready var player := $Player
@onready var player_spawn := $PlayerSpawn

@onready var pizza := $SpinningPizza/RigidBody3D
@onready var pizza_spawn := $PizzaSpawn

func _ready():
	get_viewport().set_physics_object_picking(true)

func _process(delta):
	if player.position.y < -10:
		player.respawn(player_spawn.position)
	if pizza.position.y < -10:
		pizza.position = pizza_spawn.position
		pizza.linear_velocity = Vector3.ZERO
