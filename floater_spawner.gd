extends Timer


const floater_scene = preload("res://scenes/floater.tscn")


func _on_timeout() -> void:
	var floater = floater_scene.instantiate()
	call_deferred("add_child", floater)