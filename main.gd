extends Node

const mob_script = preload("res://mob.gd")

const powerup_scene = preload("res://powerup.tscn")

var screen_size:Vector2
var player_score:float


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	screen_size = get_viewport().get_visible_rect().size
	get_tree().get_root().size_changed.connect(handle_window_resize)


func handle_window_resize():
	screen_size = get_viewport().get_visible_rect().size
	print("Window resize, screen_size: %s" % str(screen_size))


func new_game():
	get_tree().call_group(&"mobs", &"queue_free")
	player_score = Calc.default_score
	$StartTimer.start()
	$HUD.update_score(player_score - Calc.default_score)
	$HUD.show_message("Get Ready")
	$Player.start()
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	$Music.play()


func game_over():
	$MobTimer.stop()
	$HUD.show_game_over()
	get_tree().call_group("mobs", "die")
	get_tree().call_group("powerups", "die")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$Music.stop()
	$DeathSound.play()


func _on_player_grow(score:int):
	player_score = score
	if int(player_score - Calc.default_score) % Calc.bomb_spawn_frequency == 0:
		create_bomb()
	$HUD.update_score(player_score - Calc.default_score)
	$EatSound.play()


func _on_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_script.create_new_mob(player_score)
	$Player.grow.connect(mob.adjust_to_score)

	var mob_x_scale = mob.get_node("CollisionShape2D").scale[0]
	var mob_x_width = Calc.icon_width_pixels * mob_x_scale

	var mob_spawn_pos_x = [-1 * mob_x_width, screen_size[0] + mob_x_width][randi() % 2]
	var mob_spawn_pos_y = randf_range(0, screen_size[1])
	var direction = float(0) if mob_spawn_pos_x <= 0 else PI

	mob.position = Vector2(mob_spawn_pos_x, mob_spawn_pos_y)

	# Choose the velocity for the mob, get faster as score goes up
	var velocity = Calc.calc_mob_velocity(player_score)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)


func _on_start_timer_timeout():
	$MobTimer.start()


func create_bomb():
	var powerup_spawn_pos_x = randf_range(0, screen_size[0])
	var powerup_spawn_pos_y = randf_range(0, screen_size[1])

	var powerup = powerup_scene.instantiate()
	powerup.position = Vector2(powerup_spawn_pos_x, powerup_spawn_pos_y)

	add_child(powerup)
