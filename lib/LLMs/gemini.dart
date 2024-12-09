import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/services.dart';
import 'package:my_flutter_application/Classes/ListingClass.dart';
import 'package:my_flutter_application/Screens/homeScreen.dart';

GenerativeModel createGeminiModel() {
  final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: "AIzaSyDygDJL197WoLsOd5U1p15TqiOnhW4aggI",
  );
  return model;
}

Future<Uint8List> bytesFromImageUrl(String url) async {
  final response = await http.get(Uri.parse(url));

  return response.bodyBytes;
}

Future<String> sendGeminiText(ChatSession chat, String msg) async {
  final content = Content.text(msg);
  var response = await chat.sendMessage(content);

  return response.text.toString();
}

Future<GenerateContentResponse> sendGeminiTextAndImages(
    ChatSession session, String msg, List<String> imageUrls) async {
  final prompt = TextPart(msg);
  final imageParts = [
    for (int i = 0; i < imageUrls.length; i++)
      if (imageUrls[i] != "")
        DataPart('image/jpeg', await bytesFromImageUrl(imageUrls[i]))
  ];

  final content = Content.multi([prompt, ...imageParts]);
  var response = await session.sendMessage(content);
  return response;
}

Future<String> assetsFileToString(path) async {
  WidgetsFlutterBinding.ensureInitialized();
  return await rootBundle.loadString(path);
}

String createGeminiInput(Map<String, dynamic> property) {
  try {
    String description = property["description"];
    List<String> features = property["keyFeatures"];
    String bedrooms = property["bedrooms"] ?? "";
    String bathrooms = property["bathrooms"] ?? "";
    String price = property["price"] ?? "";
    String output =
        "Price: $price\nBedrooms: $bedrooms\nBathroom: $bathrooms\n";
    for (var feature in features) {
      output += "$feature\n";
    }
    output += description;
    return output;
  } catch (e) {
    showDialog(
      context: navigatorKey.currentState!.context,
      builder: (context) => AlertDialog(
        title: const Text('Error Reading properties'),
        content: Text('Error: $e\n'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return "";
  }
}

Future<ChatSession> startGeminiChat(GenerativeModel model) async {
  var chat = model.startChat();
  return chat;
}

Future<int> setupGeminiChat(ChatSession chat, GenerativeModel model) async {
  String setup =
      r'''I will provide you with multiple Property Listing descriptions, images and floorplans. Create an objective set of
        of positive bullet points and negative bullet points and gold star bullet point rating out of 5 for different 
        aspects. Don't mention lease tenure. For a 1 bedroom flat a good size is 480-600sqft, for a 2 bedroom flat a good 
        size is 700-915sqft and for a 3 bedroom flat a good size is 915-1184sqft, 
        Output should be a single JSON with three fields like this:
        {
          "Summary": "### **Positives**
                      + Large Size
                      + Good Area
                      ### **Watch Out For**
                      - High Service Charge
                      ### **Ratings**
                      * Location: ★★★  
                      * Size: ★★★★★
                      * Amenities: ★★
                      * Finishes/Quality: ★★★★
                      * Overall: ★★★★ 
          "SquareFootage" : 600 sqft [string]
          "OverallRating": 3.5 [double]
        }''';
  /*String setupResponse = */ await sendGeminiText(chat, setup);

  var countResponse = await model.countTokens([Content.text(setup)]);
  return countResponse.totalTokens;
}

Future<Listing> buildListingFromGemini(ChatSession chat,
    Map<String, dynamic> property, String geminiAreaSummary) async {
  String textInput = createGeminiInput(property);
  List<String> imagePaths = property['images'];
  if (property['floorplanPath'] != null && property['floorplanPath'] != "") {
    imagePaths.add(property['floorplanPath']);
  }
  GenerateContentResponse response =
      await sendGeminiTextAndImages(chat, textInput, imagePaths);

  String responseText = response.text.toString();
  var jsonObj = jsonDecode(responseText.substring(8, responseText.length - 4));
  String geminiSummary = jsonObj['Summary'];
  double overallRating = jsonObj['OverallRating'] as double;

  int inputTokenCount = response.usageMetadata?.promptTokenCount ?? 0;
  int outputTokenCount = response.usageMetadata?.candidatesTokenCount ?? 0;

  Listing listing = Listing(
      property['id'],
      property['url'] ?? "",
      false,
      overallRating,
      property['headline'] ?? "",
      property['address'] ?? "",
      property['description'] ?? "",
      property['keyFeatures'] ?? List.empty(),
      property['price'] ?? "",
      property['type'] ?? "",
      property['bedrooms'] ?? "",
      property['bathrooms'] ?? "",
      (property['sqft'] == null || property['sqft'] == "Ask agent")
          ? jsonObj['SquareFootage'].toString()
          : property['sqft'],
      property['images'] ?? List.empty(),
      property['floorplanPath'] ?? "",
      geminiSummary,
      geminiAreaSummary,
      inputTokenCount,
      outputTokenCount);

  return listing;
}
