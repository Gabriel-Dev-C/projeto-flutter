import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImageService {
  final ImagePicker _picker = ImagePicker();

  // Função para escolher a foto e guardá-la permanentemente no telemóvel
  Future<String?> selecionarFoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50, // Comprime a imagem para não ocupar muito espaço
      );

      if (image == null) return null;

      // 1. Achar a pasta de documentos do app
      final directory = await getApplicationDocumentsDirectory();

      // 2. Criar um nome único para a imagem
      final String fileName =
          "perfil_${DateTime.now().millisecondsSinceEpoch}${p.extension(image.path)}";
      final String savedPath = '${directory.path}/$fileName';

      // 3. Copiar a imagem da pasta temporária para a pasta fixa
      final File localImage = await File(image.path).copy(savedPath);

      return localImage.path; // Retorna o caminho para guardares no perfil
    } catch (e) {
      ("Erro ao selecionar imagem: $e  ");
      return null;
    }
  }
}
