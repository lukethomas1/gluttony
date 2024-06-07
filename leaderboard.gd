extends CanvasLayer

signal refresh_requested

const score_entry_scene = preload("res://score_entry.tscn")


func remove_all():
	for i in range(%ScoresContainer.get_child_count()):
		%ScoresContainer.get_child(i).queue_free()


func add_score(player_name: String, score: int):
	var score_entry = score_entry_scene.instantiate()
	score_entry.get_node("NameLabel").text = player_name
	score_entry.get_node("ScoreLabel").text = str(score)
	%ScoresContainer.add_child(score_entry)


func _on_texture_button_pressed():
	refresh_requested.emit()
