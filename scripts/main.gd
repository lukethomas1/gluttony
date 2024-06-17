extends Node

const mob_script = preload("res://scripts/mob.gd")

const powerup_scene = preload("res://scenes/powerup.tscn")

var screen_size:Vector2
var player_score:float
var pause_mouse_pos:Vector2

var login_failures = 0

const COLLECTION_ID = "LeaderboardV2"


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	screen_size = get_viewport().get_visible_rect().size
	get_tree().get_root().size_changed.connect(handle_window_resize)

	Firebase.Auth.auth_request.connect(_on_auth_request)
	Firebase.Auth.login_anonymous()


func handle_window_resize():
	screen_size = get_viewport().get_visible_rect().size
	print("Window resize, screen_size: %s" % str(screen_size))


func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			%StateChart.send_event("toggle_pause")
			%StateChart.send_event("toggle_menupause")
		elif event.keycode == KEY_SPACE:
			%StateChart.send_event("toggle_pause")
			%StateChart.send_event("toggle_menupause")


func _on_auth_request(result_code, result_content):
	print("Auth request")
	if result_code == 1:
		print("Auth request succeeded")
		$Leaderboard.load_leaderboard()
	else:
		print("Login failed, code %s, message: %s" % [str(result_code), str(result_content)])
		login_failures += 1
		if login_failures < 3:
			Firebase.Auth.login_anonymous()


func new_game():
	%StateChart.send_event("start")


func game_over():
	%StateChart.send_event("game_over")


func _on_submit_score():
	var player_name = $SubmitScoreBox.get_player_name()
	var score = int(player_score - Calc.default_score)
	var result = await $Leaderboard.submit_score(player_name, score)

	if result != null:
		print("Submit succeeded")
		$SubmitScoreBox.hide()
		$Leaderboard.load_leaderboard()


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


func create_bomb():
	var powerup_spawn_pos_x = randf_range(200, screen_size[0] - 200)
	var powerup_spawn_pos_y = randf_range(100, screen_size[1] - 100)

	var powerup = powerup_scene.instantiate()
	powerup.position = Vector2(powerup_spawn_pos_x, powerup_spawn_pos_y)

	call_deferred("add_child", powerup)


func _on_hud_resume_game():
	%StateChart.send_event("toggle_pause")
	%StateChart.send_event("toggle_menupause")


func _on_get_ready_state_entered():
	get_tree().call_group(&"mobs", &"queue_free")
	player_score = Calc.default_score
	$HUD.update_score(player_score - Calc.default_score)
	$HUD.show_message("Get Ready")
	$Player.start()
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	$Music.play()

	$Leaderboard.hide()
	$SubmitScoreBox.hide()
	$Instructions.hide()


func _on_get_ready_state_exited():
	Input.warp_mouse(DisplayServer.screen_get_size() / 2) # middle of screen using monitor resolution


func _on_playing_state_entered():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	get_tree().paused = false
	$HUD.hide_message()
	$MobTimer.wait_time = Calc.mob_spawn_timer_ms
	$MobTimer.start()


func _on_game_over_state_entered():
	$MobTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()


func _on_game_over_state_exited():
	$SubmitScoreBox.set_score_label(str(int(player_score - Calc.default_score)))
	$SubmitScoreBox.show()


func _on_main_menu_state_entered():
	get_tree().call_group("mobs", "die")
	get_tree().call_group("powerups", "die")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$Leaderboard.show()
	$Instructions.show()
	$HUD.show_main_menu()


func _on_paused_state_entered():
	# Need to subtract window position to support multiple monitor setups
	# because Input.warp_mouse(Vector2i) uses game-window coordinates
	pause_mouse_pos = DisplayServer.mouse_get_position() - DisplayServer.window_get_position()
	$HUD.show_pause_menu()
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_unpausing_state_entered():
	$HUD.hide_pause_menu()
	$HUD.show_message("Unpausing")
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)


func _on_playing_state_input(event):
	if event is InputEventMouseMotion:
		$Player.position = event.position
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed && $Player.num_bombs > 0:
			$Player.do_bomb()


func _on_unpausing_state_processing(_delta):
	Input.warp_mouse(pause_mouse_pos)


func _on_menu_pause_state_entered():
	$HUD.show_menupause_menu()
