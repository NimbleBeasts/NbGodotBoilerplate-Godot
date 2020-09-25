# NbKickstarter
Kickstart Project


## About
This is a simple kickstarter project for NimbleBeasts projects. It comes with some standard features and little helpers as well as a some stuff, no one has time for in a game jam.

## Structure

- assets -> All the resources needed
  - art -> All the art stuff
  - fonts -> Fonts
  - sounds -> Obviously sounds :D

- src -> Scenes and Sources
  - autoloads -> Singletons. Include order: global -> types -> debug
  - Levels -> (Can be removed if static level)
  - Menu -> Menu Scene and Code

## Game Manager
The idea is to get rid of most get_parent() cascade and introduce a game manager which holds most of the stuff. The game manager is accessible by the global singleton, e.g:
Global.gm.loadLevel(0)
or
Global.getGameManager().loadLevel(0)

## Starting Point
By default src/Levels/Level0.tscn is added to the gameViewport and serves as a first starting point.
Tipp: Hide the BootSplash node in the GameManager scene for faster loading :)

# Debugging
The Kickstart project comes with a bunch of cool debugging tools, including a console based selection menu.

## Open Folder / VScode
- While the project is running press F5 to open the project directory.
- While the project is running press F6 to open the project directory with VSCode.

## Console-Menu
While the project is running press F4 to open the console. You can add multiple categories with multiple options. This is useful for e.g. level change, respawn and set turn/life/ammo/stuff.

### How To
This is an example using the console on a player node:

```
func _ready():
	DebugSetup()

func DebugSetup():
	if Global.debug:
		var debugCat = Debug.addCategory("PlayerInfo")
		Debug.clearOptions(debugCat)
		Debug.addOption(debugCat, "Position" , funcref(self, "DebugGetPosition"), null)
		Debug.addOption(debugCat, "GodMode Toggle" , funcref(self, "DebugToggleGodMode"), null)

func DebugGetPosition(to):
	print(position)

func DebugToggleGodMode(nil):
	godMode = !godMode
	print("GodMode: " + str(godMode))
```

addCategory adds a new category if not already exists. clearOptions removes relicts of old scenes which may have re-instanced.
addOption takes the category handle, the displayed name of the option, a function reference and arguments.
