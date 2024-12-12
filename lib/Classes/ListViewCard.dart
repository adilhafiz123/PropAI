import 'package:flutter/material.dart';

class ListViewCard extends StatelessWidget {
  const ListViewCard({this.listing, super.key});

  final listing;

  @override
  Widget build(BuildContext context) {
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
                  SizedBox(
                      width: 140, height: 65, child: Text(listing.address)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const SizedBox(width: 20),
                      SizedBox(
                          width: 21, child: Image.asset("assets/share.png")),
                      const SizedBox(width: 55),
                      // SizedBox(
                      //     width: 20, child: Image.asset("assets/telephone.png")),
                      // const SizedBox(width: 30),
                      SizedBox(
                          width: 22, child: Image.asset("assets/heart.png")),
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
}
