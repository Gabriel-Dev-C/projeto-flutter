import 'dart:convert';
import 'package:http/http.dart' as http;

class AiHandler {
  static const String _apiKey =
      "COLE AQUI A CHAVE QUE ESTA NO COMENTARIO DA ATIVIDADE NO AVA";

  static Future<String> getCoachFeedback(String tempo) async {
    try {
      final url = Uri.parse("https://api.groq.com/openai/v1/chat/completions");

      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $_apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "llama-3.1-8b-instant",
          "messages": [
            {
              "role": "system",
              "content":
                  "Você é o Coach FitStart, uma IA cyberpunk tóxica e engraçada. tente humilhar falando da ex com outro ou coisas assim. Seja agressiva, mas engraçada. Não seja gentil. Seja direta e curta."
                      "Dê feedbacks curtos e agressivos sobre o tempo de treino."
            },
            {
              "role": "user",
              "content": "Acabei de treinar por $tempo. O que tem para mim?"
            }
          ],
          "temperature": 0.7
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'];
      } else {
        return "Erro no mainframe: Status ${response.statusCode}";
      }
    } catch (e) {
      return "Treino de $tempo processado. Enquanto você malha, ela está online com outro. Sistema otimizado.";
    }
  }
}
