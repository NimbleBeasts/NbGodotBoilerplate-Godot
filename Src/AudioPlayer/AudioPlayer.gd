extends Node2D

##
## Handle Audio checked a global scale.
##
## @desc:
##		This file is used to utilize all none local sounds. Especially music
##		and menu sounds.
##


## Music tracks array
const tracks: Array = []
## Index of currently played track
var music_id_playing: int = 0

# Helper nodes
@onready var Node_Music: AudioStreamPlayer = $Music
@onready var Node_Music_Bus = AudioServer.get_bus_index("Music")
@onready var Node_Sound_Bus = AudioServer.get_bus_index("Sound")


func _ready():

	# Initial Set Volumes
	setMusicVolume(Global.user_config.audio.music)
	setSoundVolume(Global.user_config.audio.sound)

	# Event Hooks
	Events.connect("play_sound",Callable(self,"_playSound"))
	Events.connect("play_music",Callable(self,"_on_play_music"))
	Events.connect("change_music",Callable(self,"_change_music"))
	Events.connect("cfg_music_set_volume",Callable(self,"setMusicVolume"))
	Events.connect("cfg_sound_set_volume",Callable(self,"setSoundVolume"))


###############################################################################
# Callbacks
###############################################################################

func setMusicVolume(value):
	if value == 0:
		$Music.stop()
	else:
		if not $Music.is_playing(): $Music.play()

	AudioServer.set_bus_volume_db(Node_Music_Bus, linear_to_db(float(value)/10))

func setSoundVolume(value):
	AudioServer.set_bus_volume_db(Node_Sound_Bus, linear_to_db(float(value)/10))


# Event Hook: Play a sound
func _playSound(sound: String, _volume : float = 1.0, _pos : Vector2 = Vector2(0, 0)):
	if Global.user_config.soundVolume > 0:
		match sound:
			"menu_click":
				$MenuClick.play()
			"example":
				$Example2D.volume_db = -20 + 12 * _volume
				$Example2D.position = _pos
				$Example2D.play()
			_:
				print("error: sound not found - name: " + str(sound))

func _change_music(music_id):
	if music_id_playing != music_id:
		music_id_playing = music_id
		Node_Music.stop()
		Node_Music.stream = tracks[music_id]
		Node_Music.play()

func _on_play_music(music_id) -> void:
	_change_music(music_id)

