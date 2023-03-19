extends Button

var on := "STEPS: ON"
var off := "STEPS: OF"

func _on_pressed():
	if $"/root/GameData".steps_sound:
		text = off
		$"/root/GameData".steps_sound = false
	else:
		text = on
		$"/root/GameData".steps_sound = true
