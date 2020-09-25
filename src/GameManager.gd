# Kickstart Template
# ------------------------------------------------
# Date       | Change
# ------------------------------------------------
# 18/11/2019 | Added Text Debug Menu

extends Control

const levels = [
	"res://src/Levels/Level0.tscn",
]

var state = Types.GameStates.Menu
var lights = true

var levelNode = null
var levelId = 0

func _ready():
	Global.setGameManager(self)
	Global.debugLabel = $Debug
	
	$gameViewport/Viewport.size = Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height"))
	$menuViewport/Viewport.size = Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height"))
	
	stateTransition(Types.GameStates.Menu)

func updateLights():
	for light in get_tree().get_nodes_in_group("light"):
		light.enabled = lights

func stateTransition(to):
	if to == Types.GameStates.Menu:
		$gameViewport.hide()
		$menuViewport.show()
		$menuViewport/Viewport/Menu.show()
		$menuViewport/Viewport/Menu.updateGui()
	elif to == Types.GameStates.Game:
		$gameViewport.show()
		$menuViewport.hide()
		$menuViewport/Viewport/Menu.hide()
		updateLights()
	state = to

func loadLevel(number = 0):
	levelNode = load(levels[number]).instance()
	$gameViewport.get_node("Viewport/LevelHolder").add_child(levelNode)
	updateLights()

func unloadLevel():
	$gameViewport.get_node("Viewport/LevelHolder").remove_child(levelNode)
	levelNode.queue_free()
	levelNode = null

func newGame():
	if levelNode:
		unloadLevel()
	loadLevel(0)
	stateTransition(Types.GameStates.Game)

func setLights(state):
	lights = state

func getLights():
	return lights
