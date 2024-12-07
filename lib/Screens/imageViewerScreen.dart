import 'package:flutter/material.dart';
import 'package:my_flutter_application/helperFunctions.dart';

class ImageViewerScreen extends StatelessWidget {
  final List<String> imagePaths;

  const ImageViewerScreen(this.imagePaths, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      physics: const PageScrollPhysics(),
      children: [
        for (int i = 0; i < imagePaths.length; i++)
          InteractiveViewer(
              child: buildImageWidget(
                  imagePaths[i], false, context, List.empty())),
      ],
    );
  }
}
