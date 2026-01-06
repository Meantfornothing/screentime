// lib/core/services/gemini_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static String get apiKey => dotenv.env['GEMINI_API_KEY'] ?? "";
  static const String model = "gemini-2.5-flash";
  static const String apiBase = "https://generativelanguage.googleapis.com/v1beta/models";

  static Future<String?> generateVisualPrompt({
    required Map<String, int> categoryPercentages,
  }) async {
    if (apiKey.isEmpty) return null;

    final distributionText = categoryPercentages.entries
        .map((e) => "- ${e.key}: ${e.value}%")
        .join("\n");

    final systemPrompt = 
        "You are an AI artist creating an abstract data visualization painting. "
        "Create a cohesive composition where colors correspond to these percentages: "
        "Productivity (Green geometric), Entertainment (Orange energy), Social (Purple bubbles), Relaxation (Blue waves). "
        "Output ONLY a descriptive prompt in English (max 40 words).";

    final url = Uri.parse("$apiBase/$model:generateContent?key=$apiKey");
    final payload = {
      "contents": [{"parts": [{"text": "$systemPrompt\n\nData:\n$distributionText"}]}]
    };

    try {
      final response = await http.post(
        url, 
        headers: {"Content-Type": "application/json"}, 
        body: jsonEncode(payload)
      );
      
      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        final description = jsonBody["candidates"][0]["content"]["parts"][0]["text"];
        
        final encodedPrompt = Uri.encodeComponent(description);
        final seed = Random().nextInt(10000);
        // Använder Pollinations AI för att rendera bilden baserat på Geminis beskrivning
        return "https://image.pollinations.ai/prompt/$encodedPrompt?seed=$seed&width=1024&height=1024&model=flux&nologo=true";
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}