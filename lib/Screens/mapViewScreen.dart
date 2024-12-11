import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:my_flutter_application/Screens/listViewScreen.dart';
import 'package:my_flutter_application/Classes/ListingClass.dart';
import 'package:my_flutter_application/Screens/summaryScreen.dart';

class MapView extends StatefulWidget {
  const MapView(this.listings, this.showListViewButton, {super.key});

  final List<Listing> listings;
  final bool showListViewButton;

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late GoogleMapController mapController;

  late (Listing, Location?) selectedListing;
  List<Future<List<Location>>> futureLocationsList = List.empty(growable: true);
  List<Future<Uint8List>> futureImages = List.empty(growable: true);

  @override
  void initState() {
    for (int i = 0; i < widget.listings.length; i++) {
      futureLocationsList.add(
          locationFromAddress("${widget.listings[i].address}, United Kingdom"));
    }
    selectedListing = (widget.listings[0], null);

    futureImages.add(getBytesFromAsset2("assets/pin_black.png", 40));
    futureImages.add(getBytesFromAsset2("assets/pin_green.png", 40));
    futureImages.add(getBytesFromAsset2("assets/pin_amber_green.png", 40));
    futureImages.add(getBytesFromAsset2("assets/pin_amber.png", 40));
    futureImages.add(getBytesFromAsset2("assets/pin_amber_red.png", 40));
    futureImages.add(getBytesFromAsset2("assets/pin_red.png", 40));

    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<Uint8List> getBytesFromAsset2(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    Codec codec = await instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(253, 253, 253, 1),
      appBar: AppBar(
        title: const Text(
          "Map View",
        ),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 9, 53, 90),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: 180,
        child: (!widget.showListViewButton)
            ? null
            : FloatingActionButton(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      30.0), // Adjust the radius as needed
                ),
                backgroundColor: const Color.fromARGB(255, 60, 120, 140),
                foregroundColor: Colors.white,
                onPressed: () => Navigator.pop(context),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.list_rounded),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      "List View",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ],
                )),
      ),
      body: FutureBuilder(
        future: Future.wait(futureLocationsList),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      "Loading map...",
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
                    ),
                  )
                ]); // Loading indicator
          }
          if (snapshot.hasError) {
            return Text(
                'Error: ${snapshot.error}\n\nStack Trace:\n${snapshot.stackTrace}'); // Handle error
          }
          final locations = snapshot.data as List<List<Location>>;

          return FutureBuilder(
              future: Future.wait(futureImages),
              builder: (context, AsyncSnapshot<List<dynamic>> snapshotImages) {
                if (snapshotImages.connectionState != ConnectionState.done) {
                  return const SizedBox();
                }

                var blackBitmapDiscriptor =
                    BitmapDescriptor.bytes(snapshotImages.data?[0]);
                var greenBitmapDiscriptor =
                    BitmapDescriptor.bytes(snapshotImages.data?[1]);
                var amberGreenBitmapDiscriptor =
                    BitmapDescriptor.bytes(snapshotImages.data?[2]);
                var amberBitmapDiscriptor =
                    BitmapDescriptor.bytes(snapshotImages.data?[3]);
                var amberRedBitmapDiscriptor =
                    BitmapDescriptor.bytes(snapshotImages.data?[4]);
                var redBitmapDiscriptor =
                    BitmapDescriptor.bytes(snapshotImages.data?[5]);

                final markers = <Marker>{};
                for (int i = 0; i < locations.length; i++) {
                  markers.add(Marker(
                      markerId: MarkerId(widget.listings[i].id),
                      icon: widget.listings[i] == selectedListing
                          ? blackBitmapDiscriptor
                          : widget.listings[i].rating > 4
                              ? greenBitmapDiscriptor
                              : widget.listings[i].rating > 3
                                  ? amberGreenBitmapDiscriptor
                                  : widget.listings[i].rating > 2
                                      ? amberBitmapDiscriptor
                                      : widget.listings[i].rating > 1
                                          ? amberRedBitmapDiscriptor
                                          : redBitmapDiscriptor,
                      position: LatLng(
                          locations[i][0].latitude, locations[i][0].longitude),
                      onTap: () {
                        setState(() => selectedListing =
                            (widget.listings[i], locations[i][0]));
                      }));
                }

                double averageLat = 0.0;
                double averageLng = 0.0;

                for (Marker marker in markers) {
                  averageLat += marker.position.latitude;
                  averageLng += marker.position.longitude;
                }
                LatLng approximateCenter = LatLng(
                  averageLat / markers.length,
                  averageLng / markers.length,
                );

                return Stack(children: [
                  GoogleMap(
                    onMapCreated: _onMapCreated,
                    zoomControlsEnabled: false,
                    initialCameraPosition: CameraPosition(
                      target: selectedListing.$2 == null
                          ? approximateCenter
                          : LatLng(selectedListing.$2!.latitude,
                              selectedListing.$2!.longitude),
                      zoom: 14.0,
                    ),
                    markers: markers,
                  ),
                  Align(
                      alignment: const Alignment(0.5, 0.7),
                      child: GestureDetector(
                        child: buildCard(selectedListing.$1),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ListingScreen(selectedListing.$1)),
                        ),
                      )),
                ]);
              });
        },
      ),
    );
  }
}
