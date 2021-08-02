###############################################################################
# Copyright (c) 2020 NimbleBeasts
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
###############################################################################

extends Node

# Version
const GAME_VERSION = 0.2
const CONFIG_VERSION = 0 # Used for config migration
# Debug Options
const DEBUG = true

# Nb Plugin Config
const NB_PLUGIN_CONFIG = {
	"gameId": "gameId",
	"filePassword": "password",
	"magic": "magiccode",
	"devlogUrl": "https://raw.githubusercontent.com/NimbleBeasts/NbGodotBoilerplate/master/_Org/devlog/Boilerplate_"+ "%0.1f" % GAME_VERSION +".txt"
}

const supportedResolutions = [
	Vector2(1280, 720), #our default
	Vector2(1366, 768), #7.47%
	Vector2(1920, 1080), #67.60%
	Vector2(2560, 1440), #8.23%
	Vector2(3840, 2160) #2.41%
	]
# Level Array
const levels = [
	"res://Src/Levels/Level0.tscn",
]

var gameState = {
	date = 0
} setget setGameState

func setGameState(value: Dictionary) -> void:
	gameState = value

# Debug Settings
#warning-ignore:unused_class_variable
var debugLabel = null

# User Config - These are also the default values
var userConfig = {
	"configVersion": CONFIG_VERSION,
	"highscore": 0,
	"soundVolume": 8,
	"musicVolume": 8,

	"fullscreen": false,
	"brightness": 1.0,
	"contrast": 1.0,
	"resolution": {"w": 1280, "h": 720},
	"language": "en"
}

# RNG base
var rng = RandomNumberGenerator.new()
var stateSeed = int(3458764513820540928)

###############################################################################
# Functions
###############################################################################

func _ready():
	print("Starting: " + str(ProjectSettings.get_setting("application/config/name")) + " v" + getVersionString())
	print("Date: " + getDateTimeStringFromUnixTime(getLocalUnixTime()))
	print("Debug: " + str(OS.is_debug_build()))
	print("Soft-Debug: "+ str(DEBUG))
	rng.randomize()
	loadConfig()
	switchFullscreen()
	
func getDateTimeStringFromUnixTime(unixTime):
	var dict = OS.get_datetime_from_unix_time(unixTime)
	return "%0*d" % [2, dict.day] + "/"  + "%0*d" % [2, dict.month] + "/" + str(dict.year) + " - " + "%0*d" % [2, dict.hour] + ":" + "%0*d" % [2, dict.minute]

func getLocalUnixTime():
	#Unix Timestamp is GMT based, but we want local time instead
	var date = OS.get_datetime_from_unix_time(OS.get_unix_time())
	var time = OS.get_time()
	date.hour = time.hour
	date.minute = time.minute
	return OS.get_unix_time_from_datetime(date)

func getSaveGameState():
	var retVal = []
	for i in range(3):
		var saveFile = File.new()
		if saveFile.file_exists("user://save_"+ str(i) + ".cfg"):
			var date = -1
			var level = -1
			saveFile.open("user://save_"+ str(i) + ".cfg", File.READ)
			var data = parse_json(saveFile.get_line())
			if data:
				if data.has("date") and data.has("level"):
					date = data.date
					level = data.level.id
			retVal.append({"state": true, "date": date, "level": level})
		else:
			retVal.append({"state": false, "date": 0, "level": -1})
	return retVal

# Save Game
func saveGame(slotId):
	var saveFile = File.new()
	gameState.date = getLocalUnixTime()
	saveFile.open("user://save_"+ str(slotId) + ".cfg", File.WRITE)
	saveFile.store_line(to_json(gameState))
	saveFile.close()
	Events.emit_signal("hud_game_hint", tr("HUD_GAME_SAVED"))
	Events.emit_signal("hud_save_window_exited")

# Load Game
func loadSave(slotId):
	var saveFile = File.new()
	if not saveFile.file_exists("user://save_"+ str(slotId) + ".cfg"):
		print("Save Game Not Found")
	
	saveFile.open("user://save_"+ str(slotId) + ".cfg", File.READ)
	var data = parse_json(saveFile.get_line())
	gameState = data.duplicate()

# Config Save
func saveConfig():
	var cfgFile = File.new()
	cfgFile.open("user://config.cfg", File.WRITE)
	cfgFile.store_line(to_json(userConfig))
	cfgFile.close()

# Config Load
func loadConfig():
	var cfgFile = File.new()
	if not cfgFile.file_exists("user://config.cfg"):
		saveConfig()
		return
	
	cfgFile.open("user://config.cfg", File.READ)
	var data = parse_json(cfgFile.get_line())
	cfgFile.close()
	
	# Check if the user has an old config, so update it
	if data.configVersion < CONFIG_VERSION:
		userConfig = migrateConfig(data)
		saveConfig()

	# Copy over userConfig
	userConfig.highscore = data.highscore
	userConfig.fullscreen = data.fullscreen
	userConfig.musicVolume = data.musicVolume
	userConfig.soundVolume = data.soundVolume
	userConfig.resolution = data.resolution
	userConfig.brightness = data.brightness
	userConfig.contrast = data.contrast
	userConfig.language = data.language
	# When stuck here, the config attributes have been changed.
	# Delete the Config.cfg to solve this issue.
	# Project->Open Project Data Folder-> Config.cfg
	#
	# Do NOT optimize it:
	# Sure this can be just copied, but you may miss if some settings are not
	# saved correctly. Also for updates please consider the migration mechanism.

# Config Migration
func migrateConfig(data):
#	for i in range(data.configVersion, CONFIG_VERSION):
#		match data.configVersion:
#			0:
#				update config here
#				data.configVersion = 1
#			_:
#				print("error: migration variant not found")
	return data


# Set Fullscreen Mode
func setFullscreen(val: bool):
	userConfig.fullscreen = val
	saveConfig()
	
	switchFullscreen()

func setResolution(val: int):
	userConfig.resolution = {
		"w": supportedResolutions[val].x,
		"h": supportedResolutions[val].y
	}
	saveConfig()
	
	switchResolution()



func switchResolution():
	OS.set_window_size(Vector2(userConfig.resolution.w, userConfig.resolution.h))
	#Center the window
	OS.center_window()

# Perform Fullscreen Switch
func switchFullscreen():
	if not userConfig.fullscreen:
		OS.window_fullscreen = false
		switchResolution()
		
	else:
		OS.window_fullscreen = true

# PRNG
func prng():
	stateSeed = int((rng.randi() + 1) * stateSeed) + 1
	return abs(stateSeed)

# PRNG by Chance in Percentage
func prngByChance(chanceInPercent):
	var value = prng() % 100
	if value <= chanceInPercent:
		return true
	return false

# Get Version
func getVersion():
	return GAME_VERSION
	
# Get Version String
func getVersionString():
	var versionString = "%2.1f" % (GAME_VERSION) 
	
	if DEBUG:
		versionString += "-debug"

	return versionString
