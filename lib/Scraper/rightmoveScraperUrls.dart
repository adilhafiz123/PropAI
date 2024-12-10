import 'package:html/dom.dart';
import 'dart:core';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

Future<List<List<String>>> getListOfUrlsAndIds(String topLevelUrl) async {
  var headersMap = {
    "User-Agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
    "Accept":
        "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.5",
    "Accept-Encoding": "gzip, deflate, br",
    "Connection": "keep-alive",
    "Upgrade-Insecure-Requests": "1",
    "Cache-Control": "no-cache",
    "Pragma": "no-cache",
    "Referer": "https://www.rightmove.co.uk/",
  };
  final response = await http.get(Uri.parse(topLevelUrl), headers: headersMap);

  if (response.statusCode == 200) {
    final document = parse(response.body);

    // Extract all links with the class "propertyCard-link"
    List<Element> linkElements =
        document.querySelectorAll('a.propertyCard-link');

    // Extract the href attribute and prepend the base URL
    String baseUrl = "https://www.rightmove.co.uk";
    List<String> urls = linkElements
        .map((element) => ((element.attributes['href'] != null) &&
                (element.attributes['href'] != ""))
            ? '$baseUrl${element.attributes['href']}'
            : null)
        .where((url) => url != null) // Remove nulls
        .cast<String>() // Ensure the type is String
        .toSet()
        .toList();

    var ids = urls.map(
      (url) {
        final uri = Uri.parse(url);
        final pathSegments = uri.pathSegments;

        if (pathSegments.isEmpty) {
          throw "No ID found for URL: $url";
        }
        // The ID is usually the last segment (assuming rightmove follows this format)
        return pathSegments.last;
      },
    ).toList();

    return [urls, ids];
  }
  return List.empty();
}
