import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

class ImageService {
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();
  final String baseUrl = ApiConfig.baseUrl;

  // Sélectionner une image depuis la galerie
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('Erreur lors de la sélection de l\'image: $e');
      rethrow;
    }
  }

  // Sélectionner une image depuis la caméra
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera, 
        imageQuality: 80,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('Erreur lors de la prise de photo: $e');
      rethrow;
    }
  }

  // Télécharger une image sur le serveur
  Future<String> uploadImage(File imageFile) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        throw Exception('Non authentifié');
      }

      // Créer une requête multipart
      var request = http.MultipartRequest(
        'POST', 
        Uri.parse('$baseUrl/api/upload/image')
      );
      
      // Ajouter l'image au formulaire
      final filename = basename(imageFile.path);
      final mimeType = _getMimeType(filename);
      
      request.files.add(
        http.MultipartFile(
          'image',
          imageFile.readAsBytes().asStream(),
          imageFile.lengthSync(),
          filename: filename,
          contentType: MediaType(mimeType.split('/')[0], mimeType.split('/')[1]),
        ),
      );
      
      // Ajouter le token d'authentification
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });
      
      // Envoyer la requête
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = _parseResponse(responseBody);
        return data['imageUrl'] as String;
      } else {
        throw Exception('Échec du téléchargement de l\'image: $responseBody');
      }
    } catch (e) {
      print('Erreur lors du téléchargement de l\'image: $e');
      rethrow;
    }
  }
  
  // Déterminer le type MIME d'un fichier
  String _getMimeType(String path) {
    final ext = extension(path).toLowerCase();
    
    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }
  
  // Parser la réponse JSON
  Map<String, dynamic> _parseResponse(String responseBody) {
    try {
      return Map<String, dynamic>.from(
        (responseBody.startsWith('{')) 
            ? HttpJsonDecoder().convert(responseBody) 
            : {'imageUrl': responseBody.trim()}
      );
    } catch (e) {
      return {'imageUrl': responseBody.trim()};
    }
  }
}

class HttpJsonDecoder {
  dynamic convert(String response) {
    return response.isEmpty ? {} : json.decode(response);
  }
}

// Import json uniquement ici pour éviter les conflits
import 'dart:convert' as json; 