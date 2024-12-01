import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

Future<Map<String, dynamic>> scrapeRightmoveProperty(String url) async {
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

  final response = await http.get(Uri.parse(url), headers: headersMap);
  if (response.statusCode == 200) {
    final document = parse(response.body);
    final property = <String, dynamic>{};

    // URL
    property['url'] = url;

    // ID
    final RegExp regExp = RegExp(r"properties/(\d+)");
    final Match? match = regExp.firstMatch(url);
    final id = match != null ? match.group(1) ?? '' : '';
    property['id'] = id;

    // Headline
    final title = document.querySelector("title");
    final bits = title?.text.split(' ');
    final headline = "${bits?[0]} ${bits?[1]} ${bits?[2]}";
    property['headline'] = headline;

    // Images (Improved selector to handle variations)
    final imageElements = document.querySelectorAll(
        '[data-testid="photo-collage"] a[itemprop="photo"] img[src], [data-testid="photo-collage"] a[itemprop="photo"] meta[itemprop="contentUrl"]');
    final images = imageElements
        .map((element) =>
            element.attributes['src'] ?? element.attributes['content']!)
        .toList(); //Gets src or content attributes.
    property['images'] = images.toSet().toList();

    // Floorplan
    var floorplanElement =
        document.querySelector('a[class="_1EKvilxkEc0XS32Gwbn-iU"] img[src]');
    final floorPlan = floorplanElement?.attributes['src'] ??
        floorplanElement?.attributes['content']!;
    property['floorplanPath'] =
        "${floorPlan?.substring(0, floorPlan.length - 17)}.jpeg";

    String? getPropertyData(String labelText) {
      // Find the label element by its text
      final labelElement = document
          .querySelectorAll('.IXkFvLy8-4DdLI1TIYLgX')
          .cast<Element?>()
          .firstWhere((element) => element?.text == labelText,
              orElse: () => null);

      // Get the next sibling's text content if label element exists
      return labelElement?.parent
          ?.querySelector('._1hV1kqpVceE9m-QrX_hWDN')
          ?.text;
    }

    // Address (more robust selector)
    property['address'] =
        document.querySelector('[itemprop="streetAddress"]')?.text.trim();

    // Price
    property['price'] =
        document.querySelector('._1gfnqJ3Vtd1z40MlC0MzXu > span')?.text.trim();

    // Key Features
    final keyFeatures = document
        .querySelectorAll('ul._1uI3IvdF5sIuBtRIvKrreQ > li')
        .map((e) => e.text.trim())
        .toList();
    property['keyFeatures'] = keyFeatures;

    // Property Type
    property['type'] = getPropertyData("PROPERTY TYPE");

    // Bedrooms
    property['bedrooms'] = getPropertyData("BEDROOMS");

    // Bathrooms
    property['bathrooms'] = getPropertyData("BATHROOMS");

    // Size
    property['sqft'] = getPropertyData("SIZE");

    // Description
    property['description'] =
        document.querySelector('._3nPVwR0HZYQah5tkVJHFh5 > div')?.text.trim();

    return property;
  } else {
    throw Exception('Failed to load Rightmove property page');
  }
}

// Helper function to extract numeric values from key features (or other lists)
int? _extractNumberFromKeyFeatures(List<String> features, RegExp regex) {
  for (final feature in features) {
    final match = regex.firstMatch(feature);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
  }
  return null;
}
