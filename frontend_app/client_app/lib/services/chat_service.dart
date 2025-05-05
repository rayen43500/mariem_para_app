import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  final String _apiKey = 'AIzaSyBBGnDYnsrrX5RwKCagz5d_rMg8Gesz6xA';
  GenerativeModel? _model;
  ChatSession? _chatSession;
  bool _isInitialized = false;

  factory ChatService() {
    return _instance;
  }

  ChatService._internal();

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      debugPrint('🔄 Initialisation du service Gemini...');
      
      // Initialiser le modèle avec la clé API
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 1024,
        ),
      );
      
      // Créer une nouvelle session de chat
      final content = Content.text(
        'Tu es un assistant spécialisé en parapharmacie. Tu dois donner des conseils précis sur les produits de soin, '
        'les compléments alimentaires, les cosmétiques et autres produits vendus en parapharmacie. '
        'Sois toujours professionnel, précis et bienveillant. Réponds en français seulement. '
        'Recommande des principes actifs spécifiques et des marques connues quand cela est approprié.'
      );
      
      if (_model != null) {
        _chatSession = _model!.startChat(history: [content]);
        _isInitialized = true;
        debugPrint('✅ Service Gemini initialisé avec succès');
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'initialisation du service Gemini: $e');
    }
  }

  Future<String> sendMessage(String message) async {
    if (!_isInitialized) {
      await initialize();
      if (!_isInitialized) {
        return 'Impossible de se connecter au service Gemini. Veuillez vérifier votre connexion et réessayer.';
      }
    }

    try {
      debugPrint('📤 Envoi du message à Gemini: $message');
      
      if (_chatSession == null) {
        debugPrint('❌ La session de chat est null');
        return 'Erreur: La session de chat n\'est pas initialisée. Veuillez réessayer.';
      }
      
      // Créer le contenu du message
      final content = Content.text(message);
      
      // Envoyer le message
      final GenerateContentResponse response;
      try {
        response = await _chatSession!.sendMessage(content);
      } catch (e) {
        debugPrint('❌ Erreur lors de l\'envoi du message: $e');
        return 'Erreur de connexion à l\'API Gemini. Veuillez réessayer plus tard.';
      }
      
      // Extraire la réponse
      final candidates = response.candidates;
      if (candidates == null || candidates.isEmpty) {
        return 'Désolé, je n\'ai pas pu générer une réponse. Veuillez réessayer.';
      }
      
      final contentParts = candidates.first.content.parts;
      if (contentParts.isEmpty) {
        return 'Désolé, je n\'ai pas pu générer une réponse. Veuillez réessayer.';
      }
      
      // Google Generative AI API renvoie la partie texte sous forme de String
      String responseText = '';
      if (contentParts.first is TextPart) {
        final textPart = contentParts.first as TextPart;
        responseText = textPart.text;
      } else {
        debugPrint('⚠️ Format de réponse inattendu: ${contentParts.first.runtimeType}');
        for (final part in contentParts) {
          if (part is TextPart) {
            responseText += part.text;
          }
        }
      }
      
      if (responseText.isEmpty) {
        return 'Désolé, je n\'ai pas pu générer une réponse. Veuillez réessayer.';
      }
      
      debugPrint('📥 Réponse reçue de Gemini');
      return responseText;
    } catch (e) {
      debugPrint('❌ Erreur générale lors de la communication avec Gemini: $e');
      return 'Désolé, une erreur est survenue. Veuillez réessayer plus tard.';
    }
  }

  void resetChat() {
    try {
      if (_model != null) {
        // Définir le contexte système de parapharmacie
        final content = Content.text(
          'Tu es un assistant spécialisé en parapharmacie. Tu dois donner des conseils précis sur les produits de soin, '
          'les compléments alimentaires, les cosmétiques et autres produits vendus en parapharmacie. '
          'Sois toujours professionnel, précis et bienveillant. Réponds en français seulement. '
          'Recommande des principes actifs spécifiques et des marques connues quand cela est approprié.'
        );
        
        // Créer une nouvelle session de chat
        _chatSession = _model!.startChat(history: [content]);
        debugPrint('🔄 Session de chat réinitialisée');
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de la réinitialisation du chat: $e');
    }
  }
} 