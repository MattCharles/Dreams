extends Control

@export 
var levels: Array[PackedScene]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_pizza_level_button_pressed():
	get_tree().change_scene_to_packed(levels[0])


func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://Scenes/menu.tscn") # Replace with function body.
