extends Control

## InputControl button scene
##
## A button element for remapping keys

## Theme to derive button colors from.
@export var theme_scene: Theme = preload("res://Src/Hud/Menu_Modern/Menu_Modern.theme")

## Emitted when a key has been assigned.
signal button_assigned(slot_id, key_event)

@onready var _buttons := [$h/Button0, $h/Button1, $h/Button2, $h/Button3]
# Colors
var _bg_color_hover: Color
var _font_color_hover: Color
var _font_color_normal: Color

# States
var _is_focused := false
var _focused_button = null
var _assign_slot: int = 0
var _set_key := false
var _key_data := []

func _ready():
	# Choice Button Colors
	var menu_theme: Theme = theme_scene
	var style_box: StyleBox = menu_theme.get_stylebox("hover", "Button")
	assert(style_box, "Menu_Modern: Stylebox not found in theme")
	_bg_color_hover = style_box.bg_color
	_font_color_normal = menu_theme.get_color("font_color", "Button")
	_font_color_hover = menu_theme.get_color("font_hover_color", "Button")
	# TODO: This could be optimized by doing it on higher level and pass down the colors
	$h/Label.set("theme_override_colors/font_color", _font_color_normal)
#	$h/Option.set("theme_override_colors/font_color", _font_color_normal)
#	$h/ButtonLast.set("theme_override_colors/font_color", _font_color_normal)
#	$h/ButtonNext.set("theme_override_colors/font_color", _font_color_normal)
	$Bg.color = _bg_color_hover
	$Bg.hide()
	
	connect("button_assigned", Callable(self, "_button_assigned"))
	# TODO feedback loop and remove double assigned buttons

func set_text(string: String):
	$h/Label.set_text(string)

func _update_button_text(button: Button, text):
	#TODO mapping to readable 
	button.text = text

func _button_assigned(a, b):
	if _set_key:
		print("my button assigned")
	else:
		print("other button assigned")

func set_key_data(data: Array):
	_key_data = data
	var i := 0
	for entry in _key_data:
		var node := get_node("h/Button" + str(i))
		if entry.size() > 0:
			node.text = str(entry.code)
		i += 1

func _focus_button(direction: int):
	if _focused_button == null:
		_focused_button = -1
	_focused_button += 1
	
	if _focused_button == _buttons.size(): _focused_button = 0
	if _focused_button < 0: _focused_button = _buttons.size() - 1
	_buttons[_focused_button].grab_focus()
	

func _input(event):
	if _set_key:
		_map_key(event)
		return
	
	if not _is_focused:
		return
	# Keyboard input
	if event is InputEventKey:
		if not event.pressed:
			if event.keycode == KEY_RIGHT:
				_focus_button(+1)
			elif event.keycode == KEY_LEFT:
				_focus_button(-1)
	# Joypad input
	elif event is InputEventJoypadButton:
		if not event.pressed:
			if event.button_index == JOY_BUTTON_DPAD_RIGHT:
				_focus_button(+1)
			elif event.button_index == JOY_BUTTON_DPAD_LEFT:
				_focus_button(-1)

func _map_key(event):
	
	var key_event := {}
	
	# Mouse
	if event is InputEventMouseButton \
		and Global.core_config.controls.allowed_input_devices & Types.InputDeviceType.Mouse:

		if not event.pressed:
			return
		key_event = {
			"type": Types.InputDeviceType.Mouse,
			"device": event.get_device(),
			"code": event.button_index,
		}
		_map_key_done(key_event)

	# Keyboard
	elif event is InputEventKey\
		and Global.core_config.controls.allowed_input_devices & Types.InputDeviceType.Keyboard:

		if not event.pressed:
			return

		if event.keycode == KEY_ESCAPE:
			# Cancel key
			_set_key = false
			_unlock_buttons()
			Events.emit_signal("menu_control_key_assign_finished")
			return
		
		# Assign key
		key_event = {
			"type": Types.InputDeviceType.Keyboard,
			"device": event.get_device(),
			"code": event.keycode,
		}
		_map_key_done(key_event)

	# Joypad Buttons
	elif event is InputEventJoypadButton \
		and Global.core_config.controls.allowed_input_devices & Types.InputDeviceType.Joypad:

		if event.button_index == JOY_BUTTON_BACK:
			# Cancel key
			_set_key = false
			_unlock_buttons()
			Events.emit_signal("menu_control_key_assign_finished")
			return

		# Assign key
		key_event = {
			"type": Types.InputDeviceType.Joypad,
			"device": event.get_device(),
			"code": event.button_index,
		}
		_map_key_done(key_event)

	# Joypad Motion
	elif event is InputEventJoypadMotion \
		and Global.core_config.controls.allowed_input_devices & Types.InputDeviceType.Joypad:
		
		if abs(event.axis_value) > 0.9:
			var value = -1.0
			if event.axis_value > 0.9:
				value = 1.0
			# Assign key
			key_event = {
				"type": Types.InputDeviceType.Joypad,
				"device": event.get_device(),
				"axis": event.axis,
				"axis_value": value
			}
			_map_key_done(key_event)



func _unlock_buttons():
	await get_tree().create_timer(0.150).timeout
	$h/Button0.disabled = false
	$h/Button1.disabled = false
	$h/Button2.disabled = false
	$h/Button3.disabled = false

func _map_key_done(key_event: Dictionary):
	emit_signal("button_assigned", _assign_slot, key_event)
	Events.emit_signal("menu_control_key_assign_finished")
	_unlock_buttons()
	_set_key = false

func _on_focus_entered():
	_is_focused = true
	_focused_button = null
	$Bg.show()
	$h/Label.set("theme_override_colors/font_color", _font_color_hover)
#	$h/Option.set("theme_override_colors/font_color", _font_color_hover)
#	$h/ButtonLast.set("theme_override_colors/font_color", _font_color_hover)
	#$h/ButtonNext.set("theme_override_colors/font_color", _font_color_hover)


func _on_focus_exited():
	_is_focused = false
	_focused_button = null
	$Bg.hide()
	$h/Label.set("theme_override_colors/font_color", _font_color_normal)
#	$h/Option.set("theme_override_colors/font_color", _font_color_normal)
#	$h/ButtonLast.set("theme_override_colors/font_color", _font_color_normal)
#	$h/ButtonNext.set("theme_override_colors/font_color", _font_color_normal)

func _assign_button(id):
	print("ok")
	await get_tree().create_timer(0.150).timeout
	print("cool")
	_set_key = true
	_assign_slot = id
	
	$h/Button0.disabled = true
	$h/Button1.disabled = true
	$h/Button2.disabled = true
	$h/Button3.disabled = true
	
	Events.emit_signal("menu_control_key_assign_entered")

func _on_button_0_button_up():
	_assign_button(0)


func _on_button_1_button_up():
	_assign_button(1)


func _on_button_2_button_up():
	_assign_button(2)


func _on_button_3_button_up():
	_assign_button(3)
