import "dart:js_interop";
import "dart:math";

import "package:web/web.dart";

import "terraintype.dart";
import "../utility/colour.dart";

class MapData {
  final int seed;
  final int width;
  final int height;
  final List<TerrainType> data;
  final TerrainType defaultTerrain;

  late final int xMin, xMax, yMin, yMax;

  MapData(int this.width, int this.height, List<TerrainType> this.data, TerrainType this.defaultTerrain, {int this.seed = 0, int this.xMin = 0, int this.xMax = 0, int this.yMin = 0, int this.yMax = 0 }) {}

  factory MapData.fromBitmap(ImageBitmap bitmap, TerrainType defaultTerrain, {int seed = 0 }) {
    final int w = bitmap.width, h = bitmap.height;

    var canvas = new OffscreenCanvas(w,h);
    var context = canvas.getContext("2d") as OffscreenCanvasRenderingContext2D;
    context.drawImage(bitmap, 0, 0);

    var terrain = new List<TerrainType>.filled(w*h, defaultTerrain);
    var imgData = context.getImageData(0, 0, w, h);
    var abgrData = imgData.data.toDart.buffer.asUint32List();

    int x1 = 0, x2 = 0, y1 = 0, y2 = 0;

    for (int i=0; i<w*h; i++) {
      var abgr = abgrData[i];
      if (TerrainTypes.lookup.containsKey(abgr)) {
        var checked = TerrainTypes.lookup[abgr]!;
        terrain[i] = checked;

        x1 = min(x1, checked.xMin);
        x2 = max(x2, checked.xMax);
        y1 = min(y1, checked.yMin);
        y2 = max(y2, checked.yMax);
      }
    }

    return new MapData(w,h, terrain, defaultTerrain, seed: seed, xMin: x1, xMax: x2, yMin: y1, yMax: y2);
  }

  TerrainType terrainAt(int x, int y) {
    if (x < 0 || x >= width || y < 0 || y >= height) { return defaultTerrain; }

    return data[y * width + x];
  }

  int indexAt(int x, int y) {
    return y * width + x;
  }
}