import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:my_flutter_application/mapViewScreen.dart';
import 'package:my_flutter_application/model.dart';
import 'package:my_flutter_application/scraperProperty.dart';
import 'package:my_flutter_application/scraperUrls.dart';
import 'package:my_flutter_application/outcodeMapping.dart';
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
    var outcode = postcode.split(' ')[0].toUpperCase();
    var outcodeMap = buildOutcodeMap();
    var code = outcodeMap[outcode];
    var saleOrRentString = isSale ? "property-for-sale" : "property-to-rent";
    var topLevelUrl =
        "https://www.rightmove.co.uk/$saleOrRentString/find.html?locationIdentifier=OUTCODE%5E$code&numberOfPropertiesPerPage=24&sortType=6&radius=0.0&index=0&includeSSTC=false&viewType=LIST&channel=BUY&areaSizeUnit=sqft&currencyCode=GBP&isFetching=false&searchLocation=$outcode&useLocationIdentifier=true&previousSearchLocation=null";
    final propertyLinks = (await getListOfUrls(topLevelUrl)).toSet().toList();

    var rng = Random();

    ////////////////////////////////////////////////////////////////////////////
    const howManyProperties = 4;
    ////////////////////////////////////////////////////////////////////////////

    List<Listing> listings = List.empty(growable: true);

    var model = createGeminiModel();
    ChatSession chat = await startGeminiChat(model);
    int setupTokenCount = await setupGeminiChat(chat, model);
    for (int i = 0; i < howManyProperties; i++) {
      final ms = rng.nextInt(3000);
      sleep(Duration(milliseconds: ms));
      final property = await scrapeRightmoveProperty(propertyLinks[i]);
      addresses.add(property["address"]);
      Listing listing = await buildListing(chat, property);
      listings.add(listing);
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
                itemCount: listings.length,
                itemBuilder: (BuildContext context, int index) {
                  final listing = listings[index];

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
