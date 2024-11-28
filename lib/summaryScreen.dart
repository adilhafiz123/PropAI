import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
//import 'package:url_launcher/url_launcher.dart';
import 'package:my_flutter_application/ListingClass.dart';

class ListingScreen extends StatefulWidget {
  const ListingScreen(this.listing, {super.key});

  final Listing listing;

  @override
  State<ListingScreen> createState() => _ListingScreenState();
}

class _ListingScreenState extends State<ListingScreen> {
  final List<File> _images = [];

  late PageController pageViewController;

  IconData heartIcon = Icons.favorite_outline;
  Color heartColor = Colors.black;

  @override
  void initState() {
    super.initState();
    pageViewController = PageController();
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

  Widget buildImageWidget(String filename) {
    return ClipRRect(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        child: Image.network(filename));
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
          backgroundColor: const Color.fromARGB(255, 9, 53, 90),
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
                        children: [
                          for (int i = 0;
                              i < widget.listing.imagePaths.length;
                              i++)
                            buildImageWidget(widget.listing.imagePaths[i]),
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
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Wrap(
                  alignment: WrapAlignment.spaceAround,
                  children: [
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
                    SizedBox(
                      width: 110,
                      child: Row(
                        children: [
                          for (int i = 0; i < widget.listing.rating; i++)
                            const Image(
                              image: AssetImage("assets/spark.png"),
                              height: 22,
                              width: 22,
                            )
                        ],
                      ),
                    )
                  ],
                ),

                const SizedBox(
                  height: 16,
                ),
                Wrap(
                  alignment: WrapAlignment.spaceAround,
                  children: [
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
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
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
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 120,
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
                            style: const TextStyle(fontSize: 16),
                          )
                        ],
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
                              buildImageWidget(widget.listing.imagePaths[i]),
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
