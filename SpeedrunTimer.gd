extends Control

@onready var label = $Label

class SpeedrunTimer:
	var time := 0.0
	var timer_on := false
	var mills := 0.0
	var secs := 0.0
	var mins := 0.0
	var hours := 0.0
	var days := 0.0
	
	func update(delta:float):
		time += delta
			
	func is_faster_than(other:SpeedrunTimer) -> bool:
		return time > other.time
		
	func print_formatted_time() -> String:
		mills = fmod(time, 1) * 1000
		secs = fmod(time, 60)
		mins = fmod(time, 3600) / 60
		hours = fmod(fmod(time, 3600 * 60) / 3600, 24)
		days = fmod(time, 12960000) / 86400
		if days >= 1:
			return "%02d:%02d:%02d:%02d:%03d" % [days, hours, mins, secs, mills]
		elif hours >= 1:
			return "%02d:%02d:%02d:%03d" % [hours, mins, secs, mills]
		else:
			return "%02d:%02d:%03d" % [mins, secs, mills]
			
	func start():
		timer_on = true

var timer := SpeedrunTimer.new()

signal finished_level(time:float)

func _ready():
	timer.start()
	var finish_lines = get_tree().get_nodes_in_group("finish_lines")
	for finish_line in finish_lines:
		finish_line.finished.connect(finish_level)

func _process(delta):
	if not timer.timer_on:
		return
	timer.update(delta)
	
	label.text = timer.print_formatted_time()

func finish_level():
	stop_timer()
	emit_signal("finished_level", timer.time)

func stop_timer():
	timer.timer_on = false

func start_timer():
	timer.start()
	
func restart_timer():
	timer.timer_on = true
	timer.time = 0
