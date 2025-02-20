extends Node

var api_key = "AIzaSyDgv39W3NOOnH9YzE-w3jHNk99WyC9JUyg"  # Votre clé API
var api_url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=" + api_key

func send_request_to_gemini(prompt: String):
	var body = {
		"contents": [{
			"parts": [{"text": prompt}]
		}]
	}
	
	var json_body = JSON.stringify(body)
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_on_request_completed")
	
	var headers = ["Content-Type: application/json"]
	var error = http_request.request(api_url, headers, false, HTTPClient.METHOD_POST, json_body)
	
	if error != OK:
		print("Erreur lors de l'envoi de la requête : ", error)

func _on_request_completed(result, response_code, headers, body):
	var raw_response = body.get_string_from_utf8()
	print("Réponse brute : ", raw_response)  # Pour déboguer
	
	if response_code == 200:
		var json = JSON.parse(raw_response)
		if json.error == OK:
			var response = json.result
			# Extraction du texte avec vérification des clés
			if response.has("candidates") && response["candidates"].size() > 0:
				var candidate = response["candidates"][0]
				if candidate.has("content") && candidate["content"].has("parts") && candidate["content"]["parts"].size() > 0:
					var ai_message = candidate["content"]["parts"][0].get("text", "Pas de texte trouvé")
					print("Réponse de l'IA : ", ai_message)
				else:
					print("Structure 'content/parts' invalide")
			else:
				print("Aucun candidat trouvé dans la réponse")
		else:
			print("Erreur JSON : ", json.error_string)
	else:
		print("Erreur HTTP : ", response_code)
		print("Message d'erreur : ", raw_response)

func _ready():
	send_request_to_gemini("Explain how AI works")
