extends Control

@export 
var levels: Array[PackedScene]
var timers: Array[SpeedRunTimer] = []

@onready var container = $HBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var i := 1
	for entry in container.get_children():
		for node in entry.get_children():
			if node is SpeedRunTimer:
				timers.push_back(node)
				node.stop_timer()
				node.update($"/root/GameData".level_times[i])
				node.label.text = node.print_formatted_time()
		i+=1


func _on_pizza_level_button_pressed():
	get_tree().change_scene_to_packed(levels[0])


func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://Scenes/menu.tscn") # Replace with function body.


func _on_level_2_button_pressed():
	get_tree().change_scene_to_packed(levels[1])


func _on_level_3_button_pressed():
	get_tree().change_scene_to_packed(levels[2])


func _on_level_4_button_pressed():
	get_tree().change_scene_to_packed(levels[3])
