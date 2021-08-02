extends Button

func _on_BaseButton_button_up():
	Events.emit_signal("play_sound", "menu_click")
