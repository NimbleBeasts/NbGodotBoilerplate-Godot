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
const GAME_VERSION = 0.1
const CONFIG_VERSION = 0 # Used for config migration
# Debug Options
const DEBUG = true

# Nb Plugin Config
const NB_PLUGIN_CONFIG = {
	"gameId": "gameId",
	"filePassword": "password",
	"magic": "magiccode"
}

# Level Array
const levels = [
	"res://Src/Levels/Level0.tscn",
]

# Debug Settings
var debugLabel = null

# User Config - These are also the default values
var userConfig = {
	"configVersion": CONFIG_VERSION,
	"highscore": 0,
	"sound": true,
	"music": true,
	"fullscreen": false
}

# RNG base
var rng = RandomNumberGenerator.new()
var stateSeed = int(3458764513820540928)

###############################################################################
# Functions
###############################################################################

func _ready():
	print("Starting: " + str(ProjectSettings.get_setting("application/config/name")) + " v" + getVersionString())
	print("Debug: " + str(OS.is_debug_build()))
	print("Soft-Debug: "+ str(DEBUG))
	rng.randomize()
	loadConfig()
	videoSetup(2)
	switchFullscreen()

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
	
	# Check if the user has an old config, so update it
	if data.configVersion < CONFIG_VERSION:
		data = migrateConfig(data)
		saveConfig()
	
	# Copy over userConfig
	userConfig.highscore = data.highscore
	userConfig.fullscreen = data.fullscreen
	userConfig.sound = data.sound
	userConfig.music = data.music
	# When stuck here, the config attributes have been changed.
	# Delete the Config.cfg to solve this issue.
	# Project->Open Project Data Folder-> Config.cfg
	#
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


# Window Scaler
func videoSetup(scale = 2):
	var initSize = Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height"))
	var screen_size = OS.get_screen_size(OS.get_current_screen())
	var window_size = initSize * scale
	var centered_pos = (screen_size - window_size) / 2
	OS.set_window_position(centered_pos)
	OS.set_window_size(window_size)

# Set Fullscreen Mode
func setFullscreen(val: bool):
	userConfig.fullscreen = val
	saveConfig()
	
	switchFullscreen()

# Perform Fullscreen Switch
func switchFullscreen():
	if not userConfig.fullscreen:
		OS.window_fullscreen = false
		videoSetup(2)
	else:
		videoSetup(3)
		OS.window_fullscreen = true

# PRNG
func prng():
	#TODO monte carlo simulation over rng
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
