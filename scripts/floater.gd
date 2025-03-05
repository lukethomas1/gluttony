extends RigidBody2D


const icon_width_pixels: int = 128

const x_speed = 500
var y_speed = 100 # placeholder until _ready adjust the value for screen size

var screen_size:Vector2
var time = 0
var x_dir = 0


func _physics_process(delta):
	time += delta
	var y_velocity = y_speed * sin(time * -1)
	linear_velocity = Vector2(x_speed * x_dir, y_velocity)


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport().get_visible_rect().size
	var floater_scale = scale[0]
	var floater_width = floater_scale * icon_width_pixels

	# Random starting 'time' value
	time = randf_range(0, PI)

	var x_pos = [-1 * floater_width, screen_size[0] + floater_width][randi() % 2]
	var y_pos = screen_size[1] * (1 - cos(time)) / 2
	position = Vector2(x_pos, y_pos)
    
	x_dir = 1 if x_pos <= 0 else -1
	y_speed = screen_size[1] / 2 - 120


func _on_visible_on_screen_notifier_2d_screen_exited():
	die()


func die():
	queue_free()
