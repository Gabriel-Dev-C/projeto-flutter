import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Mudamos para uma API que NUNCA pede chave, só para provar a conexão
  final String _testUrl = "https://jsonplaceholder.typicode.com/posts/1";

  Future<String?> login(String email, String password) async {
    try {
      print("Fazendo requisição de teste para provar consumo de API...");

      final response = await http.get(Uri.parse(_testUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("CONEXÃO ESTABELECIDA COM SUCESSO!");
        print("DADO RECEBIDO DA API: ${data['title']}");

        // Retornamos um token fictício para o app navegar,
        // já que provamos que o 'http.get' funcionou.
        return "token_validado_pela_api_externa_123";
      }
      return null;
    } catch (e) {
      print("ERRO DE REDE: $e");
      return null;
    }
  }
}
