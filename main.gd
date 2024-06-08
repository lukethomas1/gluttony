extends Node

const mob_script = preload("res://mob.gd")

const powerup_scene = preload("res://powerup.tscn")

var screen_size:Vector2
var player_score:float

var login_failures = 0

const COLLECTION_ID = "LeaderboardV1"


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	screen_size = get_viewport().get_visible_rect().size
	get_tree().get_root().size_changed.connect(handle_window_resize)
	$SubmitScoreBox.hide()

	Firebase.Auth.auth_request.connect(_on_auth_request)
	Firebase.Auth.login_anonymous()


func handle_window_resize():
	screen_size = get_viewport().get_visible_rect().size
	print("Window resize, screen_size: %s" % str(screen_size))


func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()


func _on_auth_request(result_code, result_content):
	print("Auth request")
	if result_code == 1:
		print("Auth request succeeded")
		load_leaderboard()
	else:
		print("Login failed, code %s, message: %s" % [str(result_code), str(result_content)])
		login_failures += 1
		if login_failures < 3:
			Firebase.Auth.login_anonymous()


func new_game():
	get_tree().call_group(&"mobs", &"queue_free")
	player_score = Calc.default_score
	$StartTimer.start()
	$HUD.update_score(player_score - Calc.default_score)
	$HUD.show_message("Get Ready")
	$Player.start()
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	$Music.play()

	$Leaderboard.hide()
	$SubmitScoreBox.hide()
	$Instructions.hide()


func game_over():
	$MobTimer.stop()
	$HUD.show_game_over()
	get_tree().call_group("mobs", "die")
	get_tree().call_group("powerups", "die")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$Music.stop()
	$DeathSound.play()

	load_leaderboard()
	$Leaderboard.show()
	get_node("SubmitScoreBox/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/ScoreLabel").text = str(int(player_score - Calc.default_score))
	$SubmitScoreBox.show()
	$Instructions.show()


func _on_submit_score():
	var auth = Firebase.Auth.auth
	if !auth.is_empty():
		var player_name = (get_node("SubmitScoreBox/PanelContainer/MarginContainer/VBoxContainer/NameInput") as LineEdit).text
		print("Submitting with player name %s" % player_name)
		var datetime = Time.get_datetime_string_from_system(true, false)
		var collection: FirestoreCollection = Firebase.Firestore.collection(COLLECTION_ID)

		var data = {
			"name": player_name,
			"score": int(player_score - Calc.default_score),
			"datetime": datetime,
		}
		var doc_name = "%s_%s_%s" % [data["name"].replace(" ", "-"), str(data["score"]), data["datetime"]]
		var add_task: FirestoreTask = collection.add(doc_name, data)
		var result = await add_task.add_document
		if result != null:
			print("Submit succeeded")
			$SubmitScoreBox.hide()
			load_leaderboard()


func load_leaderboard():
	print("Loading leaderboard")
	var auth = Firebase.Auth.auth
	if !auth.is_empty():
		var query : FirestoreQuery = FirestoreQuery.new().from(COLLECTION_ID).order_by("score", FirestoreQuery.DIRECTION.DESCENDING).limit(24)
		var query_task : FirestoreTask = Firebase.Firestore.query(query)
		var result : Array = await query_task.result_query

		$Leaderboard.remove_all()

		for item in result:
			$Leaderboard.add_score(item.doc_fields["name"], item.doc_fields["score"])
	else:
		print("No auth")


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
	var powerup_spawn_pos_x = randf_range(200, screen_size[0] - 200)
	var powerup_spawn_pos_y = randf_range(100, screen_size[1] - 100)

	var powerup = powerup_scene.instantiate()
	powerup.position = Vector2(powerup_spawn_pos_x, powerup_spawn_pos_y)

	add_child(powerup)