extends Node

var mob_scene: PackedScene = preload("res://mob.tscn")
var mob_script = preload("res://mob.gd")

@onready var left_spawn = $LeftMobPath/LeftMobSpawnLocation
@onready var right_spawn = $RightMobPath/RightMobSpawnLocation

var screen_size:Vector2
var player_score

func _ready():
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    screen_size = get_viewport().get_visible_rect().size
    get_tree().get_root().size_changed.connect(handle_window_resize)


func handle_window_resize():
    screen_size = get_viewport().get_visible_rect().size
    print("Window resize, screen_size: %s" % str(screen_size))


func game_over():
    $MobTimer.stop()
    $HUD.show_game_over()
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_player_grow(score:int):
    player_score = score
    $HUD.update_score(player_score - 100)


func new_game():
    print("New game")
    get_tree().call_group(&"mobs", &"queue_free")
    player_score = 100
    $StartTimer.start()
    $HUD.update_score(player_score - 100)
    $HUD.show_message("Get Ready")
    $Player.start()
    Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _on_mob_timer_timeout():
    # Create a new instance of the Mob scene.
    var mob = mob_script.create_new_mob(player_score)
    $Player.grow.connect(mob.adjust_to_score)
    print("Mob size: %s" % str(mob.size))

    var mob_spawn_pos_x = [0, screen_size[0]][randi() % 2]
    var mob_spawn_pos_y = randf_range(0, screen_size[1])
    var direction = float(0) if mob_spawn_pos_x == 0 else PI

    mob.position = Vector2(mob_spawn_pos_x, mob_spawn_pos_y)

    # Choose a random location on Path2D.
    # var mob_spawn_paths = [left_spawn, right_spawn]
    # var mob_spawn_location = mob_spawn_paths[randi() % mob_spawn_paths.size()]
    # mob_spawn_location.progress_ratio = randf()

    # Set the mob's direction perpendicular to the path direction.
    # var direction = mob_spawn_location.rotation + PI / 2

    # Set the mob's position to a random location.
    # mob.position = mob_spawn_location.position

    # Add some randomness to the direction.
    # direction += randf_range(-PI / 4, PI / 4)
    # mob.rotation = direction

    # Choose the velocity for the mob.
    var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
    mob.linear_velocity = velocity.rotated(direction)

    # Spawn the mob by adding it to the Main scene.
    add_child(mob)


func _on_start_timer_timeout():
    $MobTimer.start()


