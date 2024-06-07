extends CanvasLayer

signal start_game

const bomb_texture = preload("res://assets/textures/bomb.png")


func show_message(text):
	$MessageLabel.text = text
	$MessageLabel.show()
	$MessageTimer.start()


func show_game_over():
	show_message("Game Over")
	await $MessageTimer.timeout
	$MessageLabel.text = "Eat or Be Eaten"
	$MessageLabel.show()
	$StartButton.show()


func update_score(score):
	$ScoreLabel.text = "%d" % score


func _on_start_button_pressed():
	$StartButton.hide()
	start_game.emit()


func _on_message_timer_timeout():
	$MessageLabel.hide()


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
