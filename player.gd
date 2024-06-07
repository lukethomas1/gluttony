extends Area2D

signal grow(score:int)
signal game_over

const Mob = preload("res://mob.gd")
const Powerup = preload("res://powerup.gd")

var score:float
var has_bomb:bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()


func _input(event):
	if event is InputEventMouseMotion:
		position = event.position
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed && has_bomb:
			do_bomb()


func _on_body_entered(_body):
	var mob = _body as Mob
	if mob != null:
		handle_mob(mob)

	var powerup = _body as Powerup
	if powerup != null:
		print("Player hit powerup")
		handle_powerup(powerup)


func handle_powerup(powerup: Powerup):
	print("Doing powerup things")
	has_bomb = true
	powerup.die()


func do_bomb():
	has_bomb = false
	get_tree().call_group("mobs", "die")
	$BombSound.play()


func handle_mob(mob: Mob):
	print("Player score: %s, Mob score %s" % [score, mob.size])
	if score > mob.size:
		mob.die()
		grow_player(mob.size)

	elif score <= mob.size:
		hide()
		$CollisionShape2D.set_deferred(&"disabled", true)
		game_over.emit()


func grow_player(mob_size):
	var growth_amount = Calc.calc_growth_amount(score, mob_size)
	score += growth_amount
	scale_player_size()
	grow.emit(score)


func scale_player_size():
	var new_scale = Calc.calc_scale(score)
	$CollisionShape2D.scale = new_scale
	$Body.scale = new_scale
	$Eyes.scale = new_scale


func start():
	print("Player start")
	score = Calc.default_score
	scale_player_size()
	show()
	has_bomb = false
	$CollisionShape2D.disabled = false
