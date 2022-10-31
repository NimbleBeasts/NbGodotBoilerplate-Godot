extends Node


## Trace level types
enum TraceLevelFlags {
	TRACE_NONE = 0, ## No trace
	TRACE_ERROR = 1, ## Trace errors
	TRACE_WARNING = 2, ## Trace warnings
	TRACE_INFO = 4, ## Trace info
	TRACE_DEBUG = 8, ## Trace debug
}


var _config = {
	"file_trace_level_flags" = TraceLevelFlags.TRACE_NONE,
	"stdout_trace_level_flags" = TraceLevelFlags.TRACE_NONE,
	"console_trace_level_flags" = TraceLevelFlags.TRACE_NONE,
	"remote_trace_level_flags" = TraceLevelFlags.TRACE_NONE,
	"file_name" = "log.txt",
	"file_path" = "user://",
	"time_stamp" = true,
	"rich_text" = true,
}


## Log error message
func error(message: String):
	_write(TraceLevelFlags.TRACE_ERROR, message)


## Log warning message
func warn(message: String):
	_write(TraceLevelFlags.TRACE_WARNING, message)


## Log info message
func info(message: String):
	_write(TraceLevelFlags.TRACE_INFO, message)


## Log debug message
func debug(message: String):
	_write(TraceLevelFlags.TRACE_DEBUG, message)


## Setup logger
func setup(core_config_logger: Dictionary):
	# Check minimum config variables
	if not core_config_logger.has("logger"):
		return


	# Check file config
	if core_config_logger.logger.has("file"):
		if core_config_logger.logger.file.has("trace_level_flags"):
			_config.file_trace_level_flags = core_config_logger.logger.file.trace_level_flags
		if core_config_logger.logger.file.has("file_name"):
			_config.file_name = core_config_logger.logger.file.file_name
		if core_config_logger.logger.file.has("file_path"):
			_config.file_path = core_config_logger.logger.file.file_path
		if core_config_logger.logger.file.has("time_stamp"):
			_config.time_stamp = core_config_logger.logger.file.time_stamp

	# Check stdout config
	if core_config_logger.logger.has("stdout"):
		if core_config_logger.logger.stdout.has("trace_level_flags"):
			_config.stdout_trace_level_flags = core_config_logger.logger.stdout.trace_level_flags
		if core_config_logger.logger.stdout.has("rich_text"):
			_config.rich_text = core_config_logger.logger.stdout.rich_text

	# Check console config
	if core_config_logger.logger.has("console"):
		if core_config_logger.logger.console.has("trace_level_flags"):
			_config.console_trace_level_flags = core_config_logger.logger.console.trace_level_flags

	# Check remote config
	if core_config_logger.logger.has("remote"):
		if core_config_logger.logger.remote.has("trace_level_flags"):
			_config.remote_trace_level_flags = core_config_logger.logger.remote.trace_level_flags
	return

func _write(flag: TraceLevelFlags, message: String):
	var flag_name := ""
	var color := ""

	match flag:
		TraceLevelFlags.TRACE_ERROR:
			flag_name = "ERROR"
			color = "#b13e53"
		TraceLevelFlags.TRACE_WARNING:
			flag_name = "WARNING"
			color = "#ef7d57"
		TraceLevelFlags.TRACE_INFO:
			flag_name = "INFO"
			color = "#a7f070"
		TraceLevelFlags.TRACE_DEBUG:
			flag_name = "DEBUG"
			color = "#41a6f6"
		_:
			flag_name = "UNKNOWN"
			color = "#257179"

	if _config.file_trace_level_flags & flag:
		var file := FileAccess.open(_config.file_path + "/" + _config.file_name, FileAccess.READ_WRITE)
		file.seek_end()
		var string := ""
		if _config.time_stamp:
			string = Time.get_datetime_string_from_system() + " " + flag_name + ": " + message
		else:
			string = flag_name + ": " + message
		file.store_line(string)
		
	if _config.stdout_trace_level_flags & flag:
		var string := ""
		string = flag_name + ": " + message
		
		if flag == Logger.TraceLevelFlags.TRACE_DEBUG:
			print_debug(string)
		elif _config.rich_text:
			print_rich("[color=" + color + "]" + flag_name + "[/color]: " + message)
		else:
			print(string)

				
	if _config.console_trace_level_flags & flag:
		pass
	if _config.remote_trace_level_flags & flag:
		pass

