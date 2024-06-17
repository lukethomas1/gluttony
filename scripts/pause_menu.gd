extends PanelContainer

signal resume_game()

@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")
@onready var EFFECTS_BUS_ID = AudioServer.get_bus_index("Effects")

const CONFIG_PATH:String = "user://settings.cfg"
const SOUND_SECTION:String = "SOUND_SETTINGS"
const MUSIC_VOLUME:String = "MUSIC_VOLUME"
const EFFECTS_VOLUME:String = "EFFECTS_VOLUME"

var config:ConfigFile


func _ready():
	config = ConfigFile.new()
	load_settings()


func load_settings():
	config = ConfigFile.new()
	var err = config.load(CONFIG_PATH)

	# If the file didn't load, ignore it
	if err != OK:
		return

	%MusicSlider.value = config.get_value(SOUND_SECTION, MUSIC_VOLUME)
	%EffectsSlider.value = config.get_value(SOUND_SECTION, EFFECTS_VOLUME)


func save_settings():
	config.set_value(SOUND_SECTION, MUSIC_VOLUME, %MusicSlider.value)
	config.set_value(SOUND_SECTION, EFFECTS_VOLUME, %EffectsSlider.value)
	config.save(CONFIG_PATH)


func _on_music_slider_value_changed(value:float):
	set_bus_volume(MUSIC_BUS_ID, value)


func _on_effects_slider_value_changed(value:float):
	set_bus_volume(EFFECTS_BUS_ID, value)


func set_bus_volume(bus_id:int, value:float):
	AudioServer.set_bus_volume_db(bus_id, linear_to_db(value))
	AudioServer.set_bus_mute(bus_id, value < .05)


func _on_resume_button_pressed():
	resume_game.emit()


func _on_quit_button_pressed():
	get_tree().quit()


func _on_hidden():
	save_settings()
