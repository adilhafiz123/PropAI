import 'package:flutter/material.dart';
import 'package:my_flutter_application/listViewScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_flutter_application/firebase_options.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(fontFamily: "FigTree"),
    //home: const Home(),
    home: const ListScreen(true, "E14"),
    navigatorKey: navigatorKey, // Setting a global key for navigator
  ));
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final myController = TextEditingController();

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
      appBar: AppBar(
        title: const Text(
          "Adil's App",
        ),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 9, 53, 90),
      ),
      body: Column(children: [
        const Center(
            child: Text("Enter Postcode",
                style: TextStyle(
                    color: Color.fromARGB(255, 9, 63, 66),
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Lato"))),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
              controller: myController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                focusColor: Colors.green,
                hintText: 'Enter postcode',
              )),
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ListScreen(true, myController.text)),
                    );
                  },
                  backgroundColor: const Color.fromARGB(255, 9, 63, 66),
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ListScreen(false, myController.text)),
                    );
                  },
                  backgroundColor: const Color.fromARGB(255, 9, 63, 66),
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
        const SizedBox(height: 80),
        Image.asset("assets/houses.png")
      ]),
    );
  }
}
