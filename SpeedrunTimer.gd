extends Control

@onready var label = $Label

var time = 0
var timer_on := false

func _ready():
	timer_on = true
	var finish_line = self.get_parent().get_node("FinishLine")
	finish_line.finished.connect(stop_timer)

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
	print(str(days))
	if days >= 1:
		time_passed = "%02d:%02d:%02d:%02d:%03d" % [days, hours, mins, secs, mills]
	elif hours >= 1:
		time_passed = "%02d:%02d:%02d:%03d" % [hours, mins, secs, mills]
	else:
		time_passed = "%02d:%02d:%03d" % [mins, secs, mills]
	
	label.text = time_passed

func stop_timer():
	timer_on = false

func start_timer():
	timer_on = true
	
func restart_timer():
	timer_on = true
	time = 0
