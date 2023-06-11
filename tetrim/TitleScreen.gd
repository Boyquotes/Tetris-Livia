extends Control

func _ready():
	
	OS.window_fullscreen = StoreSettings.fullscreen

	$FadeBackground.visible = true
	$FadeBackground/AnimationPlayer.play("FadeIn")


func _on_Jogar_pressed():
	$FadeBackground.visible = true
	$FadeBackground/AnimationPlayer.play("FadeOut")


func _on_AnimationPlayer_animation_finished(anim_name):

	if anim_name == 'FadeOut':
		get_tree().change_scene("res://Game.tscn")
	else:
		$FadeBackground.visible = false


func _on_Sair_pressed():
	get_tree().quit()


func _on_Historia_pressed():
	pass
	#get_tree().change_scene("")


func _on_Controles_pressed():
	pass
	#get_tree().change_scene("")
