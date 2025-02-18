extends Area2D

@onready var planet_name = $"../MathsName"
var maths = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if maths == 0:
		planet_name.set_text("")
	elif maths == 1:
		planet_name.set_text("Mathématiques")

func _on_mouse_entered() -> void:
	maths = 1
	modulate = Color(1.4, 1.4, 1.4)

func _on_mouse_exited() -> void:
	maths = 0
	modulate = Color(1, 1, 1)
