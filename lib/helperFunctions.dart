import 'package:flutter/material.dart';
import 'package:my_flutter_application/Screens/imageViewerScreen.dart';

Widget buildImageWidget(String filename, bool onTouch, BoxFit boxfit,
    BuildContext context, List<String> imagePaths) {
  return GestureDetector(
    onTap: () => !onTouch
        ? null
        : Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ImageViewerScreen(imagePaths)),
          ),
    child: ClipRRect(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        child: FittedBox(
            fit: boxfit,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(width: 352, child: Image.network(filename)))),
  );
}

String extractOutcode(String postcode) {
  // Remove any spaces and convert to uppercase
  String cleanedPostcode = postcode.replaceAll(' ', '').toUpperCase();

  // Regular expressions to match full postcodes and outcodes
  RegExp fullPostcodeRegex = RegExp(r'^([A-Z]{1,2}\d[A-Z\d]?)\d[A-Z]{2}$');
  RegExp outcodeRegex = RegExp(r'^[A-Z]{1,2}\d[A-Z\d]?$');

  // Check if it's a full postcode first
  Match? fullMatch = fullPostcodeRegex.firstMatch(cleanedPostcode);
  if (fullMatch != null) {
    return fullMatch.group(1)!.toUpperCase();
  }

  // If not a full postcode, check if it's a valid outcode
  if (outcodeRegex.hasMatch(cleanedPostcode)) {
    return cleanedPostcode.toUpperCase();
  }

  // Return empty string for invalid input
  return '';
}

String inferFloorplanUrlFromThumnailUrk(String? url) {
  if (url == null) return "";
  // Regular expression to match and remove the "_max_XXXxXXX" part
  RegExp maxResolutionRegex = RegExp(r'(_max_\d+x\d+)(\.[^.]+)$');

  return url.replaceFirstMapped(maxResolutionRegex, (match) {
    // Return the original filename without the max resolution part
    return match.group(2) ?? '';
  });
}
