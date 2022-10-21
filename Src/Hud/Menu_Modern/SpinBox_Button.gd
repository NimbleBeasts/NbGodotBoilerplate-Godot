@tool
extends Control

## SpinBox button scene
##
## Acts like a SpinBox but in a form of a proper button.

## Theme to derive button colors from.
@export var theme_scene: Theme = preload("res://Src/Hud/Menu_Modern/Menu_Modern.theme")

## Title for the SpinBox Button.
var text := "TITLE"

## Emitted when the button state has changed.
signal spinbox_button_updated(value)


# Colors
var _bg_color_hover: Color
var _font_color_hover: Color
var _font_color_normal: Color

# States
var _is_focused := false
var _choices := []
var _range := []
var _range_step := 1.0
var _current_value
var _original_value


## Set choices and current value to the SpinBox Button
func set_choices(choices: Array, current_value: int):
	_choices = choices
	_current_value = current_value
	_original_value = current_value
	$h/Option.set_text(_format_choice_value(_choices[_current_value]))


## Set range and current value to the SpinBox Button
func set_range(range: Array, current_value: float, step: float):
	_range = range
	_range_step = step
	_current_value = current_value
	_original_value = current_value
	$h/Option.set_text(_format_range_value(_current_value))


func _ready():
	# Choice Button Colors
	var menu_theme: Theme = theme_scene
	var style_box: StyleBox = menu_theme.get_stylebox("hover", "Button")
	assert(style_box, "Menu_Modern: Stylebox not found in theme")
	_bg_color_hover = style_box.bg_color
	_font_color_normal = menu_theme.get_color("font_color", "Button")
	_font_color_hover = menu_theme.get_color("font_hover_color", "Button")
	# TODO: This could be optimized by doing it on higher level and pass down the colors
	$h/Label.set_text(str(text))
	$h/Label.set("theme_override_colors/font_color", _font_color_normal)
	$h/Option.set("theme_override_colors/font_color", _font_color_normal)
	$h/ButtonLast.set("theme_override_colors/font_color", _font_color_normal)
	$h/ButtonNext.set("theme_override_colors/font_color", _font_color_normal)
	$Bg.color = _bg_color_hover
	$Bg.hide()


func _format_choice_value(value) -> String:
	var string: String
	match typeof(value):
		TYPE_BOOL:
			if value == true:
				string = tr("TR_CAPS_ON")
			else:
				string = tr("TR_CAPS_OFF")
		TYPE_VECTOR2:
			string = str(value.x) + "x" + str(value.y)
		TYPE_VECTOR2I:
			string = str(value.x) + "x" + str(value.y)
		_:
			string = str(value)
	return string


func _format_range_value(value) -> String:
	var string: String
	if float(int(_range_step)) == _range_step:
		string = str(value)
	else:
		string = "%0.1f" % value
	return string


func _switch(direction: int):
	_current_value += direction * _range_step
	
	var string: String
	
	if _choices.size() > 0:
		# Choice based spinbox
		if _current_value < 0: _current_value = _choices.size() - 1
		elif _current_value == _choices.size(): _current_value = 0
		
		# Format
		string = _format_choice_value(_choices[_current_value])
	else:
		# Range based spinbox
		_current_value = min(max(_current_value, _range[0]), _range[1])
		
		# Format
		string = _format_range_value(_current_value)
	
	$h/Option.set_text(string)
	emit_signal("spinbox_button_updated", _current_value)


func _input(event):
	if not _is_focused:
		return
	# Keyboard input
	if event is InputEventKey:
		if not event.pressed:
			if event.keycode == KEY_RIGHT:
				_switch(+1)
			elif event.keycode == KEY_LEFT:
				_switch(-1)
	# Joypad input
	elif event is InputEventJoypadButton:
		if not event.pressed:
			if event.button_index == JOY_BUTTON_DPAD_RIGHT:
				_switch(+1)
			elif event.button_index == JOY_BUTTON_DPAD_LEFT:
				_switch(-1)


func _on_focus_entered():
	_is_focused = true
	$Bg.show()
	$h/Label.set("theme_override_colors/font_color", _font_color_hover)
	$h/Option.set("theme_override_colors/font_color", _font_color_hover)
	$h/ButtonLast.set("theme_override_colors/font_color", _font_color_hover)
	$h/ButtonNext.set("theme_override_colors/font_color", _font_color_hover)


func _on_focus_exited():
	_is_focused = false
	$Bg.hide()
	$h/Label.set("theme_override_colors/font_color", _font_color_normal)
	$h/Option.set("theme_override_colors/font_color", _font_color_normal)
	$h/ButtonLast.set("theme_override_colors/font_color", _font_color_normal)
	$h/ButtonNext.set("theme_override_colors/font_color", _font_color_normal)


func _on_mouse_entered():
	_on_focus_entered()


func _on_mouse_exited():
	_on_focus_exited()


func _on_button_last_gui_input(event):
	_on_focus_entered()
	if event is InputEventMouseButton:
		if not event.pressed:
			_switch(-1)


func _on_button_next_gui_input(event):
	_on_focus_entered()
	if event is InputEventMouseButton:
		if not event.pressed:
			_switch(+1)
