extends Button

var on := "SOUND: ON"
var off := "SOUND: OF"

func _on_pressed():
	if $"/root/GameData".sound:
		text = off
		$"/root/GameData".sound = false
	else:
		text = on
		$"/root/GameData".sound = true
