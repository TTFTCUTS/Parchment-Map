import "dart:math";

import "mapdata.dart";
import "terraintype.dart";

typedef bool PlacementFunc(int x, int y, MapData map);
typedef double Curve(double input);

abstract class Place {
  static PlacementFunc grid(int xspacing, int yspacing, [int ox=0, int oy=0]) {
    return (int x, int y, MapData map) {
      if ((x+ox) % xspacing == 0 && (y+oy) % yspacing == 0) {
        return true;
      }
      return false;
    };
  }

  static PlacementFunc staggered(int xspacing, int yspacing, [PlacementFunc? function]) {
    PlacementFunc primary = grid(xspacing, yspacing);
    PlacementFunc secondary = grid(xspacing, yspacing, xspacing ~/2, yspacing ~/2);

    return (int x, int y, MapData map) {
      if (primary(x,y,map) || secondary(x,y,map)) {
        return function != null ? function(x,y,map) : true;
      }
      return false;
    };
  }

  static PlacementFunc chanceOf(double chance, [PlacementFunc? function]) {
    return (int x, int y, MapData map) {
      Random rand = new Random(y * map.width + x);
      if( rand.nextDouble() > chance) {
        return false;
      }
      return function != null ? function(x,y,map) : true;
    };
  }

  static PlacementFunc awayFrom(TerrainType type, num radius, [PlacementFunc? function, Curve? curve = null]) {
    int irad = radius.ceil();

    return (int x, int y, MapData map) {
      Random rand = new Random(y * map.width + x);
      double closest = double.infinity;

      for (int oy = -irad; oy <= irad; oy++) {
        for (int ox = -irad; ox <= irad; ox++) {
          if (x+ox < 0 || x+ox >= map.width || y+oy < 0 || y+oy >= map.height) { continue; }

          var checeked = map.terrainAt(x+ox, y+oy);
          if (checeked != type) { continue; }

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

      return function != null ? function(x,y,map) : true;
    };
  }

  static PlacementFunc rectPredicate(int xRange, int yRange, PlacementFunc predicate, [PlacementFunc? function] ) {

    return (int x, int y, MapData map) {
      for (int iy = y-yRange; iy <= y+yRange; iy++) {
        if (iy < 0 || iy >= map.height) { continue; }
        for (int ix = x-xRange; ix <= x+xRange; ix++) {
          if (ix < 0 || ix >= map.width) { continue; }
          if (!predicate(ix,iy,map)) {
            return false;
          }
        }
      }
      return function != null ? function(x,y,map) : true;
    };
  }

  static bool _landCheck(int x, int y, MapData map) {
    TerrainType? terrain = map.terrainAt(x, y);
    if (terrain.solid) { return true; }
    return false;
  }

  static PlacementFunc onLand(int xRange, int yRange, [PlacementFunc? function]) {
    return rectPredicate(xRange, yRange, _landCheck, function);
  }
}