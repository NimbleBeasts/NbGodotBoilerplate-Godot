# NimbleBeasts Godot Boilerplate

## About

This is a simple kickstarter project for NimbleBeasts projects. It comes with some standard features and little helpers as well as a some stuff, no one has time for in a game jam.

## Some Features

- GameManager with level loading/unloading
- Menu with settings (Sound, Music, Fullscreen)
- Fullscreen and upscaler handling
- User config load/save/migration
- Global Signal Driven Events (Events.gd)
- Global Enums (Types.gd)
- Debug Console Menu (Debug.gd)
- Helper functions

---

# Basics

## File Structure

- Assets -> All Resources Go Here

  - Each assets (sounds and sprites) are grouped in folders e.g. Player, Menu.
  - Assets used in multiple locations can be stored in own folders, e.g. Fonts, Musics.

- Shaders -> Every Shader and Shader Scene could be stored here

- Src -> Scenes and Sources

  - \_Autoloads -> Global Singletons
  - Group it wisely and make use of folders, to keep it simple. E.g. Levels, Player, Objects..
  - Scene and source go in the same folder.
  - Single sources go in the parents folder.

---

## Autoloads / Globals / Singletons

The scripts are arranged in the include sequence order.

| File      | Name   | Function                                                                                                                             |
| --------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------ |
| Global.gd | Global | Global constants and variables, also functions which need to be accessed from anywhere or not directly related to the game mechanic. |
| Types.gd  | Types  | Place to define global enumerations which are used in multiple scenes.                                                               |
| Events.gd | Events | Signal Driven Event. Place to define global signals and the connector function.                                                      |
| Debug.gd  | Debug  | Debug Console Menu. Can be used as a cheat menu for debugging purpose.                                                               |

---

## Cool Features

In debugging mode while running the game you have the following hotkeys:

| Hotkey | Description                         |
| ------ | ----------------------------------- |
| F4     | Debug console to execute commands   |
| F5     | Open project directory              |
| F6     | Open VS code (executes open_vs.bat) |

---

## Where to Start

The boilerplates entry point is the GameManager scene. The game manager consists of two independet viewports one for the game and one for the menu. From here you can access the menu. Levels will be stored in the Global.gd 'levels' constant. A level will then be added as a child to the LevelHolder node within the gameViewport.

In previous version of this boilerplate the GameManager was the central gateway for communication with nodes. For obvious reasons it was replaced with 'Signal Driven Events' (Events.gd). Allowing to initiate and hook events from all nodes.

---

# Coding

## Signal Driven Events

Before the 'Signal Driven Events' where included there was the idea of getting rid of get_parent() cascades. In a first approach we introduced the GameManager node which was linked in the Global.gd and therefore accessible from all nodes. As this became very intransparent, we've decided to utilize Godot Signals.
To make them accessible globally, all (global) signals are defined in the Events.gd. Also providing a 'connect_signal' function to use it everywhere.

So why is it cool anyway?

**Interacting with a node from multiple locations**
So we all need an accoustic feedback for button clicks. If you have an ingame menu and also the main menu. You could put in both scenes an AudioStreamPlayer. But if you change something (pitch, volume, sound effect...) you will also have to adapt it in the other node or make a own scene for it. With Events.gd you can simply emit a signal to play the sound.

**No get_parent() cascades**
When the player needs to interact with the camera, e.g. scene transition, shake, .., you may have to find the camera first. E.g. get_parent().get_parent().get_node("Camera2D"). If you add another node inbetween you will also have to adapt the cascade. Or you can just simply emit a signal like:

```
Events.emit_signal("move_camera", position)
```

**Calling code in multiple nodes**
Especially in mobile games you have a button to mute the sound or music. But you also can change it in the menu. To keep the indications (on/off) synced, the boilerplate utilizes signals.

```
# Turn sound off
Events.emit_signal("switch_sound", false)
```

Via the event hooking the emited signal is processed in multiple locations:

```
# HUD.gd
Events.connect_signal("switch_sound", self, "updateSoundButtonIndication")
```

```
# Menu.gd
Events.connect_signal("switch_sound", self, "updateSoundButtonIndication")
```

**Workflow**

1. Define a new signal in the Events.gd
2. Hook on the signal using 'Events.connect_signal(...)'
3. Emit signal using 'Events.emit_signal(...)'

---

## Upscaler / Fullscreen

This template is optimized for pixel art games with predefined upscaling of 2 (window mode) or 3 (fullscreen mode). However you can change this code easily:

1. Define the desired upscaled resolution (e.g. 1920x1080)
2. Define upscaler (pixel size representation) (e.g. 3)
3. Divide desired resolution with the upscaler and set the window size in your project settings

The default mode is windowed-mode. In the 'Global.gd' you will have to adapt the 'videoSetup()' call with your desired upscaler value. And also adapt the switchFullscreen() function.

---

## Menu

Each menu screen is a Control node. In this boilerplate there are two screens included. Main screen and settings screen. When adding a new menu screen, make sure to add the case in the 'switchTo' function, add a line in 'hideAllMenuScenes' and extend the MenuState enum if needed.
It is intended to only place menu related logic here. Turning sound/music on and off or switching to fullscreen will be handled elsewhere (GameManager).

---

## Level System

There is a simple level loading mechanism included in this boilerplate. In the Global.gd a constant called 'levels' keeps an array of all the levels. A loaded level will be added as a child in the GameManagers node 'LevelHolder'. It will be unloaded if the player returns to the menu.
This could be easily extended to load the next level as well, reload the current level or display a end game screen.

---

## AudioPlayer

All audio files are managed in a single place: Src/AudioPlayer/AudioPlayer.tscn

To add new sounds make a new AudioStreamPlayer or AudioStreamPlayer2D within the AudioPlayer.tscn. Set the Bus to Sound/Music and add your new sound to the playSound(..) function.

**Examples**

Play a sound:

```
# signal play_sound(sound, volume, pos)
Events.emit_signal("play_sound", "menu_click")
```

Playing a 2D sound:

```
# signal play_sound(sound, volume, pos)
var pos = position
Events.emit_signal("play_sound", "menu_click", 1.0, pos)
```

**Signals**

| Signal                         | Type                                  | Description                                         |
| ------------------------------ | ------------------------------------- | --------------------------------------------------- |
| play_sound(sound, volume, pos) | String, float = 1.0, Vector2 = (0, 0) | Used to play a sound file from the AudioPlayer node |
| switch_sound(value)            | bool                                  | Used to turn off the sound. State is handled in GM. |
| switch_music(value)            | bool                                  | Used to turn off the music. State is handled in GM. |

---

## Debug Console

While the project is running press F4 to open the console. You can add multiple categories with multiple options. This is useful for e.g. level change, respawn and set turn/life/ammo/stuff.

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

---

## Config Migration

Sometimes when you update the game, you will also have to store some more user configuration. As the user may have stored an older cfg file already, this file needs to be updated. Therefore the Global.gd file contains a constant CONFIG_VERSION. While loading the user config the version number will be checked. If there is a missmatch 'migrateConfig(..)' will be called.

In the migrateConfig function you can update for different scenarios. e.g. version 0 to 2, or 1 to 5. An update mechanism could be:

```
func migrateConfig(data):
	for i in range(data.configVersion, CONFIG_VERSION):
		match data.configVersion:
			0:
				update config here
				data.configVersion = 1
			_:
				print("error: migration variant not found")
	return data
```

Note: Adding new userConfig members also requires changes in the loadConfig() function. This could be adapted if you know what you are doing :)
