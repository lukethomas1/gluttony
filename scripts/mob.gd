extends RigidBody2D


const mob_scene: PackedScene = preload("res://scenes/mob.tscn")

const mob_text_red_body = preload("res://assets/textures/red_body_square.png")
const mob_text_red_eye = preload("res://assets/textures/face_f.png")

const mob_text_green_body = preload("res://assets/textures/green_body_square.png")
const mob_text_green_eye = preload("res://assets/textures/face_i.png")

var size
var red = true


static func create_new_mob(player_score):
	var new_mob = mob_scene.instantiate()
	var mob_size = int(player_score * randf_range(0.5, 1.5))
	new_mob.size = mob_size
	new_mob.z_index = 1
	new_mob.adjust_to_score(player_score)
	new_mob.scale_mob_size()
	return new_mob


func scale_mob_size():
	var mob_scale = Calc.calc_scale(size)
	$CollisionShape2D.scale = mob_scale
	$Body.scale = mob_scale
	$Eyes.scale = mob_scale


func adjust_to_score(player_score):
	if red && size < player_score:
		z_index = 0
		$Body.texture = mob_text_green_body
		$Eyes.texture = mob_text_green_eye
		red = false


func _on_visible_on_screen_notifier_2d_screen_exited():
	die()


func die():
	queue_free()
