import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiChatService {
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  
  late final GenerativeModel _model;
  late final ChatSession _chat;

  AiChatService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
      systemInstruction: Content.system(
        'You are the Routo AI Assistant. Routo is a smart route delivery and navigation app. '
        'Your goal is to help users with: \n'
        '1. Finding the best delivery routes.\n'
        '2. Tracking parcels.\n'
        '3. Understanding delivery earnings.\n'
        '4. Navigating the app features (Login, Profile, Saved Addresses, Rider Screens).\n\n'
        'Keep your responses professional, helpful, and concise. '
        'If the user asks something unrelated to Routo or delivery, politely redirect them to how you can help within the app.'
      ),
    );
    _chat = _model.startChat();
  }

  bool get isConfigured => _apiKey.isNotEmpty;

  Future<String> sendMessage(String message) async {
    if (!isConfigured) {
      return 'I am currently in "offline mode" because the API key is not configured. Please provide a GEMINI_API_KEY to enable my full AI capabilities.';
    }

    try {
      final response = await _chat.sendMessage(Content.text(message));
      return response.text ?? 'I encountered an issue processing your request. Could you try again?';
    } catch (e) {
      debugPrint('Error sending message to Gemini: $e');
      
      final errorString = e.toString();
      
      // Return the exact error string so we can see what Google's servers are actually saying
      return 'API Error:\n$errorString';
    }
  }
}
