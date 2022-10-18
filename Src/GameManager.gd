extends Control

var state = Types.GameStates.Menu
var levelNode = null
var current_level: int

func _ready():
	# Set SubViewport Sizes to Project Settings
#	$gameViewport/SubViewport.size = Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height"))
#	$menuViewport/SubViewport.size = Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height"))

	#Global.debugLabel = $Debug

	# Event Hooks
	Events.connect("cfg_music_set_volume",Callable(self,"setMusicVolume"))
	Events.connect("cfg_sound_set_volume",Callable(self,"setSoundVolume"))
	Events.connect("cfg_change_brightness",Callable(self,"setBrightness"))
	Events.connect("cfg_change_contrast",Callable(self,"setContrast"))

	Events.connect("cfg_switch_fullscreen",Callable(self,"_switchFullscreen"))
	Events.connect("new_game",Callable(self,"_newGame"))
	Events.connect("menu_back",Callable(self,"_backToMenu"))

	switchTo(Types.GameStates.Menu)

# State Transition Function
func switchTo(to):
#	if to == Types.GameStates.Menu:
#		$gameViewport.hide()
#		$menuViewport.show()
#		$menuViewport/SubViewport/Menu.show()
#	elif to == Types.GameStates.Game:
#		$gameViewport.show()
#		$menuViewport.hide()
#		$menuViewport/SubViewport/Menu.hide()
	state = to

# Load a level to the LevelHolder node
func loadLevel(number = 0):
	current_level = number
	levelNode = load(Global.levels[number]).instantiate()
	$gameViewport.get_node("SubViewport/LevelHolder").add_child(levelNode)

# Unloads a loaded level
func unloadLevel():
	$gameViewport.get_node("SubViewport/LevelHolder").remove_child(levelNode)
	if levelNode:
		levelNode.queue_free()
	levelNode = null

func reloadLevel():
	unloadLevel()
	loadLevel(current_level)
	get_tree().paused = false

###############################################################################
# Callbacks
###############################################################################

# Event Hook: Back from Game to Menu
func _backToMenu():
	unloadLevel()
	switchTo(Types.GameStates.Menu)

# Event Hook: New Game
func _newGame():
	if levelNode:
		unloadLevel()
	loadLevel(0)
	switchTo(Types.GameStates.Game)

# Event Hook: Update user config for sound
func setSoundVolume(value):
	Global.user_config.soundVolume = value
	Global.saveConfig()

# Event Hook: Update user config for music
func setMusicVolume(value):
	Global.user_config.musicVolume = value
	Global.saveConfig()

func setBrightness(value):
	$gameViewport/SubViewport/WorldEnvironment.environment.adjustment_brightness = value
	Global.user_config.brightness = value
	Global.saveConfig()

func setContrast(value):
	$gameViewport/SubViewport/WorldEnvironment.environment.adjustment_contrast = value
	Global.user_config.contrast = value
	Global.saveConfig()
# Event Hook: Switch to fullscreen mode and update user config
func _switchFullscreen(value):
	Global.setFullscreen(value)
