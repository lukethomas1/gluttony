extends Control

signal resume_game()

@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")
@onready var EFFECTS_BUS_ID = AudioServer.get_bus_index("Effects")


func _on_music_slider_value_changed(value:float):
	AudioServer.set_bus_volume_db(MUSIC_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(MUSIC_BUS_ID, value < .05)


func _on_effects_slider_value_changed(value):
	AudioServer.set_bus_volume_db(EFFECTS_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(EFFECTS_BUS_ID, value < .05)


func _on_resume_button_pressed():
	resume_game.emit()