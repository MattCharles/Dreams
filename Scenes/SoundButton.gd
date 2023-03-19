extends Button

var on := "MUSIC: ON"
var off := "MUSIC: OF"

func _on_pressed():
	if $"/root/GameData".sound:
		text = off
		$"/root/GameData".sound = false
	else:
		text = on
		$"/root/GameData".sound = true
