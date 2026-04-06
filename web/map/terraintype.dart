import "dart:math";
import "../utility/colour.dart";
import "terrainelement.dart";
import "fillfunction.dart";
import "placement.dart";


class TerrainType {
  final String name;
  late final Colour colour;
  String? description;

  late final List<TerrainElement> elements;

  FillFunc? _fillfunc;
  FillFunc get fillfunc => _fillfunc!;
  PlacementFunc? _placefunc;
  PlacementFunc get placefunc => _placefunc!;
  final bool solid;
  final bool sky;
  final bool water;

  late final int xMin, xMax, yMin, yMax;

  TerrainType(String this.name, int red, int green, int blue, {List<TerrainElement>? elements = null, FillFunc? fillfunc = null, PlacementFunc? placefunc = null, bool this.solid = true, bool this.sky = false, bool this.water = false}) {
    this.colour = new Colour(red, green, blue);
    this.elements = elements ?? [];
    this._fillfunc = fillfunc ?? FillFunctions.LAND_FILL;
    this._placefunc = placefunc ?? FillFunctions.DEFAULT_PLACEMENT;

    int x1 = 0, x2 = 0, y1 = 0, y2 = 0;
    for(TerrainElement element in this.elements) {
      x1 = min(x1, element.xMin);
      x2 = max(x2, element.xMax);
      y1 = min(y1, element.yMin);
      y2 = max(y2, element.yMax);
    }
    xMin = x1;
    xMax = x2;
    yMin = y1;
    yMax = y2;
  }

  @override
  String toString() => this.name;
}

abstract class TerrainTypes {
  static TerrainType OCEAN = new TerrainType("Ocean", 68,102,170, fillfunc: FillFunctions.OCEAN_FILL, solid: false, water: true);
  static TerrainType GRASSLAND = new TerrainType("Grassland", 110,160,80);
  static TerrainType FARMLAND = new TerrainType("Farmland", 145,211,106, fillfunc: FillFunctions.FARM_FILL);
  static TerrainType FOREST = new TerrainType("Forest", 80,100,50, elements: TerrainElements.TREES_WEIGHTED, placefunc: Place.staggered(16, 14, Place.chanceOf(0.65, Place.onLand(4,3))));
  static TerrainType FARMLAND_FOREST = new TerrainType("Forested Farmland", 75,127,43, fillfunc: FillFunctions.FARM_FILL, elements: TerrainElements.TREES_WEIGHTED, placefunc:  Place.staggered(16, 14, Place.chanceOf(0.65, Place.onLand(4,3))))..description = "Farmland ground with trees on it.";
  static TerrainType PINE_FOREST = new TerrainType("Pine Forest", 50,100,70, elements: TerrainElements.PINE_TREES_WEIGHTED, placefunc: Place.staggered(16, 14, Place.chanceOf(0.75, Place.onLand(4,3))));
  static TerrainType HILLS = new TerrainType("Hills", 157,178,131, elements: TerrainElements.HILLS_WEIGHTED, placefunc: Place.staggered(32,28, Place.chanceOf(0.5, Place.onLand(16,2))));
  static TerrainType MOUNTAINS = new TerrainType("Mountains", 220,220,220, elements: TerrainElements.MOUNTAINS_WEIGHTED, placefunc: Place.staggered(32,28, Place.onLand(16,2)));
  static TerrainType SAVANNA = new TerrainType("Savanna", 230,219,101, elements: TerrainElements.SAVANNA, placefunc: Place.staggered(22, 18, Place.chanceOf(0.25)));
  static TerrainType DESERT = new TerrainType("Desert", 220,190,120, elements: TerrainElements.DUNES_WEIGHTED, placefunc: Place.staggered(22, 18, Place.chanceOf(0.55, Place.onLand(8,2))));
  static TerrainType WASTELAND = new TerrainType("Wasteland", 168,147,120, elements: TerrainElements.WASTELAND, placefunc: Place.staggered(32, 28, Place.chanceOf(0.12, Place.onLand(16,2))));
  static TerrainType TUNDRA = new TerrainType("Tundra", 195,182,179, elements: TerrainElements.TUNDRA_WEIGHTED, placefunc: Place.staggered(32, 28, Place.chanceOf(0.2, Place.onLand(16,2))));
  static TerrainType MARSH = new TerrainType("Marsh", 110,120,100, elements: TerrainElements.MARSHES_WEIGHTED, placefunc: Place.staggered(32, 28, Place.onLand(15,9)));
  static TerrainType SKY = new TerrainType("Sky", 136,204,232, fillfunc: FillFunctions.SKY_FILL, solid: false, sky: true)..description="For floating islands. Very slow to render, prefer Fast Sky for large areas away from land.";
  static TerrainType SKY_FAST = new TerrainType("Fast Sky", 149,224,255, fillfunc: FillFunctions.SKY_FILL_FAST, solid:false, sky:true, elements: TerrainElements.CLOUDS_128, placefunc: Place.staggered(400,250, Place.chanceOf(0.03)))..description = "For areas far away from land, does not generate island undersides or waterfalls. Has occasional random clouds.";
  static TerrainType CLOUDS_128 = new TerrainType("Clouds", 186,232,225, fillfunc: FillFunctions.SKY_FILL, solid:false, sky:true, elements: TerrainElements.CLOUDS_128, placefunc: Place.staggered(128,60))..description = "Dense clouds, good for scattering around sky areas.";

  static List<TerrainType> list = [OCEAN,GRASSLAND,FARMLAND,FOREST,FARMLAND_FOREST,PINE_FOREST,HILLS,MOUNTAINS,SAVANNA,DESERT,WASTELAND,TUNDRA,MARSH,SKY,SKY_FAST,CLOUDS_128];

  static Map<int,TerrainType> _lookup = {};
  static Map<int,TerrainType> get lookup {
    if (_lookup.isEmpty) {
      for (TerrainType type in list) {
        _lookup[type.colour.to32Bit] = type;
      }
    }
    return _lookup;
  }
}