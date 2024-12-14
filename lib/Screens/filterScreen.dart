import 'package:flutter/material.dart';
import 'package:my_flutter_application/Classes/FilterClass.dart';
import 'package:my_flutter_application/Screens/listViewScreen.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => FilterScreenState();
}

class FilterScreenState extends State<FilterScreen> {
  final myController = TextEditingController();
  Filter filter = Filter();
  bool isForSaleSelected = true;
  bool isToRentSelected = false;

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
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 8.0, left: 8.0, bottom: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (!isForSaleSelected) {
                      setState(() {
                        isForSaleSelected = !isForSaleSelected;
                        isToRentSelected = false;
                      });
                    }
                  },
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.resolveWith<Color>(
                      (states) =>
                          isForSaleSelected ? Colors.white : Colors.black,
                    ),
                    backgroundColor: WidgetStateProperty.resolveWith<Color>(
                      (states) => isForSaleSelected
                          ? const Color.fromARGB(255, 14, 40, 60)
                          : Theme.of(context).scaffoldBackgroundColor,
                    ),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            topLeft: Radius.circular(30)),
                      ),
                    ),
                    side: WidgetStateProperty.resolveWith<BorderSide>(
                      (states) => isToRentSelected
                          ? const BorderSide(color: Colors.black)
                          : const BorderSide(color: Colors.transparent),
                    ),
                  ),
                  child: const SizedBox(
                    height: 55,
                    child: Center(
                      child: Text(
                        'For Sale',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 8.0, right: 8.0, bottom: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (isForSaleSelected) {
                      setState(() {
                        isToRentSelected = !isToRentSelected;
                        isForSaleSelected = false;
                      });
                    }
                  },
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.resolveWith<Color>(
                      (states) =>
                          isForSaleSelected ? Colors.black : Colors.white,
                    ),
                    backgroundColor: WidgetStateProperty.resolveWith<Color>(
                      (states) => isToRentSelected
                          ? const Color.fromARGB(255, 14, 40, 60)
                          : Theme.of(context).scaffoldBackgroundColor,
                    ),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(30),
                            bottomRight: Radius.circular(30)),
                      ),
                    ),
                    side: WidgetStateProperty.resolveWith<BorderSide>(
                      (states) => isToRentSelected
                          ? const BorderSide(color: Colors.transparent)
                          : const BorderSide(color: Colors.black),
                    ),
                  ),
                  child: const SizedBox(
                    height: 55,
                    child: Center(
                      child: Text(
                        'To Rent',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        // OLD BUTTONS
        // Row(
        //   children: [
        //     Expanded(
        //       child: Padding(
        //         padding: const EdgeInsets.all(8.0),
        //         child: FloatingActionButton(
        //           elevation: 0,
        //           shape: RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(
        //                 30.0), // Adjust the radius as needed
        //           ),
        //           onPressed: () {
        //             Navigator.push(
        //               context,
        //               MaterialPageRoute(
        //                   builder: (context) =>
        //                       ListScreen(true, myController.text, filter)),
        //             );
        //           },
        //           backgroundColor: const Color.fromARGB(255, 60, 120, 140),
        //           child: const Text(
        //             "For Sale",
        //             style: TextStyle(
        //                 fontSize: 18,
        //                 color: Colors.white,
        //                 fontWeight: FontWeight.w600),
        //           ),
        //         ),
        //       ),
        //     ),
        //     Expanded(
        //       child: Padding(
        //         padding: const EdgeInsets.all(8.0),
        //         child: FloatingActionButton(
        //           elevation: 0,
        //           shape: RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(
        //                 30.0), // Adjust the radius as needed
        //           ),
        //           onPressed: () {
        //             Navigator.push(
        //               context,
        //               MaterialPageRoute(
        //                   builder: (context) =>
        //                       ListScreen(false, myController.text, filter)),
        //             );
        //           },
        //           backgroundColor: const Color.fromARGB(255, 60, 120, 140),
        //           child: const Text(
        //             "To Rent",
        //             style: TextStyle(
        //                 fontSize: 18,
        //                 color: Colors.white,
        //                 fontWeight: FontWeight.w600),
        //           ),
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
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
                      value:
                          isForSaleSelected ? filter.minPrice : filter.minRent,
                      items: isForSaleSelected
                          ? filter.minPrices.keys.map((value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                              );
                            }).toList()
                          : filter.minRents.keys.map((value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                              );
                            }).toList(),
                      onChanged: (value) {
                        setState(() {
                          isForSaleSelected
                              ? filter.minPrice = value!
                              : filter.minRent = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    height: 60,
                    width: 155,
                    child: DropdownButtonFormField<String>(
                      value:
                          isForSaleSelected ? filter.maxPrice : filter.maxRent,
                      items: isForSaleSelected
                          ? filter.maxPrices.keys.map((value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                              );
                            }).toList()
                          : filter.maxRents.keys.map((value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                              );
                            }).toList(),
                      onChanged: (value) {
                        setState(() {
                          isForSaleSelected
                              ? filter.maxPrice = value!
                              : filter.maxRent = value!;
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
        SizedBox(
          width: 280,
          height: 60,
          child: FloatingActionButton(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(30.0), // Adjust the radius as needed
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ListViewScreen(
                        isForSaleSelected, myController.text, filter)),
              );
            },
            backgroundColor: const Color.fromARGB(255, 60, 120, 140),
            child: const Text(
              "Search",
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ]),
    );
  }
}
