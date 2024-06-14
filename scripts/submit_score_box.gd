extends CanvasLayer

signal submit_score


# Called when the node enters the scene tree for the first time.
func _ready():
	%SubmitButton.disabled = true


func _on_name_input_text_changed(new_text):
	if new_text.length() > 0:
		%SubmitButton.disabled = false
	else:
		%SubmitButton.disabled = true


func _on_submit_button_pressed():
	submit_score.emit()
