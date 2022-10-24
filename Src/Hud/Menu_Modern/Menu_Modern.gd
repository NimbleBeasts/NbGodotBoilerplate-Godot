extends Control


@export var config_button_scene: PackedScene = preload("res://Src/Hud/Menu_Modern/SpinBox_Button.tscn")
@export var category_button_scene: PackedScene = preload("res://Src/Hud/Menu_Modern/Category_Button.tscn")


var _focus_object: Control = null
var _focus_keyboard: bool = false

# Menu settings that has changed but not yet accepted
var _pending_changes := []


func _ready():
	_init_menu()
	
	get_viewport().connect("gui_focus_changed", Callable(self, "_gui_focus_changed"))


func _input(event):
	# If no element has focus and the player uses keyboard or gamepad - grab focus
	if not _focus_object:
		_focus_check(event)


func _init_menu():
	# Init option buttons
	for category in Global.USER_CONFIG_MODEL.configurable:
		# Setup option buttons
		var callback = Callable(self, "_submenu_button_up")
		callback = callback.bind(category.name)
		
		var button = category_button_scene.instantiate()
		button.text = tr(category.tr)
		button.name = category.name
		button.connect("button_up", callback)
		$Views/Settings/w/SubMenu.add_child(button)
	
	$Views/Settings/w/ButtonAccept.hide()
	$Views/Settings/w/OptionMenu.hide()
	
	# Switch to main menu view
	_switch("MainMenu")


func _focus_check(event):
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


func _setup_submenu(category: String):
	# Clear old
	for child in $Views/Settings/w/OptionMenu.get_children():
		#child.disconnect() TODO
		child.queue_free()
	
	# Find configurable option in user config model
	var index := -1
	for i in range(Global.USER_CONFIG_MODEL.configurable.size()):
		if Global.USER_CONFIG_MODEL.configurable[i].name == category:
			index = i
			break
		i += 1
	assert(index != -1, "HUD: Provided category does not exists in user config model")
	
	# Set submenu title
	$Views/Settings/w/Label.set_text( Global.USER_CONFIG_MODEL.configurable[index].tr)
	
	for option in Global.USER_CONFIG_MODEL.configurable[index].options:
		var callback = Callable(self, "_config_button_up")
		callback = callback.bind(category)
		callback = callback.bind(option.name)
		var choice_button = config_button_scene.instantiate()
		choice_button.text = tr(option.tr)
		if option.has("values"):
			choice_button.set_choices(option.values, Global.user_config[category][option.name])
		else:
			choice_button.set_range(option.range, Global.user_config[category][option.name], option.step)
		choice_button.connect("spinbox_button_updated", callback)
		$Views/Settings/w/OptionMenu.add_child(choice_button)


func _config_button_up(value, option, category):
	# Check if pending change entry exists
	var exists := false
	for i in range(_pending_changes.size()):
		if _pending_changes[i].category == category:
			if _pending_changes[i].option == option:
				# Update pending change
				_pending_changes[i].value = value
				exists = true
		i += 1
	
	if not exists:
		# Add new pending change entry
		_pending_changes.append(
			{
				"category": category,
				"option": option,
				"value": value
			}
		)


func _submenu_button_up(category_name):
	_setup_submenu(category_name)
	$Views/Settings/w/SubMenu.hide()
	$Views/Settings/w/OptionMenu.show()
	$Views/Settings/w/ButtonAccept.show()
	_focus_object = null


func _switch(to):
	if to == "MainMenu":
		$Views/Settings.hide()
		$Views/MainMenu.show()
		_focus_object = null
	elif to == "Settings":
		$Views/MainMenu.hide()
		$Views/Settings.show()
		_focus_object = null


func _gui_focus_changed(control: Control) -> void:
	_focus_object = control
	if Input.is_action_pressed("ui_down") or Input.is_action_just_released("ui_down")\
		or Input.is_action_pressed("ui_up") or Input.is_action_just_released("ui_up"):
		_focus_keyboard = true
	else:
		_focus_keyboard = false


func _on_button_quit_button_up():
	get_tree().quit()


func _on_button_settings_button_up():
	_switch("Settings")


func _on_button_new_game_button_up():
	pass


func _on_button_resume_button_up():
	pass # Replace with function body.


func _on_button_back_button_up():
	if $Views/Settings/w/SubMenu.visible:
		_switch("MainMenu")
	else:
		$Views/Settings/w/Label.set_text("TR_MENU_SETTINGS")
		$Views/Settings/w/SubMenu.show()
		$Views/Settings/w/OptionMenu.hide()
		$Views/Settings/w/ButtonAccept.hide()
	_pending_changes = []


func _on_button_accept_button_up():
	for change in _pending_changes:
		for category in Global.USER_CONFIG_MODEL.configurable:
			if change.category == category.name:
				for option in category.options:
					if change.option == option.name:
						# Update config
						Global.user_config[change.category][change.option] = change.value
						if option.has("signal"):
							Events.emit_signal(option.get("signal"), change.value)
						
						# Option found break loop
						break
				# Category found break loop
				break
	# Save config
	Global.core_save_user_config(Global.user_config)
	# Navigate back
	_on_button_back_button_up()
