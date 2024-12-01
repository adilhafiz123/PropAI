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
