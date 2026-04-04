import "dart:math";

import "../utility/colour.dart";
import "mapdata.dart";

import "placement.dart";
import "terraintype.dart";

typedef Colour FillFunc(int x, int y, MapData map, bool borders);

abstract class FillFunctions {
  static FillFunc DEFAULT_FILL = (int x, int y, MapData map, bool borders) => map.terrainAt(x, y).colour;
  static PlacementFunc DEFAULT_PLACEMENT = (int x, int y, MapData map) => false;

  static FillFunc LAND_FILL = (int x, int y, MapData map, bool borders) {
    double border = 0.0;
    var terrain = map.terrainAt(x, y);

    for (int oy = -1; oy <=1; oy++) {
      for (int ox = -1; ox <=1; ox++) {
        if (ox == 0 && oy == 0) { continue; }
        if (y+oy < 0 || y+oy >= map.height || x+ox < 0 || x+ox >= map.width) { continue; }

        var checked = map.terrainAt(x+ox, y+oy);
        bool ocean = !checked.solid;
        if ((borders || ocean) && checked != terrain) {
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
  static Colour FARM_FILL(int x, int y, MapData map, bool borders) {
    final Colour landFill = LAND_FILL(x,y,map,borders);

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
        TerrainType terrain = map.terrainAt(ix, iy);
        if (terrain.fillfunc == FillFunctions.FARM_FILL || terrain.water) {
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

  static FillFunc OCEAN_FILL = (int x, int y, MapData map, bool borders) {
    double border = 0.0;

    for (int ox=-1; ox<=1; ox++) {
      for (int oy=-1; oy<=1; oy++) {
        if (x+ox < 0 || x+ox >= map.width || y+oy < 0 || y+oy >= map.height) { continue; }
        var checked = map.terrainAt(x+ox, y+oy);
        if (checked.solid) {
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

        var checked = map.terrainAt(x+ox, y+oy);
        if (checked.solid) {
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
  static SkyFillInfo getSkyFillInfo(int x, int y, MapData map) {
    if (skyCache == null) {
      skyCache = new List<SkyFillInfo?>.filled(map.width*map.height, null);
    }

    int index = map.indexAt(x, y);
    if (skyCache![index] == null) {
      skyCache![index] = calcSkyFillInfo(x, y, map);
    }

    return skyCache![index]!;
  }
  static SkyFillInfo calcSkyFillInfo(int x, int y, MapData map) {


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
      bool water = terrain.water;

      if (water) {
        bool adjacent = (map.terrainAt(x-1, cy).sky)
            || (map.terrainAt(x+1, cy).sky)
            || (map.terrainAt(x, cy-1).sky)
            || (map.terrainAt(x, cy+1).sky);

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

      TerrainType terrain = map.terrainAt(x, cy);
      bool sky = terrain.sky;

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

            TerrainType sample = map.terrainAt(x+ox, cy+oy);
            if (sample.sky) {
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

  static FillFunc SKY_FILL_FAST = (int x, int y, MapData map, bool borders) {
    return new Colour(220,220,220);
  };

  static FillFunc SKY_FILL = (int x, int y, MapData map, bool borders) {

    SkyFillInfo info = getSkyFillInfo(x, y, map);
    bool renderLand = info.renderLand;
    int landY = info.landY;
    int landDistance = info.landDistance;
    bool renderWater = info.renderWater;
    int waterY = info.waterY;
    int waterDistance = info.waterDistance;

    double border = 0.0;

    var terrain = map.terrainAt(x, y);

    for (int oy = -1; oy <=1; oy++) {
      for (int ox = -1; ox <=1; ox++) {
        if (ox == 0 && oy == 0) { continue; }
        if (y+oy < 0 || y+oy >= map.height || x+ox < 0 || x+ox >= map.width) { continue; }

        TerrainType? terrain = map.terrainAt(x+ox, y+oy);
        bool sky = (terrain.sky);

        SkyFillInfo sample = getSkyFillInfo(x+ox, y+oy, map);

        var checked = map.terrainAt(x+ox, y+oy);
        if ((borders || !sky) && checked != terrain) {
          double darken = 0.0;

          if (ox == 0 || oy == 0) {
            darken = 0.05;
          } else {
            darken = 0.03;
          }

          if (terrain.water) {
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

        Colour water = FillFunctions.OCEAN_FILL(x,y-waterDistance, map, borders);

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

      // left side
      for (int i=1; i<=range; i++) {
        if (x+i < map.width) {
          TerrainType? terrain = map.terrainAt(x + i, y);
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

      border += pow(1 - (closest/range).clamp(0, 1), 2) * 0.6;
    }

    return output * (1-border);
  };
}

class SkyFillInfo {
  bool renderLand;
  int landY;
  int landDistance;
  bool renderWater;
  int waterY;
  int waterDistance;
  SkyFillInfo(bool this.renderLand, int this.landY, int this.landDistance, bool this.renderWater, int this.waterY, int this.waterDistance);
}