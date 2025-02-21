extends Area2D

@onready var hover_sound = $"../Area2D/HoverSound"
@onready var click_sound = $"../../ClickSound"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			click_sound.play()
			get_tree().quit()

func _on_mouse_entered() -> void:
	hover_sound.play()
	modulate = Color(1.2, 1.2, 1.2)

func _on_mouse_exited() -> void:
	modulate = Color(1, 1, 1)
