extends Area2D

signal grow(score:int)
signal game_over

const Mob = preload("res://mob.gd")

var score:float


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()


func _input(event):
	if event is InputEventMouseMotion:
		position = event.position


func _on_body_entered(_body):
	var mob = _body as Mob

	if mob != null:
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
	score += int(growth_amount)
	scale_player_size()
	grow.emit(score)


func scale_player_size():
	var new_scale = Calc.calc_scale(score)
	$CollisionShape2D.scale = new_scale
	$AnimatedSprite2D.scale = new_scale


func start():
	print("Player start")
	score = Calc.default_score
	scale_player_size()
	show()
	$CollisionShape2D.disabled = false
