extends "res://NbCore/Events.gd"

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

###########################################################################
# Config Changes
###########################################################################
## Emitted if sound volume is changed in menus
signal cfg_sound_set_volume(new)
## Emitted if music volume is changed in menus
signal cfg_music_set_volume(new)
## Emitted if fullscreen mode is changed in menus
signal cfg_switch_fullscreen(value)
## Emitted if the brightness is changed in menus
signal cfg_change_brightness(value)
## Emitted if the contrast is changed in menus
signal cfg_change_contrast(value)

