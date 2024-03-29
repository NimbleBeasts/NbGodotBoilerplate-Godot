extends Control

enum MenuState {Main, Settings}

func _ready():
	# Event Hooks
	Events.connect("menu_back",Callable(self,"_back"))
	Events.connect("cfg_switch_fullscreen",Callable(self,"_switchFullscreen"))

	$Version.text = "[right]"+ Global.get_version_string(Global.GAME_VERSION) + "[/right]"

	switchTo(MenuState.Main)


	#Populate Resolution List
	for res in Global.core_config.video.supported_resolutions:
		$Settings/TabContainer/Graphics/ResolutionList.add_item(" " + str(res.x) + "x" + str(res.y))

		var resolution = Vector2(Global.user_config.resolution.w, Global.user_config.resolution.h)
		if resolution == res:
			var id = $Settings/TabContainer/Graphics/ResolutionList.get_item_count() - 1
			$Settings/TabContainer/Graphics/ResolutionList.select(id, true)
# Menu State Transition
func switchTo(to):
	hideAllMenuScenes()

	match to:
		MenuState.Main:
			$Main.show()
		MenuState.Settings:
			updateSettings()
			$Settings.show()
		_:
			print("Invalid menu state")

# Helper function for State Transition
func hideAllMenuScenes():
	# Add menu scenes here
	$Main.hide()
	$Settings.hide()

# Helper function to update the config labels
func updateSettings():
	$Settings/TabContainer/Sounds/SoundSlider.value = Global.user_config.soundVolume
	$Settings/TabContainer/Sounds/SoundSlider/Value.set_text(str(Global.user_config.soundVolume*10) + "%")

	$Settings/TabContainer/Sounds/MusicSlider.value = Global.user_config.musicVolume
	$Settings/TabContainer/Sounds/MusicSlider/Value.set_text(str(Global.user_config.musicVolume*10) + "%")

	$Settings/TabContainer/General/BrightnessSlider.value = Global.user_config.brightness
	$Settings/TabContainer/General/BrightnessSlider/Value.set_text("%.2f" % Global.user_config.brightness)

	$Settings/TabContainer/General/ContrastSlider.value = Global.user_config.contrast
	$Settings/TabContainer/General/ContrastSlider/Value.set_text("%.2f" % Global.user_config.brightness)


	if Global.user_config.fullscreen:
		$Settings/TabContainer/Graphics/FullscreenButton.text = "On"
	else:
		$Settings/TabContainer/Graphics/FullscreenButton.text = "Off"

###############################################################################
# Callbacks
###############################################################################

# Event Hook
func _switchSound(_val):
	updateSettings()

# Event Hook
func _switchMusic(_val):
	updateSettings()

# Event Hook
func _switchFullscreen(_val):
	updateSettings()

# Event Hook
func _back():
	switchTo(MenuState.Main)


func _on_ButtonPlay_button_up():
	Events.emit_signal("new_game")


func _on_ButtonSettings_button_up():
	switchTo(MenuState.Settings)


func _on_ButtonExit_button_up():
	print("Ok, Bye! Thanks for playing.")
	get_tree().quit()


func _on_BackButton_button_up():
	switchTo(MenuState.Main)

func _on_ButtonSound_button_up():
	Events.emit_signal("switch_sound", !Global.user_config.sound)


func _on_ButtonMusic_button_up():
	Events.emit_signal("switch_music", !Global.user_config.music)


func _on_FullscreenButton_button_up():
	if not Global.user_config.fullscreen:
		$Settings/TabContainer/Graphics/FullscreenButton.text = "On"
	else:
		$Settings/TabContainer/Graphics/FullscreenButton.text = "Off"

	Events.emit_signal("cfg_switch_fullscreen", !Global.user_config.fullscreen)


func _on_ApplyButton_button_up():
	var id = $Settings/TabContainer/Graphics/ResolutionList.get_selected_items()[0]
	Global.setResolution(id)

func _on_SoundSlider_value_changed(value):
	$Settings/TabContainer/Sounds/SoundSlider/Value.set_text(str(value*10) + "%")
	Events.emit_signal("cfg_sound_set_volume", value)


func _on_MusicSlider_value_changed(value):
	$Settings/TabContainer/Sounds/MusicSlider/Value.set_text(str(value*10) + "%")
	Events.emit_signal("cfg_music_set_volume", value)


func _on_BrightnessSlider_value_changed(value):
	$Settings/TabContainer/General/BrightnessSlider/Value.set_text("%.2f" % value)
	Events.emit_signal("cfg_change_brightness", value)


func _on_ContrastSlider_value_changed(value):
	$Settings/TabContainer/General/ContrastSlider/Value.set_text("%.2f" % value)
	Events.emit_signal("cfg_change_contrast", value)


