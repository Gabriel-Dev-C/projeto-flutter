import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String _testUrl = "https://jsonplaceholder.typicode.com/posts/1";

  Future<String?> login(String email, String password) async {
    try {
      ("Fazendo requisição de teste para provar consumo de API...");

      final response = await http.get(Uri.parse(_testUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ("CONEXÃO ESTABELECIDA COM SUCESSO!");
        ("DADO RECEBIDO DA API: ${data['title']}");

      
        return "token_validado_pela_api_externa_123";
      }
      return null;
    } catch (e) {
      ("ERRO DE REDE: $e");
      return null;
    }
  }
}
