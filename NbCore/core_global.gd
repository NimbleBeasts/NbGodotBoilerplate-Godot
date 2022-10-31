extends Node

var rng: Core_RandomNumberGenerator
var seed_rng: Core_RandomNumberGenerator

var _core_cfg := {}

## Initialize core 
func core_init(config: Dictionary) -> void:
	_core_cfg = config
	_core_init_rng()
	
	
	if _core_cfg.video.has("enable_screenshots") and _core_cfg.video.enable_screenshots:
		Events.connect("take_screenshot", Callable(self, "_core_take_screenshot"))

func _core_take_screenshot():
	# Create dir if not exists
	var dir = DirAccess.open("user://")
	dir.make_dir("screenshot")
	
	# Get image from viewport
	var image = get_viewport().get_texture().get_image()
	var datetime = Time.get_datetime_string_from_system()
	# YYYY-MM-DDTHH:MM:SS
	# Replace ':'
	datetime[13] = "-"
	datetime[16] = "-"
	# Store image to file
	var file_name := "user://screenshot/screenshot_" + datetime + ".png"
	image.save_png(file_name)
	

## Load user config file. Create one if no cfg exists. Also does upgrade and sanity checks.
func core_load_user_config(schema: Dictionary) -> Dictionary:
	# User config does not exist - create one
	if not FileAccess.file_exists("user://config.cfg"):
		core_save_user_config(schema)
		return schema
		
	var file := FileAccess.open("user://config.cfg", FileAccess.READ)
	var read_data: Dictionary = JSON.new().parse_string(file.get_as_text())
	
	# Overwrite corrupt configs
	if not read_data.has("configVersion"):
		core_save_user_config(schema)
		return schema
	
	# Migration check - Upgrade config if needed
	if _core_cfg.user_config.auto_upgrade or _core_cfg.user_config.sanity_check:
		if read_data.configVersion < _core_cfg.user_config.version or _core_cfg.user_config.sanity_check:
			read_data = core_upgrade_user_config(read_data, schema)

	return read_data

## Save user config file
func core_save_user_config(data: Dictionary) -> void:
	var file := FileAccess.open("user://config.cfg", FileAccess.WRITE)
	file.store_string(JSON.new().stringify(data))

## Merge attributes from schema to data. Works also as sanity check when user corrupted the cfg.
func core_upgrade_user_config(data: Dictionary, schema: Dictionary) -> Dictionary:
	data.merge(schema)
	data.configVersion = schema.configVersion
	
	if _core_cfg.user_config.auto_upgrade:
		core_save_user_config(data)
	return data


func _core_init_rng() -> void:
	# Randomize our RNG
	rng = Core_RandomNumberGenerator.new()
	rng.randomize()
	
	# Seed stated RNG 
	seed_rng = Core_RandomNumberGenerator.new()
	if _core_cfg.has("rng_default_seed"):
		seed_rng.set_seed(_core_cfg.rng_default_seed) 
	else:
		seed_rng.set_seed(0)

func get_version_string(version: float) -> String:
	return "%0.1f" % version 
