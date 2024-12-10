import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:my_flutter_application/Classes/FilterClass.dart';
import 'package:my_flutter_application/Screens/mapViewScreen.dart';
import 'package:my_flutter_application/LLMs/gemini.dart';
import 'package:my_flutter_application/Scraper/rightmoveScraper.dart';
import 'package:my_flutter_application/Scraper/rightmoveScraperUrls.dart';
import 'package:my_flutter_application/Scraper/rightmoveOutcodeMapping.dart';
import 'package:my_flutter_application/Firebase/firebase.dart';
import 'package:my_flutter_application/Classes/ListingClass.dart';
import 'package:my_flutter_application/helperFunctions.dart';
import "summaryScreen.dart";

class ListScreen extends StatefulWidget {
  const ListScreen(this.isSale, this.postcode, this.filter, {super.key});

  final bool isSale;
  final String postcode;
  final Filter filter;

  @override
  State<ListScreen> createState() => _ListScreenState(isSale, postcode);
}

class _ListScreenState extends State<ListScreen> {
  _ListScreenState(this.isSale, this.postcode);

  final String postcode;
  final bool isSale;
  dynamic mapViewButtonEnabled;
  String topLevelUrl = "";
  int setupTokens = 0;
  Future<List<Listing>>? _futureListings;
  List<Listing> listings = List.empty(growable: true);
  List<String> addresses = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    _futureListings = buildListingsAsync(postcode);
  }

  Future<List<Listing>> buildListingsAsync(String postcode) async {
    List<Listing> listings = List.empty(growable: true);

    // Cheat codes
    if (postcode == "firebase") {
      return await DatabaseService().getAllProperties();
    }

    var model = createGeminiModel(); //Only do if >1 propFromGemini
    ChatSession chat = await startGeminiChat(model);
    /*int setupTokenCount = */ await setupGeminiChat(chat, model);

    // Test Code: Remove me
    if (postcode.length == 9) {
      final property = await scrapeRightmoveProperty(
          "https://www.rightmove.co.uk/properties/$postcode#/?channel=RES_BUY");
      Future<Listing> listingFuture =
          buildListingFromGemini(chat, property, "areaSummary");
      var list = List<Future<Listing>>.empty(growable: true);
      list.add(listingFuture);
      return Future.wait(list);
    }

    var outcode = extractOutcode(postcode);
    var outcodeMap = buildOutcodeMap();
    var code = outcodeMap[outcode];
    var saleOrRentString = isSale ? "property-for-sale" : "property-to-rent";
    var topLevelUrl =
        "https://www.rightmove.co.uk/$saleOrRentString/find.html?locationIdentifier=OUTCODE%5E$code&radius=${widget.filter.searchRadii[widget.filter.searchRadius]}&minPrice=${widget.filter.minPrices[widget.filter.minPrice]}&maxPrice=${widget.filter.maxPrices[widget.filter.maxPrice]}&minBedrooms=${widget.filter.minBedrooms[widget.filter.bedroomsMin]}&maxBedrooms=${widget.filter.maxBedrooms[widget.filter.bedroomsMax]}&propertyTypes=${widget.filter.propertyTypes[widget.filter.propertyType]}&numberOfPropertiesPerPage=24&sortType=6&radius=0.0&index=0&includeSSTC=false&viewType=LIST&channel=BUY&areaSizeUnit=sqft&currencyCode=GBP&isFetching=false&searchLocation=$outcode&useLocationIdentifier=true&previousSearchLocation=null";
    final urlsAndIds =
        (await getListOfUrlsAndIds(topLevelUrl)).toSet().toList();
    if (urlsAndIds.isEmpty) return List.empty();
    ////////////////////////////////////////////////////////////////////////////
    const howManyProperties = 6;
    ////////////////////////////////////////////////////////////////////////////

    String? areaSummary = await DatabaseService().getAreaSummary(outcode);
    areaSummary ??= await sendGeminiText(chat,
        "Tell me what I need to know about the $postcode UK postcode area if I am considering moving there. Also include crime level without providing the police link");
    DatabaseService().updateAreaSummary(outcode, areaSummary);

    var rng = Random();
    for (int i = 0; i < min(howManyProperties, urlsAndIds[0].length); i++) {
      var url = urlsAndIds[0][
          i]; //https://www.rightmove.co.uk/properties/154985657#/?channel=RES_LET";
      var id = urlsAndIds[1][i]; //"154985657"

      var listing = await DatabaseService().getProperty(id);
      if (listing != null) {
        listings.add(listing);
      } else {
        final ms = rng.nextInt(3000);
        sleep(Duration(milliseconds: ms));
        final property = await scrapeRightmoveProperty(url);
        addresses.add(property["address"]);
        Listing listing =
            await buildListingFromGemini(chat, property, areaSummary);
        listings.add(listing);
        DatabaseService().updateProperty(listing);
      }
    }
    return listings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromRGBO(253, 253, 253, 1),
        appBar: AppBar(
          title: const Text(
            "Results",
          ),
          centerTitle: true,
          foregroundColor: Colors.white,
          backgroundColor: const Color.fromARGB(255, 14, 40, 60),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: SizedBox(
          width: 180,
          child: FloatingActionButton(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(30.0), // Adjust the radius as needed
              ),
              backgroundColor: const Color.fromARGB(255, 60, 120, 140),
              foregroundColor: Colors.white,
              onPressed: () => mapViewButtonEnabled
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MapView(listings, true)))
                  : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/pin.png",
                      color: Colors.white, height: 28),
                  const SizedBox(
                    width: 8,
                  ),
                  const Text(
                    "Map View",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ],
              )),
        ),
        body: FutureBuilder<List<Listing>>(
          future: _futureListings,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      "Loading properties...",
                      style: TextStyle(
                          fontFamily: "Nunito",
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Center(
                      child: CircularProgressIndicator(
                    color: Color.fromARGB(255, 9, 63, 66),
                  )),
                ],
              );
            }
            if (snapshot.hasError) {
              return Text(
                  'Error: ${snapshot.error}\n\nStack Trace:\n${snapshot.stackTrace}'); // Handle error
            }

            listings = snapshot.data!;
            mapViewButtonEnabled = true;

            return Column(
              children: [
                if (listings.isEmpty)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 40,
                      ),
                      const Text(
                        "No Results!",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Center(
                        child: Image.asset(
                          "assets/sad.png",
                          width: 150,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      SizedBox(
                        width: 150,
                        child: FloatingActionButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  6.0), // Adjust the radius as needed
                            ),
                            backgroundColor:
                                const Color.fromARGB(255, 60, 120, 140),
                            foregroundColor: Colors.white,
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "Refine Search",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            )),
                      ),
                    ],
                  ),
                // ListView with results
                if (listings.isNotEmpty)
                  Expanded(
                    flex: 3,
                    child: ListView.builder(
                      itemCount: listings.length + 2,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                bottom: 6, top: 6, left: 8),
                            child: Row(
                              children: [
                                Text(
                                  "${listings.length} results",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 250),
                                GestureDetector(
                                  child: const Icon(
                                    Icons.sort,
                                    size: 24,
                                  ),
                                  onTap: () {
                                    setState(() {
                                      // Sort listings by rating in descending order
                                      listings.sort((a, b) =>
                                          b.rating.compareTo(a.rating));
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        }

                        if (index > 0 && index < listings.length + 1) {
                          final listing = listings[index - 1];
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ListingScreen(listing),
                                ),
                              ),
                              child: buildCard(listing),
                            ),
                          );
                        }
                        // Space at the end to not hide behind the Map View button
                        if (index == listings.length + 1) {
                          return const SizedBox(height: 80);
                        }
                        return null;
                      },
                    ),
                  ),
              ],
            );
          },
        ));
  }
}

Widget buildCard(Listing listing) {
  return SizedBox(
    height: 165,
    child: Card(
      elevation: 5,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.only(topLeft: Radius.circular(5)),
                child: SizedBox(
                    width: 177,
                    height: 120,
                    child: FittedBox(
                        fit: BoxFit.cover,
                        clipBehavior: Clip.hardEdge,
                        child: Image.network(listing.imagePaths[0]))),
              ),
              ClipRRect(
                  borderRadius:
                      const BorderRadius.only(bottomLeft: Radius.circular(6)),
                  child: Container(
                      width: 177,
                      color: const Color.fromRGBO(242, 243, 245, 1),
                      child: Center(
                          child: Text(listing.price,
                              style: const TextStyle(
                                  fontSize: 26,
                                  color: Color.fromRGBO(83, 83, 95, 1),
                                  fontWeight: FontWeight.w500))))),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 4,
                ),
                Row(
                  children: [
                    for (int i = 1; i < listing.rating; i++)
                      const Row(
                        children: [
                          Image(
                            image: AssetImage("assets/black.png"),
                            height: 16,
                            width: 16,
                          ),
                          SizedBox(
                            width: 3,
                          ),
                        ],
                      ),
                    if (listing.rating - listing.rating.floor() > 0)
                      const Image(
                        image: AssetImage("assets/half_star.png"),
                        height: 18,
                        width: 18,
                      ),
                    const SizedBox(
                      width: 8,
                    ),
                    SizedBox(
                        height: 20,
                        child: listing.fromFirebase
                            ? Image.asset("assets/firebase.png")
                            : Image.asset("assets/gemini.png")),
                    // Container(
                    //   width: 27.0,
                    //   height: 27.0,
                    //   decoration: BoxDecoration(
                    //     color: Colors.transparent,
                    //     shape: BoxShape.circle,
                    //     border: Border.all(
                    //       color: Colors.blue,
                    //       width: 2.0,
                    //       style: BorderStyle.solid,
                    //     ),
                    //   ),
                    //   child: Center(
                    //       child: Text(
                    //     listing.inputTokenCount.toString(),
                    //     style: const TextStyle(
                    //         fontSize: 9, fontWeight: FontWeight.bold),
                    //   )),
                    // ),
                    // Container(
                    //   width: 27.0,
                    //   height: 27.0,
                    //   decoration: BoxDecoration(
                    //     color: Colors.transparent,
                    //     shape: BoxShape.circle,
                    //     border: Border.all(
                    //       color: Colors.yellow,
                    //       width: 2.0,
                    //       style: BorderStyle.solid,
                    //     ),
                    //   ),
                    //   child: Center(
                    //       child: Text(
                    //     listing.outputTokenCount.toString(),
                    //     style: const TextStyle(
                    //         fontSize: 9, fontWeight: FontWeight.bold),
                    //   )),
                    // ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: 155,
                  child: Text(
                    listing.headline,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 140, height: 65, child: Text(listing.address)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const SizedBox(width: 20),
                    SizedBox(width: 21, child: Image.asset("assets/share.png")),
                    const SizedBox(width: 55),
                    // SizedBox(
                    //     width: 20, child: Image.asset("assets/telephone.png")),
                    // const SizedBox(width: 30),
                    SizedBox(width: 22, child: Image.asset("assets/heart.png")),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    ),
  );
}
