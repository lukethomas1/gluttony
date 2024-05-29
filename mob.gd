extends RigidBody2D


const mob_scene: PackedScene = preload("res://mob.tscn")

var size


static func create_new_mob(player_score):
    var new_mob = mob_scene.instantiate()
    var mob_size = int(player_score * randf_range(0.5, 1.5))
    new_mob.size = mob_size
    new_mob.adjust_to_score(player_score)
    new_mob.scale_mob_size()
    return new_mob


func scale_mob_size():
    var mob_scale = Calc.calc_scale(size)
    $CollisionShape2D.scale = mob_scale
    $AnimatedSprite2D.scale = mob_scale


func adjust_to_score(player_score):
    if size < player_score:
        modulate = Color(0, 1, 0)
    else:
        modulate = Color(1, 0, 0)


func _on_VisibilityNotifier2D_screen_exited():
    die()


func die():
    queue_free()
