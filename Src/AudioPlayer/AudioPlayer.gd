extends Node2D

onready var musicPlayer: AudioStreamPlayer = $Music
onready var music_bus = AudioServer.get_bus_index("Music")
onready var sounds_bus = AudioServer.get_bus_index("Sound")
func _ready():
	# Initial Set Volumes
	setMusicVolume(Global.userConfig.musicVolume)
	setSoundVolume(Global.userConfig.soundVolume)
	# Event Hooks
	Events.connect_signal("play_sound", self, "_playSound")
	Events.connect("play_music", self, "onPlayMusic")
	
	Events.connect("cfg_music_set_volume", self, "setMusicVolume")
	Events.connect("cfg_sound_set_volume", self, "setSoundVolume")


###############################################################################
# Callbacks
###############################################################################

func setMusicVolume(value):
	if value == 0:
		$Music.stop()
	else:
		$Music.play()
	AudioServer.set_bus_volume_db(music_bus, linear2db(float(value)/10))

func setSoundVolume(value):
	AudioServer.set_bus_volume_db(sounds_bus, linear2db(float(value)/10))
	

# Event Hook: Play a sound
func _playSound(sound: String, _volume : float = 1.0, _pos : Vector2 = Vector2(0, 0)):
	if Global.userConfig.soundVolume > 0:
		match sound:
			"menu_click":
				$MenuClick.play()
			"example":
				$Example2D.volume_db = -20 + 12 * _volume
				$Example2D.position = _pos
				$Example2D.play()
			_:
				print("error: sound not found - name: " + str(sound))

# Music Loop?
func onPlayMusic(music_id) -> void:

	pass # Replace with function body.
