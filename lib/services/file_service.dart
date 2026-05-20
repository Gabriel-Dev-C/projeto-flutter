import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileService {
  // Acha a pasta de documentos do celular
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Agora o arquivo tem o nome do usuário (ex: log_coach_ia_Matheus.txt)
  Future<File> _localFile(String userName) async {
    final path = await _localPath;
    // Removemos espaços ou caracteres estranhos do nome para não dar erro no arquivo
    String safeName = userName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    return File('$path/log_coach_ia_$safeName.txt');
  }

  // Adicionado parâmetro userName
  Future<void> salvarNoLog(
      String tempo, String feedback, String userName) async {
    final file = await _localFile(userName);

    ("Gravando no Filesystem do usuário $userName: ${file.path}");

    final dataAtual = DateTime.now().toString().substring(0, 19);

    await file.writeAsString(
      '--- REGISTRO [$dataAtual] ---\nTempo: $tempo\nCoach: $feedback\n\n',
      mode: FileMode.append,
    );

    (" Upgrade registrado com sucesso para $userName.");
  }

  // Adicionado parâmetro userName
  Future<String> lerHistorico(String userName) async {
    try {
      final file = await _localFile(userName);
      if (await file.exists()) {
        return await file.readAsString();
      } else {
        return "Nenhum registro no mainframe para $userName.";
      }
    } catch (e) {
      return "Erro ao acessar registros de $userName.";
    }
  }

  // Função para deletar o log se o usuário excluir a conta
  Future<void> deletarLog(String userName) async {
    final file = await _localFile(userName);
    if (await file.exists()) {
      await file.delete();
      (" Log de $userName deletado.");
    }
  }
}
