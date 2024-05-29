extends Area2D

signal grow(score:int)
signal game_over

const Mob = preload("res://mob.gd")

const default_score = 100
var score: int

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
            var grow_ratio = mob.size / 10
            score += int(grow_ratio)
            print("Player grow to %s" % score)
            grow.emit(score)

        elif score <= mob.size:
            print("Player die")
            hide()
            $CollisionShape2D.set_deferred(&"disabled", true)
            game_over.emit()


func start():
    print("Player start")
    score = 100
    show()
    $CollisionShape2D.disabled = false


func scale_player():
    var new_scale = float(score) / float(default_score)
    scale = Vector2(new_scale, new_scale)