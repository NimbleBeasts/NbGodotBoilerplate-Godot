@tool
extends Control

const THEME_PATH = "res://Src/Hud/Menu_Modern/Menu_Modern.theme"

signal choice_updated(config_value, choice_id)

@export var text := "TITLE"
@export var config_value := "soundVolume"

var bg_color_hover: Color
var font_color_hover: Color
var font_color_normal: Color

var _active := false
var _choices := []
var _range := []
var _range_step := 1.0
var _current_value 

func _ready():
	# Choice Button Colors
	var menu_theme: Theme = load(THEME_PATH)
	var style_box: StyleBox = menu_theme.get_stylebox("hover", "Button")
	assert(style_box, "Menu_Modern: Stylebox not found in theme")
	bg_color_hover = style_box.bg_color
	font_color_normal = menu_theme.get_color("font_color", "Button")
	font_color_hover = menu_theme.get_color("font_hover_color", "Button")
	# This could be optimized by doing it on higher level and pass down the colors

	$h/Label.set_text(str(text))
	$h/Label.set("theme_override_colors/font_color", font_color_normal)
	$h/Option.set("theme_override_colors/font_color", font_color_normal)
	$h/ButtonLast.set("theme_override_colors/font_color", font_color_normal)
	$h/ButtonNext.set("theme_override_colors/font_color", font_color_normal)
	$Bg.color = bg_color_hover
	$Bg.hide()


func switch(direction: int):
	_current_value += direction * _range_step
	
	
	if _choices.size() > 0:
		if _current_value < 0: _current_value = _choices.size() - 1
		elif _current_value == _choices.size(): _current_value = 0
		$h/Option.set_text(str(_choices[_current_value]))
	else:
		_current_value = min(max(_current_value, _range[0]), _range[1])
		$h/Option.set_text(str(_current_value))
		
	emit_signal("choice_updated", _current_value)

func set_choices(choices: Array, current_value: int):
	_choices = choices
	_current_value = current_value
	$h/Option.set_text(str(_choices[_current_value]))
	

func set_range(range: Array, current_value: float, step: float):
	_range = range
	_range_step = step
	_current_value = current_value
	$h/Option.set_text(str(_current_value))

func _input(event):
	if not _active:
		return
	# Keyboard input
	if event is InputEventKey:
		if not event.pressed:
			if event.keycode == KEY_RIGHT:
				switch(+1)
			elif event.keycode == KEY_LEFT:
				switch(-1)
	# Joypad input
	elif event is InputEventJoypadButton:
		if not event.pressed:
			if event.button_index == JOY_BUTTON_DPAD_RIGHT:
				switch(+1)
			elif event.button_index == JOY_BUTTON_DPAD_LEFT:
				switch(-1)

func _on_focus_entered():
	_active = true
	$Bg.show()
	$h/Label.set("theme_override_colors/font_color", font_color_hover)
	$h/Option.set("theme_override_colors/font_color", font_color_hover)
	$h/ButtonLast.set("theme_override_colors/font_color", font_color_hover)
	$h/ButtonNext.set("theme_override_colors/font_color", font_color_hover)

func _on_focus_exited():
	_active = false
	$Bg.hide()
	$h/Label.set("theme_override_colors/font_color", font_color_normal)
	$h/Option.set("theme_override_colors/font_color", font_color_normal)
	$h/ButtonLast.set("theme_override_colors/font_color", font_color_normal)
	$h/ButtonNext.set("theme_override_colors/font_color", font_color_normal)



func _on_mouse_entered():
	_on_focus_entered()


func _on_mouse_exited():
	_on_focus_exited()


func _on_button_last_gui_input(event):
	_on_focus_entered()
	if event is InputEventMouseButton:
		if not event.pressed:
			switch(-1)


func _on_button_next_gui_input(event):
	_on_focus_entered()
	if event is InputEventMouseButton:
		if not event.pressed:
			switch(+1)
