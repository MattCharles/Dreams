extends Control

@onready var label = $Label

var time = 0
var timer_on := false

signal finished_level(time:String)

func _ready():
	timer_on = true
	var finish_lines = get_tree().get_nodes_in_group("finish_lines")
	for finish_line in finish_lines:
		finish_line.finished.connect(finish_level)

func _process(delta):
	if not timer_on:
		return
	time += delta
	
	var mills = fmod(time, 1) * 1000
	var secs = fmod(time, 60)
	var mins = fmod(time, 3600) / 60
	var hours = fmod(fmod(time, 3600 * 60) / 3600, 24)
	var days = fmod(time, 12960000) / 86400
	var time_passed := ""
	if days >= 1:
		time_passed = "%02d:%02d:%02d:%02d:%03d" % [days, hours, mins, secs, mills]
	elif hours >= 1:
		time_passed = "%02d:%02d:%02d:%03d" % [hours, mins, secs, mills]
	else:
		time_passed = "%02d:%02d:%03d" % [mins, secs, mills]
	
	label.text = time_passed

func finish_level():
	stop_timer()
	emit_signal("finished_level", label.text)

func stop_timer():
	timer_on = false

func start_timer():
	timer_on = true
	
func restart_timer():
	timer_on = true
	time = 0
