extends Control


var _settings_update_is_internal := false


var _focus_object: Control = null
var _focus_keyboard: bool = false


const THEME := preload("res://Src/Hud/Menu_Modern/Menu_Modern.theme")
const CHOICE_BUTTON_PATH := "res://Src/Hud/Menu_Modern/Choice_Button.tscn"
const CATEGORY_BUTTON_PATH := "res://Src/Hud/Menu_Modern/Category_Button.tscn"


func _ready():
	# Setup
	_setup_option_buttons()
	
	_switch("MainMenu")
	
	get_viewport().connect("gui_focus_changed", Callable(self, "_gui_focus_changed"))


func _physics_process(delta):
	$Label.set_text("Focus: " + str(_focus_object) + "\nKeyboard: " + str(_focus_keyboard))

func _setup_option_buttons():
	for category in Global.USER_CONFIG_MODEL.configurable:
		# Setup option buttons
		var callback = Callable(self, "_submenu_button_up")
		callback = callback.bind(category.name)
		
		var button = preload(CATEGORY_BUTTON_PATH).instantiate()
		button.text = tr(category.tr)
		button.name = category.name
		button.connect("button_up", callback)
		$Views/Settings/w/SubMenu.add_child(button)
#
#		print(category.name)
#		for option in category.options:
#			print(option.name)

func _setup_option_menu(category: String):
	# Clear old
	for child in $Views/Settings/w/OptionMenu.get_children():
		child.queue_free()
	
	var index := -1
	for i in range(Global.USER_CONFIG_MODEL.configurable.size()):
		if Global.USER_CONFIG_MODEL.configurable[i].name == category:
			index = i
			break
		i += 1

	assert(index != -1, "HUD: Provided category does not exists in user config model")
	for option in Global.USER_CONFIG_MODEL.configurable[index].options:
		var callback = Callable(self, "_submenu_button_up")
		callback = callback.bind(category)
		callback = callback.bind(option.name)
		var choice_button = preload(CHOICE_BUTTON_PATH).instantiate()
		choice_button.text = tr(option.tr)
		if option.has("values"):
			choice_button.set_choices(option.values, option.default)
		else:
			choice_button.set_range(option.range, option.default, option.step)
		choice_button.connect("button_up", callback)
		$Views/Settings/w/OptionMenu.add_child(choice_button)


func _submenu_choice_button_up(category_name, option_name):
	print(option_name)

func _submenu_button_up(category_name):
	print("called")
	_setup_option_menu(category_name)
	# TODO: get menu name
	$Views/Settings/w/Label.set_text("TR_MENU_SETTINGS_VIDEO")
	$Views/Settings/w/SubMenu.hide()
	$Views/Settings/w/OptionMenu.show()
	_focus_object = null

func _input(event):
	# If no element has focus and the player uses keyboard or gamepad - grab focus
	if not _focus_object:
		if event is InputEventKey:
			#if not event.pressed:
			# TODO: keyboard and gamepad codes
			if event.keycode == KEY_UP or event.keycode == KEY_DOWN:
				if $Views/MainMenu.visible:
					if $Views/MainMenu/v/ButtonResume.visible:
						$Views/MainMenu/v/ButtonResume.grab_focus()
					else:
						$Views/MainMenu/v/ButtonNewGame.grab_focus()
				else:
					$Views/Settings/w/ButtonBack.grab_focus()

func _gui_focus_changed(control: Control) -> void:
	_focus_object = control
	if control != null:
		print(control.name)
	
	if Input.is_action_pressed("ui_down") or Input.is_action_just_released("ui_down")\
		or Input.is_action_pressed("ui_up") or Input.is_action_just_released("ui_up"):
		_focus_keyboard = true
	else:
		_focus_keyboard = false

func reset():
	_ready()

func _switch(to):
	if to == "MainMenu":
		_update_MainMenu()
		$Views/Settings.hide()
		$Views/MainMenu.show()
		_focus_object = null
	elif to == "Settings":
		_update_Settings()
		$Views/MainMenu.hide()
		$Views/Settings.show()
		_focus_object = null


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
	if $Views/Settings/w/SubMenu.visible:
		_switch("MainMenu")
	else:
		$Views/Settings/w/Label.set_text("TR_MENU_SETTINGS")
		$Views/Settings/w/SubMenu.show()
		$Views/Settings/w/OptionMenu.hide()

