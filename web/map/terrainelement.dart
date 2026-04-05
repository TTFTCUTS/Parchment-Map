import "package:web/helpers.dart";

import "../utility/extensions.dart";

class TerrainElement {
  final String imagename;
  final int width;
  final int height;
  final int offsetx;
  final int offsety;
  final int jitterx;
  final int jittery;

  late final int xMin = -offsetx - jitterx;
  late final int xMax = width - offsetx + jitterx;
  late final int yMin = -offsety - jittery;
  late final int yMax = height - offsety + jittery;

  TerrainElement(String this.imagename, int this.width, int this.height, int this.offsetx, int this.offsety, [int this.jitterx = 0, int this.jittery = 0]);
}

class TerrainElements {
  static List<TerrainElement> MOUNTAINS = [
    new TerrainElement("mountain_0", 32, 32, 16, 21, 5, 3),
    new TerrainElement("mountain_1", 32, 32, 16, 22, 5, 3),
    new TerrainElement("mountain_2", 32, 32, 16, 23, 5, 3),
    new TerrainElement("mountain_3", 64, 64, 32, 41, 2, 3),
  ];

  static List<TerrainElement> MOUNTAINS_WEIGHTED = [
    ...([MOUNTAINS[0]] * 3),
    ...([MOUNTAINS[1]] * 3),
    ...([MOUNTAINS[2]] * 3),
    ...([MOUNTAINS[3]] * 1),
  ];

  static List<TerrainElement> HILLS = [
    new TerrainElement("hill_0", 32, 32, 16, 16, 3, 3),
    new TerrainElement("hill_1", 32, 32, 16, 16, 3, 3),
    new TerrainElement("hill_2", 32, 32, 16, 16, 3, 3),
    new TerrainElement("hill_3", 32, 32, 16, 16, 3, 3),
  ];

  static List<TerrainElement> HILLS_WEIGHTED = [
    ...([HILLS[0]] * 3),
    ...([HILLS[1]] * 3),
    ...([HILLS[2]] * 3),
    ...([HILLS[3]] * 2),
  ];

  static List<TerrainElement> TREES = [
    new TerrainElement("tree_0", 16, 16, 8, 13, 2, 1),
    new TerrainElement("tree_1", 16, 16, 8, 13, 2, 1),
    new TerrainElement("tree_2", 16, 16, 8, 14, 2, 1),
    new TerrainElement("tree_3", 16, 16, 8, 14, 2, 1),
  ];

  static List<TerrainElement> TREES_WEIGHTED = [
    ...([TREES[0]] * 4),
    ...([TREES[1]] * 4),
    ...([TREES[2]] * 2),
    ...([TREES[3]] * 1),
  ];

  static List<TerrainElement> PINE_TREES = [
    new TerrainElement("pine_0", 16, 16, 8, 14, 2, 1),
    new TerrainElement("pine_1", 16, 16, 8, 14, 2, 1),
  ];

  static List<TerrainElement> PINE_TREES_WEIGHTED = [
    ...([PINE_TREES[0]] * 1),
    ...([PINE_TREES[1]] * 1),
  ];

  static List<TerrainElement> MARSHES = [
    new TerrainElement("marsh_0", 32, 32, 16, 16, 5, 3),
    new TerrainElement("marsh_1", 32, 32, 16, 16, 5, 3),
    new TerrainElement("marsh_2", 32, 32, 16, 16, 5, 3),
    new TerrainElement("marsh_3", 32, 32, 16, 16, 5, 3),
    new TerrainElement("marsh_4", 32, 32, 16, 16, 5, 3),
    new TerrainElement("marsh_5", 32, 32, 16, 16, 5, 3),
  ];

  static List<TerrainElement> MARSHES_WEIGHTED = [
    ...([MARSHES[0]] * 1),
    ...([MARSHES[1]] * 1),
    ...([MARSHES[2]] * 1),
    ...([MARSHES[3]] * 2),
    ...([MARSHES[4]] * 1),
    ...([MARSHES[5]] * 2),
  ];

  static List<TerrainElement> DUNES = [
    new TerrainElement("dune_0", 32, 32, 16, 16, 4, 3),
    new TerrainElement("dune_1", 32, 32, 16, 16, 4, 3),
    new TerrainElement("dune_2", 32, 32, 16, 16, 4, 3),
    new TerrainElement("dune_3", 32, 32, 16, 16, 4, 3),
  ];

  static List<TerrainElement> CACTUS = [
    new TerrainElement("cactus_0", 24, 24, 12, 21, 2, 1),
    new TerrainElement("cactus_1", 24, 24, 12, 21, 2, 1),
    new TerrainElement("cactus_2", 24, 24, 12, 21, 2, 1),
  ];

  static List<TerrainElement> DUNES_WEIGHTED = [
    ...([DUNES[0]] * 20),
    ...([DUNES[1]] * 20),
    ...([DUNES[2]] * 20),
    ...([DUNES[3]] * 40),
    ...([CACTUS[0]] * 2),
    ...([CACTUS[1]] * 5),
    //...([CACTUS[2]] * 1),
  ];

  static List<TerrainElement> SAVANNA_TREES = [
    new TerrainElement("savanna_0", 16, 16, 8, 14, 2, 1),
    new TerrainElement("savanna_1", 16, 16, 8, 14, 2, 1),
    new TerrainElement("savanna_2", 16, 16, 8, 14, 2, 1),
  ];

  static List<TerrainElement> SAVANNA = [
    ...([DUNES[0]] * 1),
    ...([DUNES[1]] * 1),
    ...([DUNES[2]] * 1),
    ...([DUNES[3]] * 2),
    ...([SAVANNA_TREES[0]] * 4),
    ...([SAVANNA_TREES[1]] * 3),
    ...([SAVANNA_TREES[2]] * 1),
  ];

  static List<TerrainElement> DEAD_TREES = [
    new TerrainElement("dead_tree_0", 16, 16, 8, 13, 2, 1),
    new TerrainElement("dead_tree_1", 16, 16, 8, 13, 2, 1),
    new TerrainElement("dead_tree_2", 16, 16, 8, 14, 2, 1),
    new TerrainElement("dead_tree_3", 16, 16, 8, 14, 2, 1),
  ];

  static List<TerrainElement> WASTELAND = [
    ...([DEAD_TREES[0]] * 3),
    ...([DEAD_TREES[1]] * 3),
    ...([DEAD_TREES[2]] * 2),
    ...([DEAD_TREES[3]] * 3),
    ...([TUNDRA[0]] * 6),
    ...([TUNDRA[1]] * 6),
    //...([TUNDRA[2]] * 3),
    ...([TUNDRA[3]] * 4),
  ];

  static List<TerrainElement> TUNDRA = [
    new TerrainElement("tundra_0", 32, 32, 16, 16, 3, 3),
    new TerrainElement("tundra_1", 32, 32, 16, 16, 3, 3),
    new TerrainElement("tundra_2", 32, 32, 16, 16, 3, 3),
    new TerrainElement("tundra_3", 32, 32, 16, 16, 3, 3),
  ];

  static List<TerrainElement> TUNDRA_WEIGHTED = [
    ...([TUNDRA[0]] * 3),
    ...([TUNDRA[1]] * 3),
    ...([TUNDRA[2]] * 3),
    ...([TUNDRA[3]] * 2),
  ];

  static List<TerrainElement> CLOUDS_128 = [
    new TerrainElement("clouds_128_0", 128, 128, 64, 50, 8, 5),
    new TerrainElement("clouds_128_1", 128, 128, 64, 50, 8, 5),
    new TerrainElement("clouds_128_2", 128, 128, 64, 50, 8, 5),
    new TerrainElement("clouds_128_3", 128, 128, 64, 50, 8, 5),
    new TerrainElement("clouds_128_4", 128, 128, 64, 50, 8, 5),
    new TerrainElement("clouds_128_5", 128, 128, 64, 50, 8, 5),
    new TerrainElement("clouds_128_6", 128, 128, 64, 50, 8, 5),
    new TerrainElement("clouds_128_7", 128, 128, 64, 50, 8, 5),
    new TerrainElement("clouds_128_8", 128, 128, 64, 50, 8, 5),
    new TerrainElement("clouds_128_9", 128, 128, 64, 50, 8, 5),
  ];
}