
import 'package:web/web.dart';

import "../utility/extensions.dart";

abstract class Icons {
  static final List<String> imageNames = <String>[
    "images/mountain_0.png",
    "images/mountain_1.png",
    "images/mountain_2.png",
    "images/mountain_3.png",

    "images/hill_0.png",
    "images/hill_1.png",
    "images/hill_2.png",
    "images/hill_3.png",

    "images/tree_0.png",
    "images/tree_1.png",
    "images/tree_2.png",
    "images/tree_3.png",

    "images/pine_0.png",
    "images/pine_1.png",

    "images/savanna_0.png",
    "images/savanna_1.png",
    "images/savanna_2.png",

    "images/cactus_0.png",
    "images/cactus_1.png",
    "images/cactus_1.png",
    "images/cactus_2.png",

    "images/dead_tree_0.png",
    "images/dead_tree_1.png",
    "images/dead_tree_2.png",
    "images/dead_tree_3.png",

    "images/marsh_0.png",
    "images/marsh_1.png",
    "images/marsh_2.png",
    "images/marsh_3.png",
    "images/marsh_4.png",
    "images/marsh_5.png",

    "images/tundra_0.png",
    "images/tundra_1.png",
    "images/tundra_2.png",
    "images/tundra_3.png",

    "images/dune_0.png",
    "images/dune_1.png",
    "images/dune_2.png",
    "images/dune_3.png",

    "images/clouds_128_0.png",
    "images/clouds_128_1.png",
    "images/clouds_128_2.png",
    "images/clouds_128_3.png",
    "images/clouds_128_4.png",
    "images/clouds_128_5.png",
    "images/clouds_128_6.png",
    "images/clouds_128_7.png",
    "images/clouds_128_8.png",
    "images/clouds_128_9.png",

    "images/parchment.png",

    "images/maptest.png",
    "images/sky island test.png",
  ];

  static final Map<String, ImageBitmap> images = Map<String,ImageBitmap>();

  static Future<void> load(Future<ImageBitmap> Function(String name) loader) {
    return images.generateAsync(imageNames, loader);
  }

  static ImageBitmap get(String name) {
    if (images.containsKey(name)) { return images[name]!; }
    throw Exception("Image not found: $name");
  }
}