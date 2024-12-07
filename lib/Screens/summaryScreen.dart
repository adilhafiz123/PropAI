import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_flutter_application/Screens/mapViewScreen.dart';
import 'package:my_flutter_application/helperFunctions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:my_flutter_application/Classes/ListingClass.dart';

class ListingScreen extends StatefulWidget {
  const ListingScreen(this.listing, {super.key});

  final Listing listing;

  @override
  State<ListingScreen> createState() => _ListingScreenState();
}

class _ListingScreenState extends State<ListingScreen> {
  final List<File> _images = [];

  late PageController pageViewController;
  late GoogleMapController mapController;
  late Future<List<Location>> futureLocation;
  IconData heartIcon = Icons.favorite_outline;
  Color heartColor = Colors.black;

  @override
  void initState() {
    super.initState();
    futureLocation =
        locationFromAddress("${widget.listing.address}, United Kingdom");
    pageViewController = PageController();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void dispose() {
    super.dispose();
    pageViewController.dispose();
  }

  Future<void> loadImages(folderPath) async {
    final directory = Directory(folderPath);
    final List<FileSystemEntity> entities = directory.listSync();

    for (final entity in entities) {
      if (entity is File && entity.path.endsWith('.jpg') ||
          entity.path.endsWith('.png')) {
        _images.add(entity as File);
      }
    }
  }

  Widget buildFloorPlanDialog(path) {
    return Dialog(
      insetPadding: const EdgeInsets.all(10),
      child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: InteractiveViewer(child: Image.network(path))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          title: const Text(
            "Summary",
          ),
          centerTitle: true,
          foregroundColor: Colors.white,
          backgroundColor: const Color.fromARGB(255, 14, 40, 60),
        ),
        body: PageView(controller: pageViewController, children: [
          Card(
            color: Colors.grey[10],
            child: ListView(
              children: [
                Stack(children: [
                  SizedBox(
                      height: 300,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const PageScrollPhysics(),
                        children: [
                          for (int i = 0;
                              i < widget.listing.imagePaths.length;
                              i++)
                            buildImageWidget(widget.listing.imagePaths[i], true,
                                context, widget.listing.imagePaths),
                        ],
                      )),
                  Align(
                      alignment: Alignment.center,
                      child: Image.asset(
                        "assets/more.png",
                        width: 30,
                        color: Colors.white,
                      ))
                ]),
                Wrap(
                  alignment: WrapAlignment.spaceAround,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      widget.listing.price,
                      style: const TextStyle(fontSize: 36),
                    ),
                    Image.asset("assets/share.png"),
                    GestureDetector(
                      child: Icon(
                        size: 31,
                        heartIcon,
                        color: heartColor,
                      ),
                      onTap: () => {
                        setState(() {
                          heartIcon = heartIcon == Icons.favorite_outline
                              ? Icons.favorite
                              : Icons.favorite_outline;
                          heartColor = heartColor == Colors.black
                              ? Colors.red
                              : Colors.black;
                        })
                      },
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Text(
                    widget.listing.headline,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Text(
                    widget.listing.address,
                    style: const TextStyle(fontSize: 17),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    const SizedBox(width: 20),
                    SizedBox(
                      width: 120,
                      child: Row(
                        children: [
                          const Image(
                            image: AssetImage("assets/house_emoji.png"),
                            height: 22,
                            width: 22,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            widget.listing.type,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 75),
                    SizedBox(
                      width: 125,
                      child: Row(
                        children: [
                          for (int i = 0; i < widget.listing.rating; i++)
                            const Row(
                              children: [
                                Image(
                                  image: AssetImage("assets/star.png"),
                                  height: 22,
                                  width: 22,
                                ),
                                SizedBox(
                                  width: 3,
                                ),
                              ],
                            )
                        ],
                      ),
                    )
                  ],
                ),

                const SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 30,
                    ),
                    SizedBox(
                      width: 60,
                      child: Row(
                        children: [
                          const Image(
                            image: AssetImage("assets/bed_emoji.png"),
                            height: 30,
                            width: 30,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            widget.listing.beds == null
                                ? (widget.listing.type == "Studio" ? "0" : "?")
                                : widget.listing.beds.toString(),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    SizedBox(
                      width: 60,
                      child: Row(
                        children: [
                          const Image(
                            image: AssetImage("assets/bath_emoji.PNG"),
                            height: 25,
                            width: 25,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            widget.listing.baths == null
                                ? "?"
                                : widget.listing.baths.toString(),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    SizedBox(
                      width: 160,
                      child: OutlinedButton(
                        onPressed: () => widget.listing.floorplanPath == ""
                            ? null
                            : showDialog(
                                context: context,
                                builder: (context) => buildFloorPlanDialog(
                                    widget.listing.floorplanPath),
                              ),
                        child: Row(
                          children: [
                            const Image(
                              image: AssetImage("assets/floor.png"),
                              height: 25,
                              width: 25,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              widget.listing.sqft == null
                                  ? "?"
                                  : "${widget.listing.sqft}",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 36,
                ),
                const Row(
                  children: [
                    SizedBox(
                      width: 70,
                    ),
                    Image(
                      image: AssetImage("assets/sparkle.png"),
                      height: 40,
                      width: 40,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text("AI Summary",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(
                      width: 40,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MarkdownBody(
                      data: widget.listing.geminiSummary,
                      styleSheet: MarkdownStyleSheet.fromTheme(ThemeData(
                          textTheme: const TextTheme(
                              bodyMedium: TextStyle(
                                  fontSize: 15.0,
                                  fontFamily: "Nunito",
                                  fontWeight: FontWeight.w900))))),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: SizedBox(
                        height: 200,
                        width: 200,
                        child: FutureBuilder(
                            future: futureLocation,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState !=
                                  ConnectionState.done) {
                                return const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Center(
                                        child: Text(
                                          "Loading Map...",
                                          style:
                                              TextStyle(fontFamily: "Nunito"),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 30,
                                      ),
                                      Center(
                                        child: CircularProgressIndicator(
                                          color: Color.fromARGB(255, 9, 63, 66),
                                        ),
                                      )
                                    ]); // Loading indicator
                              }
                              if (snapshot.hasError) {
                                return Text(
                                    'Error: ${snapshot.error}\n\nStack Trace:\n${snapshot.stackTrace}'); // Handle error
                              }
                              final location = snapshot.data?[0] as Location;
                              final latLng =
                                  LatLng(location.latitude, location.longitude);
                              return GoogleMap(
                                onTap: (argument) => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            MapView([widget.listing], false))),
                                onMapCreated: _onMapCreated,
                                zoomControlsEnabled: false,
                                initialCameraPosition: CameraPosition(
                                  target: latLng,
                                  zoom: 14.0,
                                ),
                                markers: {
                                  Marker(
                                    markerId: MarkerId(widget.listing.id),
                                    position: latLng,
                                  )
                                },
                              );
                            })),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                OutlinedButton(
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 80,
                      ),
                      SizedBox(
                        height: 25,
                        child: Image.asset(
                          "assets/neighborhood.png",
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text("About the area",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Row(
                                children: [
                                  const SizedBox(width: 35),
                                  Image.asset("assets/neighborhood.png"),
                                  const SizedBox(width: 15),
                                  const Text(
                                    "Area Summary",
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              scrollable: true,
                              content: MarkdownBody(
                                  data: widget.listing.geminiAreaSummary),
                              insetPadding: const EdgeInsets.only(
                                  right: 10, left: 10, top: 20, bottom: 60),
                            ));
                  },
                ),
                OutlinedButton(
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 60,
                        ),
                        SizedBox(
                            height: 25,
                            child: Image.asset("assets/rightmove.png")),
                        const SizedBox(
                          width: 10,
                        ),
                        const Text("View on Rightmove",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(
                          width: 15,
                        ),
                      ],
                    ),
                    onPressed: () async =>
                        await launchUrl(Uri.parse(widget.listing.url))),
                const SizedBox(
                  height: 20,
                ),
                // SelectableText(
                //   widget.listing.url,
                //   style: const TextStyle(
                //       fontFamily: "Nunito",
                //       fontWeight: FontWeight.w900,
                //       color: Colors.blue),
                // )
                //InkWell(
                //child: Text(widget.listing.url),
                //onTap: () => launchUrl(Uri.parse(widget.listing.url))
                //),
              ],
            ),
          ),
          Card(
              color: Colors.grey[10],
              child: ListView(
                children: [
                  Stack(children: [
                    SizedBox(
                        height: 300,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            for (int i = 0;
                                i < widget.listing.imagePaths.length;
                                i++)
                              buildImageWidget(widget.listing.imagePaths[i],
                                  true, context, widget.listing.imagePaths),
                          ],
                        )),
                    Align(
                        alignment: Alignment.center,
                        child: Image.asset(
                          "assets/more.png",
                          width: 30,
                          color: Colors.white,
                        ))
                  ]),
                  Wrap(
                    alignment: WrapAlignment.spaceAround,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        widget.listing.price,
                        style: const TextStyle(fontSize: 36),
                      ),
                      const Icon(Icons.share_outlined),
                      GestureDetector(
                        child: Icon(
                          heartIcon,
                          color: heartColor,
                        ),
                        onTap: () => {
                          setState(() {
                            heartIcon = heartIcon == Icons.favorite_outline
                                ? Icons.favorite
                                : Icons.favorite_outline;
                            heartColor = heartColor == Colors.black
                                ? Colors.red
                                : Colors.black;
                          })
                        },
                      )
                    ],
                  ),
                  const Center(
                      child: Text(
                    "Original Description",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                  )),
                  for (int i = 0; i < widget.listing.keyFeatures.length; i++)
                    Text("- ${widget.listing.keyFeatures[i]}"),

                  const SizedBox(
                    height: 30,
                  ),
                  Text(widget.listing.description),
                  const SizedBox(
                    height: 30,
                  ),
                  // InkWell(
                  //     child: Text("Listing URL: ${widget.listing.url}"),
                  //     onTap: () => launchUrl(Uri.parse(widget.listing.url))
                  //   ),
                ],
              ))
        ]));
  }
}
