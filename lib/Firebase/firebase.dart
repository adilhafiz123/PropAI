import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_flutter_application/Classes/ListingClass.dart';
import 'package:my_flutter_application/LLMs/gemini.dart';

class DatabaseService {
  final CollectionReference propCollection =
      FirebaseFirestore.instance.collection("properties");

  Future updateProperty(Listing listing) async {
    return await propCollection.doc(listing.id).set({
      'url': listing.url,
      'rating': listing.rating,
      'headline': listing.headline,
      'description': listing.description,
      'keyFeatures': listing.keyFeatures,
      'address': listing.address,
      'price': listing.price,
      'type': listing.type,
      'beds': listing.beds,
      'baths': listing.baths,
      'sqft': listing.sqft,
      'imagePaths': listing.imagePaths,
      'geminiSummary': listing.geminiSummary,
      'geminiAreaSummary': listing.geminiAreaSummary,
      'inputTokenCount': listing.inputTokenCount,
      'outputTokenCount': listing.outputTokenCount,
    });
  }

  Listing listingFromSnapshot(Map<String, dynamic> data, String id) {
    try {
      var listing = Listing(
        id,
        data['url'] ?? '',
        true,
        data['rating'] ?? 0.0,
        data['headline'] ?? '',
        data['address'] ?? '',
        data['description'] ?? '',
        data['keyFeatures'] is List
            ? List<String>.from(data['keyFeatures'])
            : [],
        data['price'] ?? 0.0,
        data['type'] ?? '',
        data['beds'] ?? 0,
        data['baths'] ?? 0,
        data['sqft'] ?? 0,
        data['imagePaths'] is List ? List<String>.from(data['imagePaths']) : [],
        data['geminiSummary'] ?? '',
        data['geminiAreaSummary'] ?? '',
        data['inputTokenCount'] ?? 0,
        data['outputTokenCount'] ?? 0,
      );
      return listing;
    } catch (e) {
      throw ('Error fetching documents: $e\n\nFor Document:$id');
    }
  }

  Future<Listing?> getProperty(String id) async {
    final docRef = FirebaseFirestore.instance.collection("properties").doc(id);
    final docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      var data = docSnapshot.data() as Map<String, dynamic>;
      return listingFromSnapshot(data, id);
    }
    return null;
  }

  Future<List<Listing>> getAllProperties() async {
    final collection = FirebaseFirestore.instance.collection('properties');

    try {
      final querySnapshot = await collection.get();
      List<Listing> listings = List.empty(growable: true);
      for (final doc in querySnapshot.docs) {
        if (doc.exists) {
          listings.add(listingFromSnapshot(doc.data(), doc.id));
        }
      }
      return listings;
    } catch (e) {
      throw ('Error fetching documents: $e');
    }
  }
}
