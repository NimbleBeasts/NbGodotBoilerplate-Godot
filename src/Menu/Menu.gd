extends Control

enum MenuState {Main, Settings}

func _ready():
	Global.setMenu(self)
	$Version.bbcode_text = "[right]"+ Global.getVersionString() + "[/right]"
	stateTransition(MenuState.Main)

func updateGui():
	stateTransition(MenuState.Main)
	#if Global.gm.levelNode:
		#$Main/ButtonContinue.show()
	#else:
		#$Main/ButtonContinue.hide()

func _on_ButtonExit_button_up():
	if Global.getGameManager().state == Types.GameStates.Menu:
		print("Ok, Bye! Thanks for playing.")
		get_tree().quit()


func _on_ButtonSettings_button_up():
	if Global.getGameManager().state == Types.GameStates.Menu:
		stateTransition(MenuState.Settings)

func _on_ButtonPlay_button_up():
	if Global.getGameManager().state == Types.GameStates.Menu:
		Global.getGameManager().newGame()

func stateTransition(to):
	if to == MenuState.Main:
		$Settings.hide()
		$Main.show()
	elif to == MenuState.Settings:
		updateSettings()
		$Settings.show()
		$Main.hide()

func updateSettings():
	var lights = Global.getGameManager().getLights()
	
	if lights:
		$Settings/ButtonLights/Text.bbcode_text = "[center]Light: On[/center]"
	else:
		$Settings/ButtonLights/Text.bbcode_text = "[center]Light: Off[/center]"


func _on_ButtonBack_button_up():
	stateTransition(MenuState.Main)

func _on_ButtonLights_button_up():
	var lights = Global.getGameManager().getLights()
	Global.getGameManager().setLights(!lights)
	updateSettings()

func _on_ButtonFullscreen_button_up():
	Global.fullscreen()
	updateSettings()