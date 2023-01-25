/datum/cinematic/solo_escape
	cleanup_time = 35 SECONDS /// An extra 5 seconds to display all our epilog text.

/datum/cinematic/solo_escape/play_cinematic()
	screen.icon = 'icons/effects/escape_cinematic.dmi'
	screen.icon_state = null

	flick("solo_escape", screen)
	play_cinematic_sound(sound('sound/machines/terminal_on.ogg'))
	stoplag(3.5 SECONDS)
	play_cinematic_sound(sound('sound/machines/terminal_success.ogg'))
	stoplag(2.5 SECONDS)
	play_cinematic_sound(sound('sound/machines/terminal_button04.ogg'))
	stoplag(0.6 SECONDS)
	play_cinematic_sound(sound('sound/machines/terminal_button03.ogg'))
	stoplag(0.8 SECONDS)
	play_cinematic_sound(sound('sound/machines/terminal_button05.ogg'))
	stoplag(0.7 SECONDS)
	play_cinematic_sound(sound('sound/machines/terminal_button03.ogg'))
	stoplag(4 SECONDS)
	play_cinematic_sound(sound('sound/runtime/hyperspace/hyperspace_begin.ogg'))
	stoplag(8 SECONDS)
	play_cinematic_sound(sound('sound/runtime/hyperspace/hyperspace_progress.ogg'))
	stoplag(6 SECONDS)
	play_cinematic_sound(sound('sound/machines/terminal_off.ogg'))
	stoplag(2 SECONDS)

/datum/cinematic/pirate_kidnapped

/datum/cinematic/pirate_kidnapped/play_cinematic()
	screen.icon = 'icons/effects/escape_cinematic.dmi'
	screen.icon_state ="snatched"
	play_cinematic_sound(sound('sound/voice/sinister_laugh.ogg'))
	stoplag(15 SECONDS)
	stop_cinematic()

