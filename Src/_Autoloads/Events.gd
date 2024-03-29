extends "res://NbCore/core_events.gd"

#warning-ignore-all:unused_signal

###############################################################################
# Global Signal List
###############################################################################

# Level Management
signal new_game()

# Sound
signal play_sound(sound)
# Music
signal play_music(track)
signal change_music(track_id)
# Menu Related
signal menu_popup()
signal menu_back()


signal take_screenshot()

###########################################################################
# User Config Changes
###########################################################################

signal menu_control_key_assign_entered()
signal menu_control_key_assign_finished()

## Emitted if sound volume has changed in menus
signal menu_sound_changed(new)
## Emitted if music volume has changed in menus
signal menu_music_changed(new)
## Emitted if resolution has changed in menus
signal menu_resolution_changed(value)
## Emitted if fullscreen mode has changed in menus
signal menu_fullscreen_changed(value)
## Emitted if vsync mode has changed in menus
signal menu_vsync_changed(value)
## Emitted if the brightness has changed in menus
signal menu_brightness_change(value)
## Emitted if the language has changed in menus
signal menu_language_change(value)

