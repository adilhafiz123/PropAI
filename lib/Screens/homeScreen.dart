import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_flutter_application/Classes/FilterClass.dart';
import 'package:my_flutter_application/Screens/listViewScreen.dart';
import 'package:my_flutter_application/Firebase/firebase_options.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      fontFamily: "FigTree",
      inputDecorationTheme: const InputDecorationTheme(
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(255, 220, 220, 220)),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(255, 220, 220, 220)),
        ),
      ),
    ),
    home: const Home(),
    navigatorKey: navigatorKey,
  ));
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final myController = TextEditingController();
  Filter filter = Filter();

  @override
  void initState() {
    super.initState();
    myController.text = "E14";
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          "Adil's App",
        ),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 14, 40, 60),
      ),
      body: Column(children: [
        const SizedBox(height: 20),
        const Center(
            child: Text("Enter Postcode",
                style: TextStyle(
                  color: Color.fromARGB(255, 14, 60, 40),
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ))),
        Padding(
          padding: const EdgeInsets.all(10),
          child: TextField(
              controller: myController,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              decoration: const InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                hintText: 'Enter postcode',
              )),
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        30.0), // Adjust the radius as needed
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ListScreen(true, myController.text, filter)),
                    );
                  },
                  backgroundColor: const Color.fromARGB(255, 60, 120, 140),
                  child: const Text(
                    "For Sale",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        30.0), // Adjust the radius as needed
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ListScreen(false, myController.text, filter)),
                    );
                  },
                  backgroundColor: const Color.fromARGB(255, 60, 120, 140),
                  child: const Text(
                    "To Rent",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
            padding: const EdgeInsets.all(2.0),
            child: Column(children: [
              // Search Radius Dropdown
              const Row(children: [
                SizedBox(width: 10),
                Text("Search radius",
                    style: TextStyle(
                        fontSize: 15, color: Color.fromARGB(255, 87, 87, 87)))
              ]),
              SizedBox(
                height: 60,
                width: 335,
                child: DropdownButtonFormField<String>(
                  value: filter.searchRadius,
                  items: filter.searchRadii.keys.map((value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      filter.searchRadius = value!;
                    });
                  },
                ),
              ),

              // Bedrooms Dropdown
              const Row(children: [
                SizedBox(width: 10),
                Text("Bedrooms",
                    style: TextStyle(
                        fontSize: 15, color: Color.fromARGB(255, 87, 87, 87)))
              ]),
              Row(
                children: [
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 60,
                    width: 155,
                    child: DropdownButtonFormField<String>(
                      value: filter.bedroomsMin,
                      items: filter.minBedrooms.keys.map((value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          filter.bedroomsMin = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    height: 60,
                    width: 155,
                    child: DropdownButtonFormField<String>(
                      value: filter.bedroomsMax,
                      items: filter.maxBedrooms.keys.map((value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          filter.bedroomsMax = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),

              // Price Range Dropdown
              const Row(children: [
                SizedBox(width: 10),
                Text("Price range",
                    style: TextStyle(
                        fontSize: 15, color: Color.fromARGB(255, 87, 87, 87)))
              ]),
              Row(
                children: [
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 60,
                    width: 155,
                    child: DropdownButtonFormField<String>(
                      value: filter.minPrice,
                      items: filter.minPrices.keys.map((value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          filter.minPrice = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    height: 60,
                    width: 155,
                    child: DropdownButtonFormField<String>(
                      value: filter.maxPrice,
                      items: filter.maxPrices.keys.map((value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          filter.maxPrice = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              // // Bathrooms Dropdown
              // const Row(children: [
              //   SizedBox(width: 10),
              //   Text("Bathrooms",
              //       style: TextStyle(color: Color.fromARGB(255, 119, 119, 121)))
              // ]),
              // Row(
              //   children: [
              //     const SizedBox(width: 10),
              //     SizedBox(
              //       height: 60,
              //       width: 155,
              //       child: DropdownButtonFormField<String>(
              //         value: filter.bathroomsMin,
              //         items: ["1", "2", "3", "4", "5", "No min"].map((value) {
              //           return DropdownMenuItem<String>(
              //             value: value,
              //             child: Text(value,
              //                 style:
              //                     const TextStyle(fontWeight: FontWeight.w600)),
              //           );
              //         }).toList(),
              //         onChanged: (value) {
              //           setState(() {
              //             filter.bathroomsMin = value!;
              //           });
              //         },
              //       ),
              //     ),
              //     const SizedBox(width: 20),
              //     SizedBox(
              //       height: 60,
              //       width: 155,
              //       child: DropdownButtonFormField<String>(
              //         value: filter.bathroomsMax,
              //         items: ["1", "2", "3", "4", "5", "No max"].map((value) {
              //           return DropdownMenuItem<String>(
              //             value: value,
              //             child: Text(value,
              //                 style:
              //                     const TextStyle(fontWeight: FontWeight.w600)),
              //           );
              //         }).toList(),
              //         onChanged: (value) {
              //           setState(() {
              //             filter.bathroomsMax = value!;
              //           });
              //         },
              //       ),
              //     ),
              //   ],
              // ),

              // Property Type
              const Row(children: [
                SizedBox(width: 10),
                Text("Property Type",
                    style: TextStyle(
                        fontSize: 15, color: Color.fromARGB(255, 87, 87, 87)))
              ]),
              Row(
                children: [
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 60,
                    width: 326,
                    child: DropdownButtonFormField<String>(
                      value: filter.propertyType,
                      items: filter.propertyTypes.keys.map((value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          filter.propertyType = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
            ])),
        //Image.asset("assets/houses.png")
      ]),
    );
  }
}
