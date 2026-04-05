
import 'package:web/web.dart';

import "../utility/extensions.dart";

abstract class Icons {
  static final List<String> imageNames = <String>[
    "mountain_0",
    "mountain_1",
    "mountain_2",
    "mountain_3",

    "hill_0",
    "hill_1",
    "hill_2",
    "hill_3",

    "tree_0",
    "tree_1",
    "tree_2",
    "tree_3",

    "pine_0",
    "pine_1",

    "savanna_0",
    "savanna_1",
    "savanna_2",

    "cactus_0",
    "cactus_1",
    "cactus_1",
    "cactus_2",

    "dead_tree_0",
    "dead_tree_1",
    "dead_tree_2",
    "dead_tree_3",

    "marsh_0",
    "marsh_1",
    "marsh_2",
    "marsh_3",
    "marsh_4",
    "marsh_5",

    "tundra_0",
    "tundra_1",
    "tundra_2",
    "tundra_3",

    "dune_0",
    "dune_1",
    "dune_2",
    "dune_3",

    "clouds_128_0",
    "clouds_128_1",
    "clouds_128_2",
    "clouds_128_3",
    "clouds_128_4",
    "clouds_128_5",
    "clouds_128_6",
    "clouds_128_7",
    "clouds_128_8",
    "clouds_128_9",

    //"images/parchment.png",

    //"images/maptest.png",
    //"images/sky island test.png",
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