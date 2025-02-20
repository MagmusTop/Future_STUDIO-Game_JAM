extends Area2D

var answer : int = -1
var time : float = 0
var float_height : float = 20.0
var float_speed : float = 5.0
var is_falling: bool = false
var start_position = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_position = position
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta
	if is_falling:
		position.y += 300 * delta
	else:
		# Create smooth floating motion using sin wave
		position.y += sin(time * float_speed) * delta * float_height

func set_answer(new_answer: int) -> void:
	answer = new_answer

func fall_down():
	is_falling = true

func reset_position():
	position = start_position
	is_falling = false
	show()
