extends Control

# -----------------------------
# Словарь чисел
# -----------------------------
var numbers = {
	1: {"en": "one", "ru": "один"},
	2: {"en": "two", "ru": "два"},
	3: {"en": "three", "ru": "три"},
	4: {"en": "four", "ru": "четыре"},
	5: {"en": "five", "ru": "пять"},
	6: {"en": "six", "ru": "шесть"},
	7: {"en": "seven", "ru": "семь"},
	8: {"en": "eight", "ru": "восемь"},
	9: {"en": "nine", "ru": "девять"},
	10: {"en": "ten", "ru": "десять"},
	11: {"en": "eleven", "ru": "одиннадцать"},
	12: {"en": "twelve", "ru": "двенадцать"},
	13: {"en": "thirteen", "ru": "тринадцать"},
	14: {"en": "fourteen", "ru": "четырнадцать"},
	15: {"en": "fifteen", "ru": "пятнадцать"},
	16: {"en": "sixteen", "ru": "шестнадцать"},
	17: {"en": "seventeen", "ru": "семнадцать"},
	18: {"en": "eighteen", "ru": "восемнадцать"},
	19: {"en": "nineteen", "ru": "девятнадцать"},
	20: {"en": "twenty", "ru": "двадцать"}
}

# -----------------------------
# Языки
# -----------------------------
var languages : Array = ["ru", "en"]
var native_language : String = "ru"
var target_language : String = "en"

# -----------------------------
# Игровые переменные
# -----------------------------
var current_number : int = 0
var score : int = 0

# -----------------------------
# Сцена готова
# -----------------------------
func _ready() -> void:
	randomize()
	populate_language_buttons()
	generate_question()
	print("Ready! Native:", native_language, "Target:", target_language)

# -----------------------------
# Генерация вопроса
# -----------------------------
func generate_question() -> void:
	current_number = randi() % 20 + 1

	# Label на target_language
	$NumberLabel.text = numbers[current_number][target_language]

	# Генерируем варианты ответов
	var answers : Array = [current_number]
	while answers.size() < 3:
		var wrong : int = randi() % 20 + 1
		if wrong not in answers:
			answers.append(wrong)
	answers.shuffle()

	# Присваиваем текст кнопкам на native_language
	for i in range(3):
		var btn = $Answers.get_child(i)
		btn.text = numbers[answers[i]][native_language]
		btn.set_meta("number", answers[i])

# -----------------------------
# Проверка ответа
# -----------------------------
func _on_answer_pressed(button : Button) -> void:
	var selected_number = button.get_meta("number")
	if selected_number == current_number:
		score += 1
	$ScoreLabel.text = get_score_text()
	generate_question()

func get_score_text() -> String:
	match native_language:
		"ru":
			return "Очки: %d" % score
		"en":
			return "Score: %d" % score
		_:
			return "Score: %d" % score

# -----------------------------
# Сигналы кнопок ответов
# -----------------------------
func _on_answer_1_pressed() -> void:
	_on_answer_pressed($Answers/Answer1)


func _on_answer_2_pressed() -> void:
	_on_answer_pressed($Answers/Answer2)


func _on_answer_3_pressed() -> void:
	_on_answer_pressed($Answers/Answer3)
# -----------------------------
# Озвучка числа
# -----------------------------
func _on_play_sound_button_pressed() -> void:
	var path : String = "res://audio/%s/%d.mp3" % [target_language, current_number]
	print("Trying to play audio:", path)
	if FileAccess.file_exists(path):
		var stream = load(path)
		if stream:
			$AudioPlayer.stream = stream
			$AudioPlayer.play()
			print("Playing audio...")
		else:
			print("Failed to load audio stream")
	else:
		print("Audio file not found")

# -----------------------------
# OptionButton
# -----------------------------
func populate_language_buttons() -> void:
	$NativeLanguageButton.clear()
	$TargetLanguageButton.clear()
	for lang_code in languages:
		var name = get_language_name(lang_code)
		$NativeLanguageButton.add_item(name)
		$TargetLanguageButton.add_item(name)
	$NativeLanguageButton.selected = languages.find(native_language)
	$TargetLanguageButton.selected = languages.find(target_language)

func get_language_name(code : String) -> String:
	match code:
		"ru": return "Русский"
		"en": return "English"
		"es": return "Español"
		"fr": return "Français"
		"de": return "Deutsch"
		_: return code

func _on_native_language_button_item_selected(index : int) -> void:
	var new_native = languages[index]
	if new_native == target_language:
		# target язык не может совпадать, переключаем его на старый native
		target_language = native_language
		$TargetLanguageButton.selected = languages.find(target_language)
	native_language = new_native
	print("Native language set to:", native_language, "Target language:", target_language)
	$ScoreLabel.text = get_score_text()
	generate_question()  # обновляем кнопки на новый native

func _on_target_language_button_item_selected(index : int) -> void:
	var new_target = languages[index]
	if new_target == native_language:
		# native язык не может совпадать, переключаем его на старый target
		native_language = target_language
		$NativeLanguageButton.selected = languages.find(native_language)
	target_language = new_target
	print("Target language set to:", target_language, "Native language:", native_language)
	generate_question()  # обновляем Label на новый target
	$ScoreLabel.text = get_score_text()
