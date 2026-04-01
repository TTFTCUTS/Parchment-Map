library parchmentmap;

//import 'dart:html';
import 'package:web/web.dart';
import 'dart:js_interop';
import 'dart:math';

late HTMLCanvasElement canvas;
late CanvasRenderingContext2D ctx;
Random rand = new Random(1);
Map<HTMLImageElement, bool> imageLoadStates = {};
Map<String, HTMLImageElement> images = {};

Future<void> main() async {
  canvas = document.querySelector("#canvas")! as HTMLCanvasElement;
  ctx = canvas.context2D;

  List<String> imageNames = <String>[
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

  List<Future<Event>> loading = <Future<Event>>[];
  Element loader = document.querySelector("#loader")!;

  for (String src in imageNames) {
    final HTMLImageElement img = new HTMLImageElement();
    String name = src.split("/").last.split(".").first;
    print(name);
    images[name] = img;

    loading.add(img.onLoad.first);

    img.src = src;
    loader.append(img);
  }

  await Future.wait(loading);

  makeMap();
}

void makeMap() {
  // generated cell map
  /*CellMap map = new CellMap(canvas.width, canvas.height);
	map.build(30, 20);//(40, 30);
	map.draw(ctx);*/

  // image based map
  //CellMap map = new ImageMap(images["maptest"]!);

  //ImageElement img = images["sky island test"]!;
  HTMLImageElement img = images["maptest"]!;
  CellMap map = new ImageMap(img);
  map.build(0,0);
  canvas..width = img.width..height = img.height;
  map.draw(ctx, false);

  print("done");
}

class Colour {
  static Colour DEFAULT = new Colour(127,127,127);
  static Colour WHITE = new Colour(255,255,255);

  int red;
  int green;
  int blue;

  Colour(int this.red, int this.green, int this.blue);

  String toString() {
    return "rgb($red, $green, $blue)";
  }

  operator * (Object other) {
    if (other is num) {
      return new Colour((red*other).clamp(0, 255).floor(), (green*other).clamp(0, 255).floor(), (blue*other).clamp(0, 255).floor());
    }
    else if (other is Colour) {
      return new Colour(
        (((red/255) * (other.red/255)).clamp(0, 1) * 255).round(),
        (((green/255) * (other.green/255)).clamp(0, 1) * 255).round(),
        (((blue/255) * (other.blue/255)).clamp(0, 1) * 255).round(),
      );
    }
  }

  operator + (Object other) {
    if (other is Colour) {
      return new Colour (other.red + red, other.green + green, other.blue + blue);
    }
  }
}

typedef Colour FillFunc(int x, int y, Cell cell, CellMap map, bool borders);
typedef bool PlaceObjectFunc(int x, int y, Cell cell, CellMap map);
typedef double Curve(double input);

class SkyFillInfo {
  bool renderLand;
  int landY;
  int landDistance;
  bool renderWater;
  int waterY;
  int waterDistance;
  SkyFillInfo(bool this.renderLand, int this.landY, int this.landDistance, bool this.renderWater, int this.waterY, int this.waterDistance);
}

class TerrainType {
  static FillFunc DEFAULT_FILL = (int x, int y, Cell cell, CellMap map, bool borders) => cell.terrain == null ? Colour.DEFAULT : cell.terrain!.colour;
  static PlaceObjectFunc DEFAULT_PLACEMENT = (int x, int y, Cell cell, CellMap map) => false;

  static FillFunc LAND_FILL = (int x, int y, Cell cell, CellMap map, bool borders) {

    /*for (int oy = 0; oy < 2; oy++) {
			for (int ox = 0; ox < 2; ox++) {
				if (y+oy >= map.height || x+ox >= map.width) { continue; }
				int index = (y+oy) * map.width + x + ox;
				if (borders && map.closest[index] != cell && map.closest[index].terrain != TerrainTypes.OCEAN) {
					return new Colour(225,225,225);
				}
			}
		}*/

    double border = 0.0;

    for (int oy = -1; oy <=1; oy++) {
      for (int ox = -1; ox <=1; ox++) {
        if (ox == 0 && oy == 0) { continue; }
        if (y+oy < 0 || y+oy >= map.height || x+ox < 0 || x+ox >= map.width) { continue; }

        int index = (y+oy) * map.width + x + ox;
        bool ocean = !(map.closest[index]?.terrain?.solid??true);
        if ((borders || ocean) && map.closest[index] != cell) {
          double darken = 0.0;

          if (ox == 0 || oy == 0) {
            darken = 0.05;
          } else {
            darken = 0.03;
          }

          if (ocean) {
            darken *= 5;
          }

          border += darken;
        }
      }
    }

    int val = ((1.0-border) * 255).floor();

    return new Colour(val,val,val);//Colour.WHITE;
  };

  static const int _farm_cell_size = 24;
  static const double _farm_cell_deviation = 18;
  static const double _farm_lane_width = 6;
  static const double _farm_opacity = 0.25;
  static const int _farm_fade_radius = 6;
  static Colour FARM_FILL(int x, int y, Cell cell, CellMap map, bool borders) {
    final Colour landFill = LAND_FILL(x,y,cell,map,borders);

    int widthCells = (map.width / _farm_cell_size).ceil();

    int xCell = x ~/ _farm_cell_size;
    int yCell = y ~/ _farm_cell_size;

    Random rand1 = new Random((yCell) * widthCells + (xCell));
    double x1 = (xCell) * _farm_cell_size + rand1.nextDouble()*_farm_cell_deviation - _farm_cell_deviation * 0.5;
    double y1 = (yCell) * _farm_cell_size + rand1.nextDouble()*_farm_cell_deviation - _farm_cell_deviation * 0.5;
    double d1 = (x-x1)*(x-x1) + (y-y1)*(y-y1);

    Random rand2 = new Random((yCell) * widthCells + (xCell+1));
    double x2 = (xCell+1) * _farm_cell_size + rand2.nextDouble()*_farm_cell_deviation - _farm_cell_deviation * 0.5;
    double y2 = (yCell) * _farm_cell_size + rand2.nextDouble()*_farm_cell_deviation - _farm_cell_deviation * 0.5;
    double d2 = (x-x2)*(x-x2) + (y-y2)*(y-y2);

    Random rand3 = new Random((yCell+1) * widthCells + (xCell));
    double x3 = (xCell) * _farm_cell_size + rand3.nextDouble()*_farm_cell_deviation - _farm_cell_deviation * 0.5;
    double y3 = (yCell+1) * _farm_cell_size + rand3.nextDouble()*_farm_cell_deviation - _farm_cell_deviation * 0.5;
    double d3 = (x-x3)*(x-x3) + (y-y3)*(y-y3);

    Random rand4 = new Random((yCell+1) * widthCells + (xCell+1));
    double x4 = (xCell+1) * _farm_cell_size + rand4.nextDouble()*_farm_cell_deviation - _farm_cell_deviation * 0.5;
    double y4 = (yCell+1) * _farm_cell_size + rand4.nextDouble()*_farm_cell_deviation - _farm_cell_deviation * 0.5;
    double d4 = (x-x4)*(x-x4) + (y-y4)*(y-y4);

    late final Random r;
    late final double cellX;
    late final double cellY;
    if (d1 <= d2 && d1 <= d3 && d1 <= d4) {
      r = rand1;
      cellX = x1;
      cellY = y1;
    } else if (d2 <= d3 && d2 <= d4) {
      r = rand2;
      cellX = x2;
      cellY = y2;
    } else if (d3 <= d4) {
      r = rand3;
      cellX = x3;
      cellY = y3;
    } else {
      r = rand4;
      cellX = x4;
      cellY = y4;
    }

    double angle = r.nextDouble()*2*pi;
    double rSin = sin(angle);
    double rCos = cos(angle);

    double px = (x-cellX) * rSin - (y-cellY) * rCos;
    double py = (y-cellY) * rSin + (x-cellX) * rCos;

    double lane_width = _farm_lane_width * (0.8 + r.nextDouble() * 0.4);

    double wiggle = 0.2 + r.nextDouble() * 0.5;
    wiggle *= 0.2;
    double wiggle_amount = 0.25;

    double py2 = (py / lane_width) % 1;
    double px2 = ((px + sin(py * 2 * pi * wiggle) * wiggle_amount) / lane_width) % 1;

    double line = (1-((0.5 - px2).abs() * 5)).clamp(0, 1);

    int total = 0;
    int total_farm = 0;
    for (int iy = y-_farm_fade_radius; iy <= y+_farm_fade_radius; iy++) {
      if (iy < 0 || iy >= map.height) { continue; }
      for (int ix = x-_farm_fade_radius; ix <= x+_farm_fade_radius; ix++) {
        if (ix < 0 || ix >= map.width) { continue; }
        total++;
        TerrainType? terrain = map.terrainAt(ix, iy);
        if (terrain == null) { continue; }
        if (terrain.fillfunc == TerrainType.FARM_FILL || terrain.water) {
          total_farm++;
        }
      }
    }
    double fade = total == 0 ? 0 : (total_farm / total);
    fade = fade * fade * fade * fade;

    double variance = r.nextDouble() * 0.1 - 0.05;

    double opacity = (_farm_opacity + variance) * fade;
    int lineCol = (255 * (1-line*opacity)).floor();
    Colour out = new Colour(lineCol, lineCol, lineCol);

    return landFill * out;
  }

  static FillFunc OCEAN_FILL = (int x, int y, Cell cell, CellMap map, bool borders) {
    double border = 0.0;

    for (int ox=-1; ox<=1; ox++) {
      for (int oy=-1; oy<=1; oy++) {
        if (x+ox < 0 || x+ox >= map.width || y+oy < 0 || y+oy >= map.height) { continue; }
        int index = (y + oy) * map.width + x + ox;
        if (map.closest[index] == null || (map.closest[index]?.terrain?.solid??true)) {
          if (ox == 0 || oy == 0) {
            border += 0.05;
          } else {
            border += 0.03;
          }
        }
      }
    }

    for (int ox=-1; ox<=1; ox++) {
      if (x+ox < 0 || x+ox >= map.width || y-1 < 0 ) { continue; }
      TerrainType? terrain = map.terrainAt(x+ox, y-1);
      if (terrain == TerrainTypes.SKY) {
        if (ox == 0) {
          border += 0.05;
        } else {
          border += 0.03;
        }
      }
    }

    int edgeval = ((1.0-border*5) * 255).floor();

    int rad = 10;
    double closest = double.infinity;
    for (int ox=-rad; ox<=rad; ox++) {
      for (int oy=-rad; oy<=rad; oy++) {
        if (x+ox < 0 || x+ox >= map.width || y+oy < 0 || y+oy >= map.height) { continue; }

        double dx = ox / rad;
        double dy = oy / rad;
        double dist = sqrt(dx*dx + dy*dy);
        if (dist > 1) { continue; }

        int index = (y + oy) * map.width + x + ox;
        if (map.closest[index] == null || (map.closest[index]?.terrain?.solid??true)) {
          if (dist < closest) {
            closest = dist;
          }
        }
      }
    }
    if (closest <= 1) {
      double fraction = (1- ((1-closest) * (1-closest)));

      if (closest > 0.4 && closest < 0.55) {
        double interval = 0.0;
        if (closest < 0.475) {
          interval = (closest - 0.4) / 0.075;
        } else {
          interval = 1 - ((closest - 0.475) / 0.075);
        }
        fraction -= 0.8 * interval * 1.8;
      } else if (closest > 0.8 && closest < 0.95) {
        double interval = 0.0;
        if (closest < 0.875) {
          interval = (closest - 0.8) / 0.075;
        } else {
          interval = 1 - ((closest - 0.875) / 0.075);
        }
        fraction -= 0.5 * interval * 1.8;
      }

      int shade = min(edgeval,(fraction * 80 + 155).floor());
      return new Colour(shade,shade,shade);
    }

    int val = min(edgeval, 235);
    return new Colour(val,val,val);
  };

  static const int landRange = 36;
  static const int landRadius = landRange ~/ 2;
  static const int waterRange = 80;
  static const int lineRange = 50;
  static List<SkyFillInfo?>? skyCache;
  static SkyFillInfo getSkyFillInfo(int x, int y, CellMap map) {
    if (skyCache == null) {
      skyCache = new List<SkyFillInfo?>.filled(map.width*map.height, null);
    }

    int index = map.getIndex(x, y);
    if (skyCache![index] == null) {
      skyCache![index] = calcSkyFillInfo(x, y, map);
    }

    return skyCache![index]!;
  }
  static SkyFillInfo calcSkyFillInfo(int x, int y, CellMap map) {


    bool renderLand = false;
    int landY = -1;
    int landDistance = 0;
    bool renderWater = false;
    int waterY = -1;
    int waterDistance = 0;

    // water

    for (var i = 1; i <= waterRange; i++) {
      int cy = y - i;
      if (cy < 0) {
        break;
      }

      TerrainType? terrain = map.terrainAt(x, cy);
      bool water = terrain?.water ?? false;

      if (water) {
        bool adjacent = (map.terrainAt(x-1, cy)?.sky??false)
            || (map.terrainAt(x+1, cy)?.sky??false)
            || (map.terrainAt(x, cy-1)?.sky??false)
            || (map.terrainAt(x, cy+1)?.sky??false);

        if (adjacent) {
          renderWater = true;
          if (cy > waterY) {
            waterDistance = i;
            waterY = cy;
          }
          //break;
        }
      }
    }

    // land

    for (var i = 1; i <= landRange; i++) {
      int cy = y - i;
      if (cy < 0) {
        break;
      }

      TerrainType? terrain = map.terrainAt(x, cy);
      bool sky = terrain?.sky ?? false;

      if (!sky) {

        int rad = landRadius;
        double closest = double.infinity;
        for (int ox=-rad; ox<=rad; ox++) {
          for (int oy=-rad; oy<=rad; oy++) {
            if (x+ox < 0 || x+ox >= map.width || cy+oy < 0 || cy+oy >= map.height) { continue; }

            double dx = ox / rad;
            double dy = oy / rad;
            double dist = sqrt(dx*dx + dy*dy);
            if (dist > 1) { continue; }

            TerrainType? sample = map.terrainAt(x+ox, cy+oy);
            if (sample != null && sample.sky) {
              if (dist < closest) {
                closest = dist;
              }
            }
          }
        }

        num lfrac = pow(i/landRange, 1.75);

        num jitter = sin(x * 0.05) * 0.04 + sin(x * 0.5) * 0.02 + 0.02;

        lfrac += jitter;

        if (closest > lfrac) {
          renderLand = true;
          if (cy > landY) {
            landY = cy;
            landDistance = i;
          }
        }
      }
    }

    return new SkyFillInfo(renderLand, landY, landDistance, renderWater, waterY, waterDistance);
  }

  static FillFunc SKY_FILL_FAST = (int x, int y, Cell cell, CellMap map, bool borders) {
    return new Colour(220,220,220);
  };

  static FillFunc SKY_FILL = (int x, int y, Cell cell, CellMap map, bool borders) {

    SkyFillInfo info = getSkyFillInfo(x, y, map);
    bool renderLand = info.renderLand;
    int landY = info.landY;
    int landDistance = info.landDistance;
    bool renderWater = info.renderWater;
    int waterY = info.waterY;
    int waterDistance = info.waterDistance;

    double border = 0.0;

    for (int oy = -1; oy <=1; oy++) {
      for (int ox = -1; ox <=1; ox++) {
        if (ox == 0 && oy == 0) { continue; }
        if (y+oy < 0 || y+oy >= map.height || x+ox < 0 || x+ox >= map.width) { continue; }

        TerrainType? terrain = map.terrainAt(x+ox, y+oy);
        bool sky = (terrain?.sky??true);

        SkyFillInfo sample = getSkyFillInfo(x+ox, y+oy, map);

        int index = map.getIndex(x+ox, y+oy);
        if ((borders || !sky) && map.closest[index] != cell) {
          double darken = 0.0;

          if (ox == 0 || oy == 0) {
            darken = 0.05;
          } else {
            darken = 0.03;
          }

          if (terrain?.water??false) {
            if (oy == -1) {
              darken = 0;
            }
            else if(oy == 0) {
              darken *= 0.5;
            }
          }

          if (!sky) {
            darken *= 5;
          }

          border += darken;
        }

        // waterfall outlines
        if (!renderLand || waterY >= landY) {
          if (renderWater && !sample.renderWater && sky) {
            border += 0.1 * (1 - (waterDistance / waterRange));
          }
          else if (!renderWater && sample.renderWater && sky) {
            border += 0.2 * (1 - (sample.waterDistance / waterRange));
          }
          else if ((renderWater == sample.renderWater) && (waterY - sample.waterY).abs() > 2) {
            if (ox == 0 || oy == 0) {
              border += 0.15 * (1 - (sample.waterDistance / waterRange));
            } else {
              border += 0.07 * (1 - (sample.waterDistance / waterRange));
            }
          }
        }

        // underside outline
        if (!renderWater || landY > waterY) {
          // land vs sky and land vs water
          if ((renderLand != sample.renderLand) || (sample.renderWater && sample.waterY >= sample.landY && renderLand)) {
            if (ox == 0 || oy == 0) {
              border += 0.25;
            } else {
              border += 0.1;
            }
          }
          // depth difference
          else if((renderLand == sample.renderLand) && (landY - sample.landY).abs() > 2) {
            if (ox == 0 || oy == 0) {
              border += 0.08;
            } else {
              border += 0.04;
            }
          }
        }
      }
    }

    Colour output = new Colour(220,220,220);

    if (renderLand && (landY > waterY)) {
      double frac = 1.0 - landDistance / landRange;

      output = new Colour(220,220,220) * (frac * 0.5 + 0.5);
    }

    if (renderWater && (waterY >= landY)) {
      int jitter = (sin(x) * 2).round() + new Random(x).nextInt(2) - 1;

      double frac = 1.0 - pow(waterDistance / waterRange, 1.5);

      if (waterDistance < waterRange - jitter - 2) {
        //return new Colour(0, (frac * 255).floor(), 0);

        Colour water = TerrainType.OCEAN_FILL(x,y-waterDistance, cell, map, borders);

        output = ((water * (frac-0.2)) + (output * (1-frac))) * (1-border);
      }
    }

    if ((y~/2)%3 == 0 && !renderWater && !renderLand) {
      int range = (lineRange * (0.8 + sin(y*0.3) * 0.2)).floor();

      int closest = range+1;

      // right side
      for (int i=1; i<=range; i++) {
        if (x-i >= 0) {
          TerrainType? terrain = map.terrainAt(x - i, y);
          if (terrain != null) {
            if (!terrain.sky) {
              closest = min(closest,i);
            } else {
              SkyFillInfo sample = getSkyFillInfo(x - i, y, map);
              if (sample.renderLand) {
                closest = min(closest,i);
              }
            }
          }
        }
      }

      // left side
      for (int i=1; i<=range; i++) {
        if (x+i < map.width) {
          TerrainType? terrain = map.terrainAt(x + i, y);
          if (terrain != null) {
            if (!terrain.sky) {
              closest = min(closest,i);
            } else {
              SkyFillInfo sample = getSkyFillInfo(x + i, y, map);
              if (sample.renderLand) {
                closest = min(closest,i);
              }
            }
          }
        }
      }

      border += pow(1 - (closest/range).clamp(0, 1), 2) * 0.6;
    }

    return output * (1-border);
  };

  String name;
  late Colour colour;

  List<TerrainElement>? elements;

  FillFunc? fillfunc;
  PlaceObjectFunc? placefunc;
  bool solid;
  bool sky;
  bool water;

  TerrainType(String this.name, int red, int green, int blue, {List<TerrainElement>? this.elements = null, FillFunc? this.fillfunc = null, PlaceObjectFunc? this.placefunc = null, bool this.solid = true, bool this.sky = false, bool this.water = false}) {
    this.colour = new Colour(red, green, blue);
    if (this.fillfunc == null) {
      this.fillfunc = LAND_FILL;
    }
    if (this.placefunc == null) {
      this.placefunc = DEFAULT_PLACEMENT;
    }
  }

  @override
  String toString() => this.name;
}

class TerrainElement {
  String imagename;
  int offsetx;
  int offsety;
  int jitterx;
  int jittery;

  TerrainElement(String this.imagename, int this.offsetx, int this.offsety, [int this.jitterx = 0, int this.jittery = 0]);
}

class TerrainElements {
  static List<TerrainElement> MOUNTAINS = [
    new TerrainElement("mountain_0", 16, 21, 5, 3),
    new TerrainElement("mountain_1", 16, 22, 5, 3),
    new TerrainElement("mountain_2", 16, 23, 5, 3),
    new TerrainElement("mountain_3", 32, 41, 2, 3),
  ];

  static List<TerrainElement> MOUNTAINS_WEIGHTED = [
    ...([MOUNTAINS[0]] * 3),
    ...([MOUNTAINS[1]] * 3),
    ...([MOUNTAINS[2]] * 3),
    ...([MOUNTAINS[3]] * 1),
  ];

  static List<TerrainElement> HILLS = [
    new TerrainElement("hill_0", 16, 16, 3, 3),
    new TerrainElement("hill_1", 16, 16, 3, 3),
    new TerrainElement("hill_2", 16, 16, 3, 3),
    new TerrainElement("hill_3", 16, 16, 3, 3),
  ];

  static List<TerrainElement> HILLS_WEIGHTED = [
    ...([HILLS[0]] * 3),
    ...([HILLS[1]] * 3),
    ...([HILLS[2]] * 3),
    ...([HILLS[3]] * 2),
  ];

  static List<TerrainElement> TREES = [
    new TerrainElement("tree_0", 8, 13, 2, 1),
    new TerrainElement("tree_1", 8, 13, 2, 1),
    new TerrainElement("tree_2", 8, 14, 2, 1),
    new TerrainElement("tree_3", 8, 14, 2, 1),
  ];

  static List<TerrainElement> TREES_WEIGHTED = [
    ...([TREES[0]] * 4),
    ...([TREES[1]] * 4),
    ...([TREES[2]] * 2),
    ...([TREES[3]] * 1),
  ];

  static List<TerrainElement> PINE_TREES = [
    new TerrainElement("pine_0", 8, 14, 2, 1),
    new TerrainElement("pine_1", 8, 14, 2, 1),
  ];

  static List<TerrainElement> PINE_TREES_WEIGHTED = [
    ...([PINE_TREES[0]] * 1),
    ...([PINE_TREES[1]] * 1),
  ];

  static List<TerrainElement> MARSHES = [
    new TerrainElement("marsh_0", 16,16, 5, 3),
    new TerrainElement("marsh_1", 16,16, 5, 3),
    new TerrainElement("marsh_2", 16,16, 5, 3),
    new TerrainElement("marsh_3", 16,16, 5, 3),
    new TerrainElement("marsh_4", 16,16, 5, 3),
    new TerrainElement("marsh_5", 16,16, 5, 3),
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
    new TerrainElement("dune_0", 16,16, 4, 3),
    new TerrainElement("dune_1", 16,16, 4, 3),
    new TerrainElement("dune_2", 16,16, 4, 3),
    new TerrainElement("dune_3", 16,16, 4, 3),
  ];

  static List<TerrainElement> CACTUS = [
    new TerrainElement("cactus_0", 12,21, 2, 1),
    new TerrainElement("cactus_1", 12,21, 2, 1),
    new TerrainElement("cactus_2", 12,21, 2, 1),
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
    new TerrainElement("savanna_0", 8,14, 2, 1),
    new TerrainElement("savanna_1", 8,14, 2, 1),
    new TerrainElement("savanna_2", 8,14, 2, 1),
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
    new TerrainElement("dead_tree_0", 8, 13, 2, 1),
    new TerrainElement("dead_tree_1", 8, 13, 2, 1),
    new TerrainElement("dead_tree_2", 8, 14, 2, 1),
    new TerrainElement("dead_tree_3", 8, 14, 2, 1),
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
    new TerrainElement("tundra_0", 16, 16, 3, 3),
    new TerrainElement("tundra_1", 16, 16, 3, 3),
    new TerrainElement("tundra_2", 16, 16, 3, 3),
    new TerrainElement("tundra_3", 16, 16, 3, 3),
  ];

  static List<TerrainElement> TUNDRA_WEIGHTED = [
    ...([TUNDRA[0]] * 3),
    ...([TUNDRA[1]] * 3),
    ...([TUNDRA[2]] * 3),
    ...([TUNDRA[3]] * 2),
  ];

  static List<TerrainElement> CLOUDS_128 = [
    new TerrainElement("clouds_128_0", 64, 50, 8, 5),
    new TerrainElement("clouds_128_1", 64, 50, 8, 5),
    new TerrainElement("clouds_128_2", 64, 50, 8, 5),
    new TerrainElement("clouds_128_3", 64, 50, 8, 5),
    new TerrainElement("clouds_128_4", 64, 50, 8, 5),
    new TerrainElement("clouds_128_5", 64, 50, 8, 5),
    new TerrainElement("clouds_128_6", 64, 50, 8, 5),
    new TerrainElement("clouds_128_7", 64, 50, 8, 5),
    new TerrainElement("clouds_128_8", 64, 50, 8, 5),
    new TerrainElement("clouds_128_9", 64, 50, 8, 5),
  ];
}

class Place {
  static PlaceObjectFunc grid(int xspacing, int yspacing, [int ox=0, int oy=0]) {
    return (int x, int y, Cell cell, CellMap map) {
      if ((x+ox) % xspacing == 0 && (y+oy) % yspacing == 0) {
        return true;
      }
      return false;
    };
  }

  static PlaceObjectFunc staggered(int xspacing, int yspacing, [PlaceObjectFunc? function]) {
    PlaceObjectFunc primary = grid(xspacing, yspacing);
    PlaceObjectFunc secondary = grid(xspacing, yspacing, xspacing ~/2, yspacing ~/2);

    return (int x, int y, Cell cell, CellMap map) {
      if (primary(x,y,cell,map) || secondary(x,y,cell,map)) {
        return function != null ? function(x,y,cell,map) : true;
      }
      return false;
    };
  }

  static PlaceObjectFunc chanceOf(double chance, [PlaceObjectFunc? function]) {
    return (int x, int y, Cell cell, CellMap map) {
      if( rand.nextDouble() > chance) {
        return false;
      }
      return function != null ? function(x,y,cell,map) : true;
    };
  }

  static PlaceObjectFunc awayFrom(TerrainType type, num radius, [PlaceObjectFunc? function, Curve? curve = null]) {
    int irad = radius.ceil();

    return (int x, int y, Cell cell, CellMap map) {
      double closest = double.infinity;

      for (int oy = -irad; oy <= irad; oy++) {
        for (int ox = -irad; ox <= irad; ox++) {
          if (x+ox < 0 || x+ox >= map.width || y+oy < 0 || y+oy >= map.height) { continue; }

          int index = (y+oy) * map.width + x+ox;
          Cell? ccell = map.closest[index];

          if (ccell != null && ccell.terrain != type) { continue; }

          double dx = ox / radius;
          double dy = oy / radius;
          double dist = sqrt(dx*dx + dy*dy);
          if (dist > 1) { continue; }

          if (dist < closest) {
            closest = dist;
          }
        }
      }
      double c = 1-closest;
      if (curve != null) {
        c = curve(1-closest);
      }
      if (c == 0 || rand.nextDouble() < c ) {
        return false;
      }

      return function != null ? function(x,y,cell,map) : true;
    };
  }

  static PlaceObjectFunc rectPredicate(int xRange, int yRange, PlaceObjectFunc predicate, [PlaceObjectFunc? function] ) {

    return (int x, int y, Cell cell, CellMap map) {
      for (int iy = y-yRange; iy <= y+yRange; iy++) {
        if (iy < 0 || iy >= map.height) { continue; }
        for (int ix = x-xRange; ix <= x+xRange; ix++) {
          if (ix < 0 || ix >= map.width) { continue; }
          if (!predicate(ix,iy,cell,map)) {
            return false;
          }
        }
      }
      return function != null ? function(x,y,cell,map) : true;
    };
  }

  static bool _landCheck(int x, int y, Cell cell, CellMap map) {
    TerrainType? terrain = map.terrainAt(x, y);
    if (terrain == null) { return false; }
    if (terrain.solid) { return true; }
    return false;
  }

  static PlaceObjectFunc onLand(int xRange, int yRange, [PlaceObjectFunc? function]) {
    return rectPredicate(xRange, yRange, _landCheck, function);
  }
}

class TerrainTypes {
  static TerrainType OCEAN = new TerrainType("Ocean", 68,102,170, fillfunc: TerrainType.OCEAN_FILL, solid: false, water: true);
  static TerrainType GRASSLAND = new TerrainType("Grassland", 110,160,80);
  static TerrainType FARMLAND = new TerrainType("Farmland", 145,211,106, fillfunc: TerrainType.FARM_FILL);
  static TerrainType FOREST = new TerrainType("Forest", 80,100,50, elements: TerrainElements.TREES_WEIGHTED, placefunc: Place.staggered(16, 14, Place.chanceOf(0.65, Place.onLand(4,3))));
  static TerrainType FARMLAND_FOREST = new TerrainType("Forested Farmland", 75,127,43, fillfunc: TerrainType.FARM_FILL, elements: TerrainElements.TREES_WEIGHTED, placefunc:  Place.staggered(16, 14, Place.chanceOf(0.65, Place.onLand(4,3))));
  static TerrainType PINE_FOREST = new TerrainType("Pine Forest", 50,100,70, elements: TerrainElements.PINE_TREES_WEIGHTED, placefunc: Place.staggered(16, 14, Place.chanceOf(0.75, Place.onLand(4,3))));
  static TerrainType HILLS = new TerrainType("Hills", 157,178,131, elements: TerrainElements.HILLS_WEIGHTED, placefunc: Place.staggered(32,28, Place.chanceOf(0.5, Place.onLand(16,2))));
  static TerrainType MOUNTAINS = new TerrainType("Mountains", 220,220,220, elements: TerrainElements.MOUNTAINS_WEIGHTED, placefunc: Place.staggered(32,28, Place.onLand(16,2)));
  static TerrainType SAVANNA = new TerrainType("Savanna", 230,219,101, elements: TerrainElements.SAVANNA, placefunc: Place.staggered(22, 18, Place.chanceOf(0.25)));
  static TerrainType DESERT = new TerrainType("Desert", 220,190,120, elements: TerrainElements.DUNES_WEIGHTED, placefunc: Place.staggered(22, 18, Place.chanceOf(0.55, Place.onLand(8,2))));
  static TerrainType WASTELAND = new TerrainType("Wasteland", 168,147,120, elements: TerrainElements.WASTELAND, placefunc: Place.staggered(32, 28, Place.chanceOf(0.12, Place.onLand(16,2))));
  static TerrainType TUNDRA = new TerrainType("Tundra", 195,182,179, elements: TerrainElements.TUNDRA_WEIGHTED, placefunc: Place.staggered(32, 28, Place.chanceOf(0.2, Place.onLand(16,2))));
  static TerrainType MARSH = new TerrainType("Marsh", 110,120,100, elements: TerrainElements.MARSHES_WEIGHTED, placefunc: Place.staggered(32, 28, Place.onLand(15,9)));
  static TerrainType SKY = new TerrainType("Sky", 136,204,232, fillfunc: TerrainType.SKY_FILL, solid: false, sky: true);
  static TerrainType SKY_FAST = new TerrainType("Fast Sky", 149,224,255, fillfunc: TerrainType.SKY_FILL_FAST, solid:false, sky:true, elements: TerrainElements.CLOUDS_128, placefunc: Place.staggered(400,250, Place.chanceOf(0.03)));
  static TerrainType CLOUDS_128 = new TerrainType("Clouds 128", 186,232,225, fillfunc: TerrainType.SKY_FILL, solid:false, sky:true, elements: TerrainElements.CLOUDS_128, placefunc: Place.staggered(128,60)); // Place.staggered(100,45));

  static List<TerrainType> list = [OCEAN,GRASSLAND,FARMLAND,FOREST,FARMLAND_FOREST,PINE_FOREST,HILLS,MOUNTAINS,SAVANNA,DESERT,WASTELAND,TUNDRA,MARSH,SKY,SKY_FAST,CLOUDS_128];

  static TerrainType getTerrainForCell(int cx, int cy, int cw, int ch, int x, int y, int w, int h) {
    if (cx == 0 || cx == cw -1 || cy == 0 || cy == ch -1) {
      return OCEAN;
    }

    double dx = (0.5 - (x/w)) * 2;
    double dy = (0.5 - (y/h)) * 2;
    double depth = 1-sqrt(dx*dx+dy*dy);
    print(depth);

    if (depth < 0.75) {
      if (rand.nextDouble() - 0.2 > depth * 1.5) {
        return OCEAN;
      }

      if (depth < 0.3 && rand.nextDouble() > 0.5) {
        return MARSH;
      }
    }

    if (depth > 0.9 || (depth > 0.75 && rand.nextDouble() > 0.4)) {
      return MOUNTAINS;
    }

    if (depth > 0.1 && depth < 0.6 && rand.nextDouble() < 0.2) {
      return DESERT;
    }

    if (rand.nextDouble()-0.1 < depth) {
      if (depth < 0.75 && rand.nextDouble() < 0.8) {
        return FOREST;
      } else {
        return PINE_FOREST;
      }
    }

    return GRASSLAND;
  }
}

class Cell {
  int x;
  int y;
  TerrainType? terrain;
  late Colour colour;

  Cell(int this.x, int this.y, TerrainType? this.terrain) {
    this.colour = new Colour(rand.nextInt(128) + 63, rand.nextInt(128) + 63, rand.nextInt(128) + 63);
  }
}

class CellMap {
  int width;
  int height;
  late List<Cell?> closest;
  late List<Cell> cells;

  CellMap(int this.width, int this.height) {
    this.closest = new List<Cell?>.filled(this.width * this.height, null);
    this.cells = <Cell>[];
  }

  int getIndex(int x, int y) {
    return y * width + x;
  }

  TerrainType? terrainAt(int x, int y) {
    if (x < 0 || x >= width || y < 0 || y >= height) { return null; }

    int index = getIndex(x,y);
    return closest[index]?.terrain;
  }

  void build(int spacing, int spread) {
    // make all the cells semi-randomly
    int xcells = (width / spacing).ceil();
    int ycells = (height / spacing).ceil();
    int xoffset = -(((xcells * spacing) - width) ~/ 2) + (spacing ~/2);
    int yoffset = -(((ycells * spacing) - height) ~/ 2) + (spacing ~/2);

    int cx,cy;
    for (int x = 0; x<xcells; x++) {
      for (int y = 0; y<ycells; y++) {

        cx = x * spacing + xoffset;
        cx -= spread ~/ 2;
        cx += rand.nextInt(spread);

        cy = y * spacing + yoffset;
        cy -= spread ~/ 2;
        cy += rand.nextInt(spread);

        TerrainType type = TerrainTypes.getTerrainForCell(x,y,xcells,ycells, cx, cy, width, height);
        print(type);
        Cell cell = new Cell(cx, cy, type);
        this.cells.add(cell);
      }
    }

    // sweep over the cells with a box to limit which are checked against for closest
    Iterable<Cell> cellsToCheck;
    for (int y = 0; y<height; y++) {
      for (int x = 0; x<width; x++) {
        cellsToCheck = cellsInBox(x,y, spacing);

        Cell? close = null;
        double closedistance = double.infinity;

        for(Cell c in cellsToCheck) {
          int dx = x - c.x;
          int dy = y - c.y;
          double distance = sqrt(dx*dx + dy*dy);

          if (distance <= closedistance) {
            close = c;
            closedistance = distance;
          }
        }

        this.closest[y * width + x] = close;
      }
    }
  }

  Iterable<Cell> cellsInBox(int x, int y, int halfsize) {
    int xmin = x - halfsize;
    int xmax = x + halfsize;
    int ymin = y - halfsize;
    int ymax = y + halfsize;

    return this.cells.where((Cell c) { return c.x >= xmin && c.x <= xmax && c.y >= ymin && c.y <= ymax; });
  }

  void draw(CanvasRenderingContext2D ctx, [bool borders = true]) {

    ImageData img = ctx.getImageData(0,0,this.width,this.height);
    var data = img.data.toDart;

    int index;
    Cell? close;
    for (int y = 0; y<height; y++) {
      for (int x = 0; x < width; x++) {
        index = y * width + x;

        close = this.closest[index];

        if (close == null || close.terrain == null) { continue; }

        Colour colour = close.terrain!.fillfunc!(x,y, close, this, borders);

        data[index * 4] = colour.red;
        data[index * 4 + 1] = colour.green;
        data[index * 4 + 2] = colour.blue;
        data[index * 4 + 3] = 255;
      }
    }

    ctx.putImageData(img, 0,0);

    for (int y = 0; y<height; y++) {
      for (int x = 0; x < width; x++) {
        index = y * width + x;

        close = this.closest[index];

        if (close == null || close.terrain == null) {
          continue;
        }

        if (close.terrain?.elements == null || close.terrain!.elements!.isEmpty) {
          continue;
        }

        if (!close.terrain!.placefunc!(x,y,close, this)) { continue; }

        TerrainElement element = close.terrain!.elements![rand.nextInt(close.terrain!.elements!.length)];

        int spritex = x - element.offsetx;
        if (element.jitterx > 0) {
          spritex -= element.jitterx;
          spritex += rand.nextInt(1 + element.jitterx * 2);
        }

        int spritey = y - element.offsety;
        if (element.jittery > 0) {
          spritey -= element.jittery;
          spritey += rand.nextInt(1 + element.jittery * 2);
        }

        ctx.drawImage(images[element.imagename]!, spritex, spritey);
      }
    }

    /*ctx.fillStyle = "#000000";
		for (Cell c in cells) {
			//ctx.fillStyle = c.fill;
			ctx.fillRect(c.x - 1, c.y -1, 3,3);
		}*/

    /*CanvasPattern parchment = ctx.createPatternFromImage(images["parchment"]!, "repeat");
    ctx.globalCompositeOperation = "multiply";
    ctx.fillStyle = parchment;
    ctx.fillRect(0,0,width,height);*/
  }
}

class ImageMap extends CellMap {
  HTMLImageElement sourceImage;

  Map<TerrainType, Cell> cellMapping = {};

  ImageMap(HTMLImageElement this.sourceImage):super(sourceImage.width, sourceImage.height) {
    for (TerrainType type in TerrainTypes.list) {
      Cell cell = new Cell(0,0,type);
      cellMapping[type] = cell;
      this.cells.add(cell);
    }
  }

  @override
  void build(int spacing, int spread) {
    HTMLCanvasElement mapcanvas = new HTMLCanvasElement()..width = this.width..height = this.height;
    CanvasRenderingContext2D ctx = mapcanvas.context2D;
    ctx.drawImage(this.sourceImage, 0, 0);

    ImageData imgData = ctx.getImageData(0, 0, this.width, this.height);
    var data = imgData.data.toDart;

    for (int x=0; x<this.width; x++) {
      for (int y=0; y<this.height; y++) {
        int index = (y * this.width) + x;

        for (TerrainType type in TerrainTypes.list) {
          Colour c = type.colour;

          if (data[index*4] == c.red && data[index*4+1] == c.green && data[index*4+2] == c.blue) {
            this.closest[index] = cellMapping[type];
            break;
          }
        }
      }
    }
  }
}

extension ListMult<T> on List<T> {
  operator *(int other) {
    return this.repeat(other);
  }

  List<T> repeat(int count) {
    List<T> out = <T>[];
    for (int i=0; i<count; i++) {
      out.addAll(this);
    }
    return out;
  }
}