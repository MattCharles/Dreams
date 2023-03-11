extends Control

@onready var timer = $Timer
@onready var label = $Label

var seconds := 0
var minutes := 0
var hours := 0

func _ready():
	var finish_line = self.get_parent().get_parent().get_node("FinishLine")
	finish_line.finished.connect(stop_timer)

func _process(delta):
	pass


func _on_timer_timeout():
	update_display()

func update_display():
	seconds = seconds + 1
	if seconds == 60:
		seconds = 0
		minutes = minutes + 1
	if minutes == 60:
		minutes = 0
		hours = hours + 1
	
	label.text = "%04d:%02d:%02d" % [hours, minutes, seconds]

func stop_timer():
	print("stopping timer")
	timer.stop()
