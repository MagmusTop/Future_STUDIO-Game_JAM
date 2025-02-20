extends Area2D

@onready var planet_name = $"../SciencesName"
@onready var hover_sound = $"../HoverSound"
@onready var click_sound = $"../ClickSound"
var sci = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if sci == 0:
		planet_name.set_text("")
	elif sci == 1:
		planet_name.set_text("Sciences Physique et Technologies")
		
func _on_mouse_entered() -> void:
	hover_sound.play()
	sci = 1
	modulate = Color(1.4, 1.4, 1.4)

func _on_mouse_exited() -> void:
	sci = 0
	modulate = Color(1, 1, 1)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			click_sound.play()
			var game_scene = load("res://scenes/science_quiz.tscn")
			get_tree().change_scene_to_file("res://scenes/science_quiz.tscn")
