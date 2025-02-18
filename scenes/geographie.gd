extends Area2D

@onready var planet_name = $"../GeoName"
var geo = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if geo == 0:
		planet_name.set_text("")
	elif geo == 1:
		planet_name.set_text("Géographie")

func _on_mouse_entered() -> void:
	geo = 1
	modulate = Color(1.4, 1.4, 1.4)

func _on_mouse_exited() -> void:
	geo = 0
	modulate = Color(1, 1, 1)
