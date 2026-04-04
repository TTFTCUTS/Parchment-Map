import "dart:js_interop";

import "package:web/web.dart";

import "terraintype.dart";
import "../utility/colour.dart";

class MapData {
  final int width;
  final int height;
  final List<TerrainType> data;
  final TerrainType defaultTerrain;

  MapData(int this.width, int this.height, List<TerrainType> this.data, TerrainType this.defaultTerrain) {}

  factory MapData.fromBitmap(ImageBitmap bitmap, TerrainType defaultTerrain) {
    final int w = bitmap.width, h = bitmap.height;

    var canvas = new OffscreenCanvas(w,h);
    var context = canvas.getContext("2d") as OffscreenCanvasRenderingContext2D;
    context.drawImage(bitmap, 0, 0);

    var terrain = new List<TerrainType>.filled(w*h, defaultTerrain);
    var imgData = context.getImageData(0, 0, w, h);
    var abgrData = imgData.data.toDart.buffer.asUint32List();

    for (int i=0; i<w*h; i++) {
      var abgr = abgrData[i];
      if (TerrainTypes.lookup.containsKey(abgr)) {
        terrain[i] = TerrainTypes.lookup[abgr]!;
      }
    }

    return new MapData(w,h, terrain, defaultTerrain);
  }

  TerrainType terrainAt(int x, int y) {
    if (x < 0 || x >= width || y < 0 || y >= height) { return defaultTerrain; }

    return data[y * width + x];
  }

  int indexAt(int x, int y) {
    return y * width + x;
  }
}