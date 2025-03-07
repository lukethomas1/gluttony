extends Area2D

signal grow(score:int)
signal game_over
signal num_bombs_changed(num_bombs:int)

const Mob = preload("res://scripts/mob.gd")
const Powerup = preload("res://scripts/powerup.gd")
const Floater = preload("res://scripts/floater.gd")

var score:float
var num_bombs:int = 0
var playing:bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()


func _on_body_entered(_body):
	var mob = _body as Mob
	if mob != null:
		handle_mob(mob)
		return

	var powerup = _body as Powerup
	if powerup != null:
		num_bombs += 1
		num_bombs_changed.emit(num_bombs)
		powerup.die()

	var floater = _body as Floater
	if floater != null:
		handle_floater(floater)
	

func do_bomb():
	num_bombs -= 1
	num_bombs_changed.emit(num_bombs)
	get_tree().call_group("mobs", "die")
	$BombSound.play()


func handle_floater(floater: Floater):
	score += Calc.calc_floater_growth_amount()
	scale_player_size()
	grow.emit(score)
	floater.die()


func handle_mob(mob: Mob):
	if score > mob.size:
		mob.die()
		grow_player(mob.size)

	elif score <= mob.size:
		do_game_over()


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
	position = get_viewport().get_visible_rect().size / 2 # middle of screen using pixel coordinates
	score = Calc.default_score
	scale_player_size()
	show()
	$CollisionShape2D.disabled = false
	playing = true
	num_bombs = 3
	num_bombs_changed.emit(num_bombs)


func do_game_over():
	playing = false
	hide()
	$CollisionShape2D.set_deferred(&"disabled", true)
	num_bombs = 0
	num_bombs_changed.emit(num_bombs)
	game_over.emit()
