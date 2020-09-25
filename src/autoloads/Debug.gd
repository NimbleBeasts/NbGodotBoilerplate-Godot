extends Node

var menuOpen = false
var subMenu = 0 
var zeroPressed = false

var data = []
var options = []

func _input(event):
	if Global.debug:
		if event is InputEventKey and not event.is_echo():
			if event.pressed:
				#Open Folder/VSCode
				if event.scancode == KEY_F5:
					print("Open Project Folder")
					var arg = ProjectSettings.globalize_path("res://")
					OS.shell_open(arg)
				elif event.scancode == KEY_F6:
					print("Open Project with VSCode")
					var arg = ProjectSettings.globalize_path("res://") + "open_vs.bat"
					OS.execute(arg, [], false)
				#Close Debug Menu
				if menuOpen and event.scancode == KEY_ESCAPE:
					menuOpen = false
				#Open Debug Menu
				elif event.scancode == KEY_F4:
					_displayMenu()
					subMenu = 0
					menuOpen = true
				elif menuOpen:
					_handleOptions(event.scancode)

func _displayMenu():
	print(" ")
	print("Menu============")
	for points in data:
		print(str(points.index) + "." + points.name)
	print("================")

func _displaySubMenu(index):
	print(" ")
	print("SubMenu---------")
	for point in data[subMenu - 1].options:
		print(str(point.index) + "." + point.name)
	print("----------------")

func _handleOptions(code):
	if code == KEY_0 and not zeroPressed:
		zeroPressed = true
		return
	if code >= KEY_0 and code <= KEY_9:
		var index = code - KEY_0
		if zeroPressed:
			index += 10
			zeroPressed = false
		
		print(">"+str(index))
		if subMenu == 0:
			for category in data:
				if category.index == index:
					subMenu = index
					_displaySubMenu(index)
		else:
			for point in data[subMenu - 1].options:
				if point.index == index:
					point.callback.call_func(point.parameter)
					menuOpen = false
					break

func _ready():
#	var cat1 = addCategory("Test 1")
#	addOption(cat1, "Variant 1", funcref(self, "test"), true)
#	addOption(cat1, "Variant 2", funcref(self, "test"), false)
#	var cat2 = addCategory("Test 2")
#	addOption(cat2, "Variant 3", funcref(self, "test"), true)
#	addOption(cat2, "Variant 4", funcref(self, "test"), false)
	pass

func addCategory(categoryName):
	for i in range(data.size()):
		if data[i].name == categoryName:
			return i
			
	var index = data.size() + 1 
	data.append({"index": index, "name": categoryName, "options": []})
	return index 

func addOption(category, optionName, callback, parameter):
	var index = data[category - 1].options.size() + 1
	data[category - 1].options.append({"index": index, "name": optionName, "callback": callback, "parameter": parameter})

func clearOptions(category):
	data[category - 1].options.clear()


func test(value):
	print("-> Selected Value: " + str(value) )
