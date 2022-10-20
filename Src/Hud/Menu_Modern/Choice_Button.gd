@tool
extends Control

const THEME_PATH = "res://Src/Hud/Menu_Modern/Menu_Modern.theme"

signal choice_updated(config_value, choice_id)

@export var text := "TITLE"
@export var config_value := "soundVolume"

var bg_color_hover: Color
var font_color_hover: Color
var font_color_normal: Color

var id := -1
var active := false
var selection_id := 0
var choices := ["1", "2", "3"]

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
	selection_id += direction
	
	if selection_id < 0: selection_id = choices.size() - 1
	elif selection_id == choices.size(): selection_id = 0
	
	$h/Option.set_text(str(choices[selection_id]))
	emit_signal("choice_updated", selection_id)

func set_choices(choices: Array, current_value):
	pass

func set_range(range: Array, current_value):
	pass

func _input(event):
	if not active:
		return
	if event is InputEventKey:
		if not event.pressed:
			if event.keycode == KEY_RIGHT:
				switch(+1)
			elif event.keycode == KEY_LEFT:
				switch(-1)

func _on_focus_entered():
	active = true
	$Bg.show()
	$h/Label.set("theme_override_colors/font_color", font_color_hover)
	$h/Option.set("theme_override_colors/font_color", font_color_hover)
	$h/ButtonLast.set("theme_override_colors/font_color", font_color_hover)
	$h/ButtonNext.set("theme_override_colors/font_color", font_color_hover)

func _on_focus_exited():
	active = false
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
