#extends Node
#
## Console Debug Menu
##
## Can be used as a cheat menu for debugging purpose. 
##
## Usage:
##	var cat1 = addCategory("Test 1")
##	addOption(cat1, "Variant 1", funcref(self, "test"), true)
##	addOption(cat1, "Variant 2", funcref(self, "test"), false)
##
##	var cat2 = addCategory("Test 2")
##	addOption(cat2, "Variant 3", funcref(self, "test"), true)
##	addOption(cat2, "Variant 4", funcref(self, "test"), false)
## 
## func test(val: bool):
## 	...
#
##warning-ignore-all:unused_class_variable
#
#var isMenuOpen = false
#var subMenu = 0 
#var zeroPressed = false
#
#var data = []
#var options = []
#
################################################################################
## Global Functions
################################################################################
#
## Test Function
#func test(value):
#	print("-> Selected Value: " + str(value) )
#
## Adds a new category to the main menu
#func addCategory(categoryName):
#	for i in range(data.size()):
#		if data[i].name == categoryName:
#			return i
#
#	var index = data.size() + 1 
#	data.append({"index": index, "name": categoryName, "options": []})
#	return index 
#
## Adds a new option to the category
#func addOption(category, optionName, callback, parameter):
#	var index = data[category - 1].options.size() + 1
#	data[category - 1].options.append({"index": index, "name": optionName, "callback": callback, "parameter": parameter})
#
## Removes options from category
#func clearOptions(category):
#	data[category - 1].options.clear()
#
################################################################################
## Local Functions
################################################################################
#
## Input Hook: Handle Coder Input
#func _input(event: InputEvent):
#	if Global.DEBUG:
#		if event is InputEventKey and not event.is_echo():
#			if event.pressed:
#				#Open Folder/VSCode
#				if event.scancode == KEY_F5:
#					print("Open Project Folder")
#					var arg = ProjectSettings.globalize_path("res://")
#					#warning-ignore:return_value_discarded
#					OS.shell_open(arg)
#				elif event.scancode == KEY_F6:
#					print("Open Project with VSCode")
#					var arg = ProjectSettings.globalize_path("res://") + "open_vs.bat"
#					#warning-ignore:return_value_discarded
#					OS.execute(arg, [], false)
#				#Close Debug Menu
#				if isMenuOpen and event.scancode == KEY_ESCAPE:
#					isMenuOpen = false
#				#Open Debug Menu
#				elif event.scancode == KEY_F4:
#					_displayMenu()
#					subMenu = 0
#					isMenuOpen = true
#				elif isMenuOpen:
#					_handleOptions(event.scancode)
#
## Output the Main Menu
#func _displayMenu():
#	print(" ")
#	print("Menu============")
#	for points in data:
#		print(str(points.index) + "." + points.name)
#	print("================")
#
## Output a Sub Menu
#func _displaySubMenu(_index):
#	print(" ")
#	print("SubMenu---------")
#	for point in data[subMenu - 1].options:
#		print(str(point.index) + "." + point.name)
#	print("----------------")
#
## Handle coder input
#func _handleOptions(code):
#	if code == KEY_0 and not zeroPressed:
#		zeroPressed = true
#		return
#	if code >= KEY_0 and code <= KEY_9:
#		var index = code - KEY_0
#		if zeroPressed:
#			index += 10
#			zeroPressed = false
#
#		print(">"+str(index))
#		if subMenu == 0:
#			for category in data:
#				if category.index == index:
#					subMenu = index
#					_displaySubMenu(index)
#		else:
#			for point in data[subMenu - 1].options:
#				if point.index == index:
#					point.callback.call_func(point.parameter)
#					isMenuOpen = false
#					break
#
