extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	modulate = Color(0, 0, 1)


func die():
	queue_free()


func _on_despawn_timer_timeout():
	die()
