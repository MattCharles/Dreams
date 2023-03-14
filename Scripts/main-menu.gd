extends Control

@onready var pizza_label = $Pizza
@onready var dream_label = $Dreams

@onready var pizza_target = $PizzaTarget
@onready var dream_target = $DreamTarget

@onready var start_button = $Start
@onready var options_button = $Options
@onready var quit_button = $Quit

@onready var start_target = $StartTarget
@onready var options_target = $OptionsTarget
@onready var quit_target = $QuitTarget

var center_of_screen := Vector2(0, 0)

const TITLE_MAX_TRAVEL := Vector2(1000, 1000) # Longest distance title will follow mouse
const SUBTITLE_MAX_TRAVEL := Vector2(200, 200) # Longest distance title will follow mouse

const HOVER_OFFSET_VECTOR := Vector2(100, 0)
const INTRO_DELAY := 5 # How long should we allow for the intro to play before setting position with mouse?
var intro := true

func _process(delta: float) -> void:
	if not intro:
		var pizza_dist_to_mouse = (get_global_mouse_position() - center_of_screen).clamp(-TITLE_MAX_TRAVEL, TITLE_MAX_TRAVEL)
		var dream_dist_to_mouse = (get_global_mouse_position() - center_of_screen).clamp(-SUBTITLE_MAX_TRAVEL, SUBTITLE_MAX_TRAVEL)
		
		pizza_label.position = lerp(pizza_target.position, pizza_dist_to_mouse, delta * 2)
		dream_label.position = lerp(dream_target.position, dream_dist_to_mouse, delta * 2)

func _ready():
	var rect = get_viewport_rect()
	center_of_screen = rect.size / 2
	paint_menu()
	get_tree().create_timer(INTRO_DELAY).timeout.connect(end_intro)
	
func end_intro():
	intro = false

func paint_menu():
	pizza()
	start()
	
func pizza():
	var pizza_position_tween = get_tree().create_tween()
	var pizza_alpha_tween = get_tree().create_tween()
	pizza_position_tween.tween_property(pizza_label, "position",
			pizza_target.position, 2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	pizza_alpha_tween.tween_property(pizza_label, "modulate", Color(1, 1, 1, 1), 1).set_ease(Tween.EASE_IN)
	
	pizza_position_tween.tween_callback(dream)

func dream():
	var dream_tween = get_tree().create_tween()
	dream_tween.set_parallel(true)
	dream_tween.tween_property(dream_label, "position",
			dream_target.position, 2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	dream_tween.tween_property(dream_label, "modulate", Color(1, 1, 1, 1), .5).set_ease(Tween.EASE_IN)

func start():
	var start_button_tween = get_tree().create_tween()
	var position_tween = get_tree().create_tween()
	position_tween.tween_property(start_button, "position",
			start_target.position, 5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	start_button_tween.tween_property(start_button, "modulate", Color(1, 1, 1, 1), .5).set_ease(Tween.EASE_IN)
	
	start_button_tween.tween_callback(options)
	
func options():
	var options_button_tween = get_tree().create_tween()
	var position_tween = get_tree().create_tween()
	position_tween.tween_property(options_button, "position",
			options_target.position, 5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	options_button_tween.tween_property(options_button, "modulate", Color(1, 1, 1, 1), .5).set_ease(Tween.EASE_IN)
	
	options_button_tween.tween_callback(quit)
	
func quit():
	var quit_button_tween = get_tree().create_tween()
	var position_tween = get_tree().create_tween()
	quit_button_tween.set_parallel(true)
	position_tween.tween_property(quit_button, "position",
			quit_target.position, 5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	quit_button_tween.tween_property(quit_button, "modulate", Color(1, 1, 1, 1), 1).set_ease(Tween.EASE_IN)

func _on_start_pressed():
	get_tree().change_scene_to_file("res://Scenes/pizza_level.tscn")

func _on_options_pressed():
	print("Ain't no options mang")
	

func _on_quit_pressed():
	get_tree().quit()

func _on_start_mouse_entered():
	var position_tween = get_tree().create_tween()
	position_tween.tween_property(start_button, "position",
			start_target.position + HOVER_OFFSET_VECTOR, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)


func _on_options_mouse_entered():
	var position_tween = get_tree().create_tween()
	position_tween.tween_property(options_button, "position",
			options_target.position + HOVER_OFFSET_VECTOR, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	


func _on_quit_mouse_entered():
	var position_tween = get_tree().create_tween()
	position_tween.tween_property(quit_button, "position",
			quit_target.position + HOVER_OFFSET_VECTOR, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	


func _on_start_mouse_exited():
	var position_tween = get_tree().create_tween()
	position_tween.tween_property(start_button, "position",
			start_target.position, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	


func _on_options_mouse_exited():
	var position_tween = get_tree().create_tween()
	position_tween.tween_property(options_button, "position",
			options_target.position, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	


func _on_quit_mouse_exited():
	var position_tween = get_tree().create_tween()
	position_tween.tween_property(quit_button, "position",
			quit_target.position, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	
