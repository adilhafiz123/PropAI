class Listing {
  String id;
  String url;
  bool fromFirebase;
  double rating;
  String headline;
  String description;
  List<String> keyFeatures;
  String address;
  String price;
  String type;
  String? beds;
  String? baths;
  String? sqft;
  List<String> imagePaths = List.empty();
  String geminiSummary;
  int inputTokenCount;
  int outputTokenCount;

  Listing(
      this.id,
      this.url,
      this.fromFirebase,
      this.rating,
      this.headline,
      this.address,
      this.description,
      this.keyFeatures,
      this.price,
      this.type,
      this.beds,
      this.baths,
      this.sqft,
      this.imagePaths,
      this.geminiSummary,
      this.inputTokenCount,
      this.outputTokenCount);
}
