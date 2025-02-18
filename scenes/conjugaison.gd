extends Area2D

@onready var planet_name = $"../ConjName"
var conj = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if conj == 0:
		planet_name.set_text("")
	elif conj == 1:
		planet_name.set_text("Conjugaison")

func _on_mouse_entered() -> void:
	conj = 1
	modulate = Color(1.4, 1.4, 1.4)

func _on_mouse_exited() -> void:
	conj = 0
	modulate = Color(1, 1, 1)
