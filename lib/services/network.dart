import 'dart:convert';

import 'package:http/http.dart' as http;

class FetchApiData{

  String _apiKey = 'YOUR-API-KEY';

  Future<String> GenerateResponse(String prompt) async {
    // Préparez les données à envoyer à l'API
    // Envoyez la requête HTTP
    http.Response response = await http.post(
      Uri.parse('https://api.openai.com/v1/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
        'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'text-davinci-003',
        'prompt': prompt,
        'max_tokens': 2000,
        'temperature': 0,
        'top_p': 1,
        'frequency_penalty': 0.0,
        'presence_penalty': 0.0,
      }),
    );
    // Retournez la réponse sous forme de chaîne de caractères
    var responseDecoded = jsonDecode(response.body);
    var responseText = responseDecoded['choices'][0]['text'];
    String responseUTF8 = utf8.decode(responseText.runes.toList());
    return responseUTF8;
  }
}