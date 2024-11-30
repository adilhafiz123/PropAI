import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:my_flutter_application/Screens/mapViewScreen.dart';
import 'package:my_flutter_application/LLMs/gemini.dart';
import 'package:my_flutter_application/Scraper/rightmoveScraper.dart';
import 'package:my_flutter_application/Scraper/rightmoveScraperUrls.dart';
import 'package:my_flutter_application/Scraper/rightmoveOutcodeMapping.dart';
import 'package:my_flutter_application/Firebase/firebase.dart';
import 'package:my_flutter_application/Classes/ListingClass.dart';
import "summaryScreen.dart";

class ListScreen extends StatefulWidget {
  const ListScreen(this.isSale, this.postcode, {super.key});

  final bool isSale;
  final String postcode;

  @override
  State<ListScreen> createState() => _ListScreenState(isSale, postcode);
}

class _ListScreenState extends State<ListScreen> {
  _ListScreenState(this.isSale, this.postcode);

  final String postcode;
  final bool isSale;
  bool mapViewButtonEnabled = false;
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

    if (postcode == "firebase") {
      return await DatabaseService().getAllProperties();
    }

    var outcode = postcode.split(' ')[0].toUpperCase();
    var outcodeMap = buildOutcodeMap();
    var code = outcodeMap[outcode];
    var saleOrRentString = isSale ? "property-for-sale" : "property-to-rent";
    var topLevelUrl =
        "https://www.rightmove.co.uk/$saleOrRentString/find.html?locationIdentifier=OUTCODE%5E$code&numberOfPropertiesPerPage=24&sortType=6&radius=0.0&index=0&includeSSTC=false&viewType=LIST&channel=BUY&areaSizeUnit=sqft&currencyCode=GBP&isFetching=false&searchLocation=$outcode&useLocationIdentifier=true&previousSearchLocation=null";
    final urlsAndIds =
        (await getListOfUrlsAndIds(topLevelUrl)).toSet().toList();

    ////////////////////////////////////////////////////////////////////////////
    const howManyProperties = 1;
    ////////////////////////////////////////////////////////////////////////////

    var model = createGeminiModel(); //Only do if >1 propFromGemini
    ChatSession chat = await startGeminiChat(model);
    /*int setupTokenCount = */ await setupGeminiChat(chat, model);
    String geminiAreaSummary = await sendGeminiText(chat,
        "Tell me what I need to know about the $postcode area if I am considering moving there");
    var rng = Random();
    for (int i = 0; i < howManyProperties; i++) {
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
            await buildListingFromGemini(chat, property, geminiAreaSummary);
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
          backgroundColor: const Color.fromARGB(255, 9, 53, 90),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: SizedBox(
          width: 180,
          child: FloatingActionButton(
              backgroundColor: const Color.fromARGB(255, 9, 63, 66),
              foregroundColor: Colors.white,
              onPressed: () => mapViewButtonEnabled
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MapView(listings)))
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
              mapViewButtonEnabled = false;
              return const Center(
                  child: CircularProgressIndicator(
                color: Color.fromARGB(255, 9, 63, 66),
              )); // Loading indicator
            }
            if (snapshot.hasError) {
              return Text(
                  'Error: ${snapshot.error}\n\nStack Trace:\n${snapshot.stackTrace}'); // Handle error
            }

            listings = snapshot.data!;
            mapViewButtonEnabled = true;
            return ListView.builder(
                itemCount: listings.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: 6, top: 6, left: 8),
                      child: Text(
                        "${listings.length} results",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                  final listing = listings[index - 1];

                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ListingScreen(listing)),
                      ),
                      child: buildCard(listing),
                    ),
                  );
                });
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.only(topLeft: Radius.circular(6)),
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
            padding: const EdgeInsets.only(left: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    for (int i = 0; i < listing.rating; i++)
                      const Image(
                        image: AssetImage("assets/spark.png"),
                        height: 22,
                        width: 22,
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
                const Divider(
                  height: 12,
                ),
                Text(
                  listing.headline,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 140, child: Text(listing.address)),
                const SizedBox(
                  height: 16,
                ),
                const Wrap(
                  spacing: 22,
                  children: [
                    Icon(Icons.send_rounded),
                    Icon(Icons.phone),
                    Icon(Icons.favorite_border_outlined)
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
