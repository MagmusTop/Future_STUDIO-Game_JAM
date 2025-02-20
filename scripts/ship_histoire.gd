extends CharacterBody2D

@onready var q_lab = get_parent().get_node("QuestionLabel")
@onready var ans_1 = get_parent().get_node("AnswerLabel1")
@onready var ans_2 = get_parent().get_node("AnswerLabel2")
@onready var ans_3 = get_parent().get_node("AnswerLabel3")
@onready var ans_validation = get_parent().get_node("AnswerValidation")
@onready var count = get_parent().get_node("Timer")
@onready var question_timer = Timer.new()
@onready var collision_shape = $Sprite2D/Area2D/CollisionShape2D
@onready var astro_face = get_parent().get_node("AstroFace")
@onready var popup = get_parent().get_node("HintPopup")
@onready var title_label = get_parent().get_node("HintPopup/TitleLabel")
@onready var hint_label = get_parent().get_node("HintPopup/HintLabel")
@onready var close_button = get_parent().get_node("HintPopup/CloseButton")
@onready var hover_sound = $"../HoverSound"
@onready var click_sound = $"../ClickSound"
@onready var good_response_sound = $"../GoodResponseSound"
@onready var bad_response_sound = $"../BadResponseSound"
@onready var end_game_sound = $"../GameEndSound"
@onready var dialog_baloon = $"../DialogBaloon"
@onready var timer_label = $"../TimerLabel"
@onready var countdown_timer = Timer.new()

const SPEED = 300.0

var current_question_index: int = 0
var good_answers: int = 0
var bad_answers: int = 0
var score: int = 0
var start_position = Vector2()
var is_correct_answer = false
var time_remaining = 15
var questions = [
	{
		"question": "Quelle civilisation est célèbre pour avoir construit les pyramides en Égypte ?",
		"answers": ["Les Grecs", "Les Romains", "Les Égyptiens"],
		"correct_answer": 2,
		"hint": "Les pyramides sont emblématiques de l'Ancienne Égypte, et en particulier des pharaons. Les Grecs et les Romains ont aussi réalisé des avancées architecturales, mais les pyramides sont spécifiquement associées à la civilisation égyptienne. Rappelez-vous que ces civilisations ont surtout contribué à d'autres domaines, comme la philosophie et le droit."
	},
	{
		"question": "Quelle est la principale cause de la Révolution Française de 1789 ?",
		"answers": ["L'invasion militaire de la France par l'Angleterre", "Les inégalités sociales et la crise économique", "Le désir de conquête coloniale de la France"],
		"correct_answer": 1,
		"hint": "La Révolution Française a été en grande partie provoquée par des inégalités profondes entre les différentes classes sociales (le Tiers État, le clergé et la noblesse) et par une grave crise économique, exacerbée par la dette de l'État et la mauvaise récolte. Rappelez-vous que l'invasion militaire ou la conquête coloniale n'étaient pas les causes immédiates de la révolution."
	},
	{
		"question": "En quelle année a commencé la Première Guerre Mondiale ?",
		"answers": ["1912", "1914", "1916"],
		"correct_answer": 1,
		"hint": "La Première Guerre Mondiale a commencé le 28 juillet 1914, après l'assassinat de l'archiduc François-Ferdinand d'Autriche. Si vous avez choisi une autre date, cela pourrait être lié à une autre guerre ou événement historique. Par exemple, la guerre des tranchées a principalement eu lieu entre 1914 et 1918."
	},
	{
		"question": "Quel événement a marqué le début de la Seconde Guerre Mondiale ?",
		"answers": ["L'invasion de la Pologne par l'Allemagne", "L'attaque de Pearl Harbor", "Le débarquement en Normandie"],
		"correct_answer": 0,
		"hint": "La Seconde Guerre Mondiale a commencé officiellement le 1er septembre 1939, lorsque l'Allemagne nazie a envahi la Pologne. L'attaque de Pearl Harbor, qui a eu lieu en 1941, a entraîné l'entrée en guerre des États-Unis, mais elle ne marque pas le début du conflit mondial. Quant au débarquement en Normandie, il a eu lieu en 1944, bien après le début de la guerre."
	},
	{
		"question": "La guerre froide était principalement un conflit entre quelles deux superpuissances ?",
		"answers": ["Les États-Unis et l'Union Soviétique", "La Chine et le Japon", "L'Allemagne et la France"],
		"correct_answer": 0,
		"hint": "La guerre froide a opposé les États-Unis, représentant du capitalisme et de la démocratie, à l'Union Soviétique, représentant du communisme et du totalitarisme. Ce conflit idéologique et politique a duré plusieurs décennies après la Seconde Guerre Mondiale, mais n'a pas donné lieu à un affrontement militaire direct. Si vous avez choisi une autre option, cela pourrait correspondre à d'autres conflits, mais pas à la guerre froide."
	}
]

enum GameState { PLAYING, ANSWERING, TRANSITIONING }
var current_state = GameState.PLAYING

enum PopupState { RULES, HINT, END_GAME, TIMEOUT }
var current_popup_state = PopupState.RULES

const GAME_RULES = """
Bienvenue dans le Quiz Spatial !

Dirigez le vaisseau vers l'astronaute qui porte la bonne réponse.
Vous gagnez 5 points pour chaque bonne réponse, perdez 1 point pour chaque mauvaise réponse ou un timeout.
Vous avez 15 secondes pour répondre à chaque question.
Utilisez les flèches du clavier pour vous déplacer.

Bonne chance !
"""

var good_responses = [
	"Bonne réponse !",
	"Excellent !",
	"Bravo !",
	"C'est exact !",
	"Parfait !",
	"Tu as raison !",
	"Bien joué !"
]

var bad_responses = [
	"Mauvaise réponse.",
	"Pas tout à fait...",
	"Essaie encore !",
	"Ce n'est pas ça.",
	"Incorrect.",
	"Tu peux faire mieux !",
	"Pas exactement..."
]

func _ready():
	start_position = position
	setup_popup()
	astro_face.hide()
	dialog_baloon.hide()
	add_child(question_timer)
	question_timer.wait_time = 3.0
	question_timer.one_shot = true
	question_timer.timeout.connect(_on_QuestionTimer_timeout)
	close_button.pressed.connect(_on_close_button_pressed)
	close_button.mouse_entered.connect(_on_button_hover)
	close_button.button_down.connect(_on_button_click)
	
	hint_label.custom_minimum_size = Vector2(300, 0)
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	show_rules()
	
	add_child(countdown_timer)
	countdown_timer.wait_time = 1.0
	countdown_timer.timeout.connect(_on_countdown_timeout)
	timer_label.text = str(time_remaining)

func setup_popup():
	popup.hide()
	popup.custom_minimum_size = Vector2(400, 200)
	
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color("#1e3d59")
	style_box.border_color = Color("#ff6e40")
	style_box.border_width_left = 4
	style_box.border_width_right = 4
	style_box.border_width_top = 4
	style_box.border_width_bottom = 4
	style_box.corner_radius_top_left = 10
	style_box.corner_radius_top_right = 10
	style_box.corner_radius_bottom_left = 10
	style_box.corner_radius_bottom_right = 10
	
	style_box.content_margin_left = 20
	style_box.content_margin_right = 20
	style_box.content_margin_top = 20
	style_box.content_margin_bottom = 20
	
	popup.add_theme_stylebox_override("panel", style_box)
	
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.custom_minimum_size.y = 40
	title_label.add_theme_color_override("font_color", Color("#ffc13b"))
	title_label.add_theme_font_size_override("font_size", 24)
	
	var button_style = StyleBoxFlat.new()
	button_style.bg_color = Color("#ff6e40")
	button_style.border_color = Color("#ffc13b")
	button_style.border_width_left = 2
	button_style.border_width_right = 2
	button_style.border_width_top = 2
	button_style.border_width_bottom = 2
	button_style.corner_radius_top_left = 5
	button_style.corner_radius_top_right = 5
	button_style.corner_radius_bottom_left = 5
	button_style.corner_radius_bottom_right = 5
	
	close_button.custom_minimum_size = Vector2(200, 40)
	close_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	close_button.add_theme_stylebox_override("normal", button_style)
	close_button.add_theme_color_override("font_color", Color.WHITE)
	close_button.add_theme_font_size_override("font_size", 18)
	
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hint_label.custom_minimum_size = Vector2(360, 0)
	hint_label.add_theme_color_override("font_color", Color.WHITE)
	hint_label.add_theme_font_size_override("font_size", 16)
	
	hint_label.add_theme_constant_override("margin_top", 10)
	hint_label.add_theme_constant_override("margin_bottom", 20)
	close_button.add_theme_constant_override("margin_top", 10)

func show_rules():
	current_popup_state = PopupState.RULES
	title_label.text = "Règles du jeu"
	hint_label.text = GAME_RULES
	close_button.text = "Lancer la partie"
	popup.show()

func show_hint(hint_text: String):
	current_popup_state = PopupState.HINT
	title_label.text = "Indice"
	hint_label.text = hint_text
	close_button.text = "Réessayer"
	popup.show()

func _physics_process(delta: float) -> void:
	var horizontal_direction := Input.get_axis("ui_left", "ui_right")
	var vertical_direction := Input.get_axis("ui_up", "ui_down")

	velocity = Vector2.ZERO

	if horizontal_direction:
		velocity.x = horizontal_direction * SPEED
	if vertical_direction:
		velocity.y = vertical_direction * SPEED

	move_and_slide()

func assign_answers_to_astronauts():
	var current_question = questions[current_question_index]
	var correct_astronaut_index = randi() % 3
	
	var astronauts = get_tree().get_nodes_in_group("astro")
	
	var available_answers = range(3)
	
	astronauts[correct_astronaut_index].set_answer(current_question["correct_answer"])
	available_answers.erase(current_question["correct_answer"])
	
	for i in range(astronauts.size()):
		if i != correct_astronaut_index:
			var random_index = randi() % available_answers.size()
			var wrong_answer = available_answers[random_index]
			astronauts[i].set_answer(wrong_answer)
			available_answers.remove_at(random_index)

func get_random_response(is_correct: bool) -> String:
	var responses = good_responses if is_correct else bad_responses
	return responses[randi() % responses.size()]

func check_answer(astronaut):
	countdown_timer.stop()
	if current_state != GameState.PLAYING:
		return
		
	current_state = GameState.ANSWERING
	collision_shape.set_deferred("disabled", true)
	is_correct_answer = astronaut.answer == questions[current_question_index]["correct_answer"]
	
	dialog_baloon.show()
	
	if is_correct_answer:
		good_response_sound.play()
		good_answers += 1
		score += 5
		astronaut.hide()
		for a in get_tree().get_nodes_in_group("astro"):
			if a != astronaut:
				a.fall_down()
		ans_validation.text = get_random_response(true)
		astro_face.show()
		astro_face.play("good")
		question_timer.start()
	else:
		bad_response_sound.play()
		bad_answers += 1
		score = max(0, score - 1)
		ans_validation.text = get_random_response(false)
		astro_face.show()
		astro_face.play("bad")
		show_hint(questions[current_question_index]["hint"])

func _on_QuestionTimer_timeout():
	if !is_correct_answer:
		return
		
	current_state = GameState.TRANSITIONING
	astro_face.hide()
	ans_validation.text = ""
	
	current_question_index += 1
	if current_question_index < questions.size():
		reset_scene()
		setup_new_question()
	else:
		end_game()

func _on_close_button_pressed():
	popup.hide()
	
	match current_popup_state:
		PopupState.RULES:
			setup_new_question()
		PopupState.HINT:
			if current_state == GameState.ANSWERING:
				astro_face.hide()
				reset_scene()
				setup_new_question()
		PopupState.TIMEOUT:
			reset_scene()
			setup_new_question()
		PopupState.END_GAME:
			get_tree().change_scene_to_file("res://scenes/modules_menu.tscn")

func reset_scene():
	position = start_position
	dialog_baloon.hide()
	for a in get_tree().get_nodes_in_group("astro"):
		a.reset_position()

func setup_new_question():
	current_state = GameState.PLAYING
	assign_answers_to_astronauts()
	display_question()
	collision_shape.set_deferred("disabled", false)
	popup.hide()
	astro_face.hide()
	dialog_baloon.hide()
	ans_validation.text = ""
	time_remaining = 15
	timer_label.text = str(time_remaining)
	countdown_timer.start()

func next_question():
	ans_validation.text = ""
	position = start_position
	collision_shape.set_deferred("disabled", false)
	var astro_group = get_tree().get_nodes_in_group("astro")
	for a in astro_group:
		a.reset_position()
		a.show()
	current_question_index += 1
	if current_question_index < questions.size():
		assign_answers_to_astronauts()
		display_question()
	else:
		end_game()
	astro_face.hide()

func format_question_text(question: String, max_chars_per_line: int = 60) -> String:
	var words = question.split(" ")
	var lines = []
	var current_line = ""
	
	for word in words:
		if current_line.length() + word.length() + 1 <= max_chars_per_line:
			if current_line.length() > 0:
				current_line += " "
			current_line += word
		else:
			lines.append(current_line)
			current_line = word
	
	if current_line.length() > 0:
		lines.append(current_line)
	
	return "\n".join(lines)

func display_question():
	if current_question_index >= questions.size():
		return
	var current_question = questions[current_question_index]
	q_lab.set_text(format_question_text(current_question["question"]))

	var astronauts = get_tree().get_nodes_in_group("astro")
	for i in range(astronauts.size()):
		match i:
			0: ans_1.set_text("Astro Orange : " + current_question["answers"][astronauts[i].answer])
			1: ans_2.set_text("Astro Rose : " + current_question["answers"][astronauts[i].answer])
			2: ans_3.set_text("Astro Vert : " + current_question["answers"][astronauts[i].answer])

func game_over():
	print("Game Over ! Votre score final est : ", score)
	get_tree().reload_current_scene()

func end_game():
	countdown_timer.stop()
	current_state = GameState.TRANSITIONING
	dialog_baloon.hide()
	q_lab.hide()
	ans_1.hide()
	ans_2.hide()
	ans_3.hide()
	ans_validation.hide()
	timer_label.hide()
	show_end_game()

func show_end_game():
	current_popup_state = PopupState.END_GAME
	title_label.text = "Partie Terminée"
	hint_label.text = "Vous avez eu " + str(good_answers) + " bonnes réponses et " + \
					 str(bad_answers) + " mauvaises réponses.\nVotre score final est " + str(score)
	close_button.text = "Retourner au choix des modules"
	end_game_sound.play()
	popup.show()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("astro"):
		check_answer(area)

func _on_button_hover():
	hover_sound.play()

func _on_button_click():
	click_sound.play()

func _on_countdown_timeout():
	time_remaining -= 1
	timer_label.text = str(time_remaining)
	
	if time_remaining <= 0:
		handle_timeout()
		countdown_timer.stop()

func handle_timeout():
	if current_state != GameState.PLAYING:
		return
		
	current_state = GameState.ANSWERING
	collision_shape.set_deferred("disabled", true)
	score = max(0, score - 1)
	bad_answers += 1
	bad_response_sound.play()
	show_timeout()

func show_timeout():
	current_popup_state = PopupState.TIMEOUT
	title_label.text = "Temps écoulé !"
	hint_label.text = questions[current_question_index]["hint"]
	close_button.text = "Réessayer"
	popup.show()
