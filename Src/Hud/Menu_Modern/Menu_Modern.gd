extends Control


var _settings_update_is_internal := false
var _submenu_entered := false

var _focus_object: Control = null

const THEME := preload("res://Src/Hud/Menu_Modern/Menu_Modern.theme")


func _ready():
	# Setup
	_setup_option_buttons()
	
	_switch("MainMenu")
	_switch_submenu("SubMenu")
	
	get_viewport().connect("gui_focus_changed", Callable(self, "_gui_focus_changed"))


func _setup_option_buttons():
	for category in Global.USER_CONFIG_MODEL.configurable:
		# Setup option buttons
		var callback = Callable(self, "_submenu_button_up")
		callback.bind(category.name)
		
		var button = Button.new()
		button.clip_text = true
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.text = tr(category.tr)
		button.name = category.name
		button.theme = THEME
		button.custom_minimum_size = Vector2i(0, 40)
		button.connect("button_up", callback)
		$Views/Settings/w/SubMenu.add_child(button)
#
#		print(category.name)
#		for option in category.options:
#			print(option.name)




func _submenu_button_up(category_name):
	print(category_name)

func _input(event):
	# If no element has focus and the player uses keyboard or gamepad - grab focus
	if not _focus_object:
		if event is InputEventKey:
			if not event.pressed:
			# TODO: keyboard and gamepad codes
				if event.keycode == KEY_UP or event.keycode == KEY_DOWN:
					if $Views/MainMenu/v/ButtonResume.visible:
						$Views/MainMenu/v/ButtonResume.grab_focus()
					else:
						$Views/MainMenu/v/ButtonNewGame.grab_focus()

func _gui_focus_changed(control: Control) -> void:
	_focus_object = control
	if control != null:
		print(control.name)

func reset():
	_ready()

func _switch(to):
	if to == "MainMenu":
		_update_MainMenu()
		$Views/Settings.hide()
		$Views/MainMenu.show()
	elif to == "Settings":
		_update_Settings()
		$Views/MainMenu.hide()
		$Views/Settings.show()

func _switch_submenu(to):

	
	if (to != "SubMenu"):
		_submenu_entered = true
	else:
		_submenu_entered = false
		$Views/Settings/w/Label.set_text("TR_MENU_SETTINGS")
	
	get_node("Views/Settings/w/"+str(to)).show()


func _update_MainMenu():
	# Nothing to do
	pass

func _update_Settings():
	# Set settings ui to actual values
	
	# Set flag to skip value change signals
	_settings_update_is_internal = true



	# Release flag
	_settings_update_is_internal = false


func _on_button_quit_button_up():
	get_tree().quit()


func _on_button_settings_button_up():
	_switch("Settings")


func _on_button_new_game_button_up():
	pass # Replace with function body.


func _on_button_resume_button_up():
	pass # Replace with function body.


func _on_button_back_button_up():
	if _submenu_entered:
		_switch_submenu("SubMenu")
	else:
		_switch("MainMenu")

# Submenu Buttons
func _on_button_s_video_button_up():
	_switch_submenu("SubVideo")
	$Views/Settings/w/Label.set_text("TR_MENU_SETTINGS_VIDEO")


func _on_button_s_audio_button_up():
	_switch_submenu("SubAudio")
	$Views/Settings/w/Label.set_text("TR_MENU_SETTINGS_AUDIO")


func _on_button_s_controls_button_up():
	_switch_submenu("SubControls")
	$Views/Settings/w/Label.set_text("TR_MENU_SETTINGS_CONTROLS")


func _on_button_s_language_button_up():
	_switch_submenu("SubLanguage")
	$Views/Settings/w/Label.set_text("TR_MENU_SETTINGS_LANGUAGE")



