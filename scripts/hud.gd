extends CanvasLayer

signal start_game
signal settings_button_pressed
signal resume_game

const bomb_texture = preload("res://assets/textures/bomb.png")


func show_message(text):
	$MessageLabel.text = text
	$MessageLabel.show()


func hide_message():
	$MessageLabel.hide()


func show_game_over():
	show_message("Game Over")


func show_main_menu():
	show_message("Eat or Be Eaten")
	$StartButton.show()
	$SettingsButton.show()


func update_score(score):
	$ScoreLabel.text = "%d" % score


func _on_start_button_pressed():
	$StartButton.hide()
	$SettingsButton.hide()
	$PauseMenu.hide()
	start_game.emit()


func _on_num_bombs_changed(num_bombs: int):
	var num_bombs_showing = $BombContainer.get_child_count()
	if num_bombs > num_bombs_showing:
		for i in range(num_bombs - num_bombs_showing):
			var texture_rect = TextureRect.new()
			texture_rect.texture = bomb_texture
			texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
			$BombContainer.add_child(texture_rect)
	elif num_bombs < num_bombs_showing:
		for i in range(num_bombs_showing - num_bombs):
			$BombContainer.get_child(i).queue_free()


func _on_settings_button_pressed():
	toggle_pause_menu()


func _on_pause_menu_resume_game():
	hide_pause_menu()
	resume_game.emit()


func show_pause_menu():
	$PauseMenu.visible = true


func hide_pause_menu():
	$PauseMenu.visible = false


func toggle_pause_menu():
	$PauseMenu.visible = !$PauseMenu.visible
