extends CharacterBody2D

const SPEED = 100.0

func _physics_process(delta: float) -> void:
	var horizontal_direction := Input.get_axis("ui_left", "ui_right")
	var vertical_direction := Input.get_axis("ui_up", "ui_down")

	velocity = Vector2.ZERO

	if horizontal_direction:
		velocity.x = horizontal_direction * SPEED
	elif vertical_direction:
		velocity.y = vertical_direction * SPEED

	move_and_slide()
