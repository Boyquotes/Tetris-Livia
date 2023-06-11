extends Node


var fullscreen
var audio_music
var audio_sfx
var config

const TILE_SIZE = 32


func _ready():
	_load_settings()


func _load_settings():

	config = ConfigFile.new()

	var err = config.load("user://settings.cfg")

	if err == OK:
		fullscreen = config.get_value('display', 'fullscreen', false)
		audio_music = config.get_value('audio', 'music', true)
		audio_sfx = config.get_value('audio', 'sfx', true)
	else:
		fullscreen = false
		audio_music = true
		audio_sfx = true

func _save_settings():

	config.set_value("display", "fullscreen", fullscreen)
	config.set_value("audio", "music", audio_music)
	config.set_value("audio", "sfx", audio_sfx)


	config.save("user://settings.cfg")
