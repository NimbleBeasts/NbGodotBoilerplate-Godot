###############################################################################
# Copyright (c) 2022 NimbleBeasts
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
extends "res://NbCore/Global.gd"
##
## Global singleton
##
## @desc:
##		This is mainly used for configurative purposes. As well as global helper
##		functions.
##

const GAME_VERSION = 1.0
const CONFIG_VERSION = 1




## Boilerplate config
var core_config := {
	"rng_default_seed": 0,
	"devlog_url": "https://raw.githubusercontent.com/NimbleBeasts/NbGodotBoilerplate/master/_Org/devlog/Boilerplate_"+ "%0.1f" % GAME_VERSION +".txt",
	"user_config": {
		"version": 1,
		"auto_upgrade": true,
		"sanity_check": true,
	},
	"video": {
		"supported_resolutions": [
			#Vector2i(320, 180),
			#Vector2i(640, 360),
			Vector2i(1280, 720), #our default
			Vector2i(1366, 768), #7.47%
			Vector2i(1920, 1080), #67.60%
			Vector2i(2560, 1440), #8.23%
			Vector2i(3840, 2160) #2.41%
		],
		"support_fullscreen": true,
		"upscaler": {
			"enabled": true,
			"base_resolution": Vector2(320, 180),
		}
		
			
	}
	
}


const USER_CONFIG_MODEL := {
	"meta": {
		"configVersion": "CONFIG_VERSION",
		"highscore": 0
	},
	"configurable": [
		{
			"name": "video",
			"tr": "TR_MENU_SETTINGS_VIDEO",
			"options": [
				{
					"name": "resolution",
					"tr": "TR_MENU_SETTINGS_RESOLUTION",
					"values": [
						#Vector2(320, 180),
						#Vector2(640, 360),
						Vector2(1280, 720), #our default
						Vector2(1366, 768), #7.47%
						Vector2(1920, 1080), #67.60%
						Vector2(2560, 1440), #8.23%
						Vector2(3840, 2160) #2.41%
					],
					"default": 0,
					"signal": "menu_resolution_changed"
				},
				{
					"name": "fullscreen",
					"tr": "TR_MENU_SETTINGS_FULLSCREEN",
					"values": [
						false,
						true
					],
					"default": 0,
					"signal": "menu_fullscreen_changed"
				},
				{
					"name": "vsync",
					"tr": "TR_MENU_SETTINGS_VSYNC",
					"values": [
						false,
						true
					],
					"default": 1,
					"signal": "menu_vsync_changed"
				},
				{
					"name": "brightness",
					"tr": "TR_MENU_SETTINGS_BRIGHTNESS",
					"range": [
						0.5,
						1.5
					],
					"step": 0.1,
					"default": 1.0,
					"signal": "menu_vsync_changed"
				},
			]
		},
		{
			"name": "audio",
			"tr": "TR_MENU_SETTINGS_AUDIO",
			"options": [
				{
					"name": "sound",
					"tr": "TR_MENU_SETTINGS_SOUND",
					"range": [
						0,
						100
					],
					"step": 5,
					"default": 50,
					"signal": "menu_sound_changed"
				},
				{
					"name": "music",
					"tr": "TR_MENU_SETTINGS_MUSIC",
					"range": [
						0,
						100
					],
					"step": 5,
					"default": 50,
					"signal": "menu_music_changed"
				},
			]
		},
		{
			"name": "language",
			"tr": "TR_MENU_SETTINGS_LANGUAGE",
			"options": [
				{
					"name": "language",
					"tr": "TR_MENU_SETTINGS_LANGUAGE",
					"values": [
						"TR_MENU_SETTINGS_LANGUAGE_EN"
					],
					"default": 0,
					"signal": "menu_language_change"
				}
			]
		}
	]
}


## User config. Holds the actual config.
## The user config is derived from USER_CONFIG_MODEL and will be overwritten
## by the loading the user config file.
var user_config := {}


func parse_user_config_model(model: Dictionary) -> Dictionary:
	var config := {}
	
	# Add meta
	for entry in model.meta:
		var value = null
		
		if typeof(model.meta[entry]) == TYPE_STRING and get(model.meta[entry]):
			value = get(model.meta[entry])
		else:
			value = model.meta[entry]

		config.merge({
			entry: value
		})

	# Add configurables
	for category in model.configurable:
		var option_entry = {}
		for option in category.options:
			option_entry.merge({option.name: option.default})
		config.merge({category.name: option_entry})

	return config


func _ready():
	core_init(core_config)
	user_config = parse_user_config_model(USER_CONFIG_MODEL)
	
	# Load user config file
	user_config = core_load_user_config(user_config)

	# Video Setup
	
	
	_event_signal_setup()

func _event_signal_setup():
	pass






### Default boilerplate configuration file; this is overwritten if a boiler.cfg exists.
#var boilerplate_config: Dictionary = {
#	"game_version": 0.3,
#	"config_version": 0,
#	"debug": true,
#	"devlog_url": "https://raw.githubusercontent.com/NimbleBeasts/NbGodotBoilerplate/master/_Org/devlog/Boilerplate_"+ "%0.1f" % boilerplate_config.game_version +".txt",
#	"supported_resolutions": [
#		#Vector2(320, 180),
#		#Vector2(640, 360),
#		Vector2(1280, 720), #our default
#		Vector2(1366, 768), #7.47%
#		Vector2(1920, 1080), #67.60%
#		Vector2(2560, 1440), #8.23%
#		Vector2(3840, 2160) #2.41%
#	],
#	"levels": ["res://Src/Levels/Level0.tscn"]
#}
#
### Default user config file; this is overwritten if a config.cfg exists.
#var user_config: Dictionary = {
#	"configVersion": boilerplate_config.config_version,
#	"highscore": 0,
#	"soundVolume": 8,
#	"musicVolume": 8,
#	"fullscreen": false,
#	"brightness": 1.0,
#	"contrast": 1.0,
#	"resolution": {"w": 1280, "h": 720},
#	"language": "en"
#}
#
### Default game state for saving/loading; this will be overwritten with the users game state.
#var game_state: Dictionary = {
#	"header": {
#		"game_version": boilerplate_config.game_version,
#		"date": get_datetime_string_from_unixtime(get_local_unixtime()),
#		"level": 0
#	},
#	"data": {}
#}
#
## Save game states
#var save_game_headers: Array = []
#
### Initialized pseudo random number generater
#var rng: RandomNumberGenerator = RandomNumberGenerator.new()
#var _state_seed: int = int(3458764513820540928)
#
#
#func _ready() -> void:
#	print("Starting: " + str(ProjectSettings.get_setting("application/config/name")) + " v" + getVersionString())
#	print("Date: " + get_datetime_string_from_unixtime(get_local_unixtime()))
#	print("Debug: " + str(OS.is_debug_build()))
#	print("Boilerplate-Debug: "+ str(boilerplate_config.debug))
#
#	# Randomize the RNG
#	rng.randomize()
#	# Load user config
#	load_config()
#	# Setup video settings
#	video_setup()
#	# Load save game headers
#	get_save_games()
#
#
################################################################################
## User Configs
################################################################################
### Save user config
#func save_config() -> void:
#	var cfgFile = File.new()
#	cfgFile.open("user://config.cfg", File.WRITE)
#	cfgFile.store_line(JSON.new().stringify(user_config))
#	cfgFile.close()
#
#
### Load user config; migrate if outdated
#func load_config() -> void:
#	var cfgFile = File.new()
#	if not cfgFile.file_exists("user://config.cfg"):
#		# Config has not been created yet, create default one
#		save_config()
#		return
#
#	cfgFile.open("user://config.cfg", File.READ)
#	var test_json_conv = JSON.new()
#	test_json_conv.parse(cfgFile.get_line())
#	var data = test_json_conv.get_data()
#	cfgFile.close()
#
#	# Check if the user has an old config, migrate new settings
#	if data.configVersion < boilerplate_config.config_version:
#		user_config = _migrate_config(data)
#		save_config()
#
#	# Copy over userConfig
#	user_config = data.duplicate()
#
#
### Config Migration: Once rolled out, new config options needs to be migrated
### into the user config. This function is used to add the new config options
### to it. It is called by the load_config()
#func _migrate_config(data):
##	for i in range(data.configVersion, CONFIG_VERSION):
##		match data.configVersion:
##			0:
##				update config here
##				data.configVersion = 1
##			_:
##				print("error: migration variant not found")
#	return data
#
#
################################################################################
## Save Games
################################################################################
### Get save game state headers
#func get_save_games() -> void:
#	# Clear all states
#	save_game_headers = []
#
#	var dir = Directory.new()
#	if dir.open("usr://") == OK:
#		dir.list_dir_begin() # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
#		var file_name = dir.get_next()
#
#		while file_name != "":
#			if not dir.current_is_dir():
#				if file_name.get_extension() == "sav":
#					# Load header
#					var file = File.new()
#					file.open("usr://" + file_name, File.READ)
#					var test_json_conv = JSON.new()
#					test_json_conv.parse(file.get_as_text())
#					var data = test_json_conv.get_data()
#					save_game_headers.append({"file": file_name, "header": data.header})
#					file.close()
#			file_name = dir.get_next()
#		dir.list_dir_end()
#
#
### Save current game state into slot_id. slot_id = -1 will create a new save
### game file
#func save_game(slot_id = -1, _new_save_name = "") -> void:
#	var saveFile = File.new()
#	game_state.date = get_local_unixtime()
#	#TODO: hier
#	if slot_id == -1:
#		slot_id = save_game_headers.size()
#	saveFile.open("user://"+ str(slot_id) + ".sav", File.WRITE)
#	saveFile.store_line(JSON.new().stringify(game_state))
#	saveFile.close()
#	Events.emit_signal("hud_game_hint", tr("HUD_GAME_SAVED"))
#	Events.emit_signal("hud_save_window_exited")
#
#
### Load game state from given slot_id.
#func load_game(slotId) -> void:
#	var saveFile = File.new()
#	if not saveFile.file_exists("user://save_"+ str(slotId) + ".cfg"):
#		print("Save Game Not Found")
#
#	saveFile.open("user://save_"+ str(slotId) + ".cfg", File.READ)
#	var test_json_conv = JSON.new()
#	test_json_conv.parse(saveFile.get_line())
#	var data = test_json_conv.get_data()
#	game_state = data.duplicate()
#
#
################################################################################
## Video Setup
################################################################################
## Set Fullscreen Mode
#func setFullscreen(val: bool):
#	user_config.fullscreen = val
#	save_config()
#
#	video_setup()
#
#func setResolution(val: int):
#	user_config.resolution = {
#		"w": boilerplate_config.supported_resolutions[val].x,
#		"h": boilerplate_config.supported_resolutions[val].y
#	}
#	save_config()
#
#	switchResolution()
#
#
#
#func switchResolution():
##	OS.set_window_size(Vector2(user_config.resolution.w, user_config.resolution.h))
##	#Center the window
##	OS.center_window()
#	pass
#
## Perform Fullscreen Switch
#func video_setup():
#	if not user_config.fullscreen:
#		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
#	else:
#		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
#		switchResolution()
#
##	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
##else:
##	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
#
#
################################################################################
## Global Helper Functions
################################################################################
## PRNG
#func prng():
#	_state_seed = int((rng.randi() + 1) * _state_seed) + 1
#	return abs(_state_seed)
#
## PRNG by Chance in Percentage
#func prngByChance(chanceInPercent):
#	var value = prng() % 100
#	if value <= chanceInPercent:
#		return true
#	return false
#
## Get Version
#func getVersion():
#	return boilerplate_config.game_version
#
## Get Version String
#func getVersionString():
#	var versionString = "%2.1f" % (boilerplate_config.game_version)
#
#	if boilerplate_config.debug:
#		versionString += "-debug"
#
#	return versionString
### Get datetime string from given unixtime
#func get_datetime_string_from_unixtime(unixTime) -> String:
#	var dict = Time.get_datetime_dict_from_system_from_unix_time(unixTime)
#	return "%0*d" % [2, dict.day] + "/"  + "%0*d" % [2, dict.month] + "/" + str(dict.year) + " - " + "%0*d" % [2, dict.hour] + ":" + "%0*d" % [2, dict.minute]
#
### Get user local unixtime stamp
#func get_local_unixtime() -> int:
#	var date = Time.get_datetime_dict_from_system_from_unix_time(Time.get_unix_time_from_system())
#	var time = OS.get_time()
#	date.hour = time.hour
#	date.minute = time.minute
#	return Time.get_unix_time_from_system_from_datetime(date)
