import "dart:js_interop";
import "dart:math";

import "package:web/web.dart";

import "worker/workerbase.dart";
import "worker/commands.dart";
import "logging/logger.dart";
import "map/icons.dart";
import "map/mapdata.dart";
import "map/terraintype.dart";
import "map/fillfunction.dart";
import "utility/colour.dart";

class MapWorker extends WorkerBase {
  Logger log = new Logger("Render Worker", true);

  ImageBitmap? sourceImage;
  MapData? sourceData;

  MapWorker(DedicatedWorkerGlobalScope context) : super(context);

  @override
  Future<Object?> handleCommand(String command, Object? payload) async {

    switch(command) {
      case RenderCommands.loadImages:
        return await loadImages();
      case RenderCommands.setSourceImage:
        return await setSourceImage(payload as RendererSetSourceImageMessage);
      case RenderCommands.render:
        return render(payload as RendererRenderMessage);
    }

    return null;
  }

  Object? setSourceImage(RendererSetSourceImageMessage message) async {
    log.info("Setting source image");
    sourceImage = message.image;
    sourceData = new MapData.fromBitmap(message.image, TerrainTypes.GRASSLAND, seed: message.seed);
    log.debug("Element clearance: ${sourceData!.xMin} to ${sourceData!.xMax}, ${sourceData!.yMin} to ${sourceData!.yMax}");
    return null;
  }

  ImageBitmap render(RendererRenderMessage message) {
    if (sourceData == null) { throw Exception("Map data is null"); }
    var mapData = sourceData!;

    int ox = message.x, oy = message.y;
    int w = message.width, h = message.height;
    log.info("Rendering region at $ox,$oy, $w by $h");
    var canvas = new OffscreenCanvas(w,h);
    var context = canvas.getContext("2d") as OffscreenCanvasRenderingContext2D;

    log.debug("Converting source data");
    var imgData = context.getImageData(0, 0, w, h);
    var data = imgData.data;
    var agbrData = data.toDart.buffer.asUint32List();

    log.debug("Filling base terrain array");
    for (int y=0; y<h; y++) {
      for (int x=0; x<w; x++) {
        TerrainType terrain = mapData.terrainAt(x+ox, y+oy);
        FillFunc fill = terrain.fillfunc;
        agbrData[y*w + x] = fill(x+ox,y+oy, mapData, false).to32Bit;
      }
    }

    log.debug("Drawing base terrain");
    context.putImageData(imgData, 0, 0);

    log.debug("Place objects");
    int bx1 = min(ox,-mapData.xMin);
    int bx2 = min(mapData.width - (ox + w), mapData.xMax);
    int by1 = min(oy,-mapData.yMin);
    int by2 = min(mapData.height - (oy + h), mapData.yMax);
    log.debug("Object buffer: x: $bx1, $bx2  y: $by1, $by2");

    for (int y=-by1; y<h+by2; y++) {
      for (int x=-bx1; x<w+bx2; x++) {
        TerrainType terrain = mapData.terrainAt(x+ox, y+oy);

        if (terrain.elements.isEmpty) { continue; }
        // skip this point if it's outside range for placement of this terrain type's objects
        if (x < -terrain.xMax || x > w - terrain.xMin || y < -terrain.yMax || y > h - terrain.yMin) { continue; }

        if (!terrain.placefunc(x+ox,y+oy,mapData)) { continue; }

        Random rand = new Random((y+oy) * mapData.width + (x+ox) + mapData.seed + 200);
        var element = terrain.elements[rand.nextInt(terrain.elements.length)];

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

        context.drawImage(Icons.images[element.imagename]!, spritex, spritey);
      }
    }

    log.debug("Returning finished image");
    return canvas.transferToImageBitmap();
  }

  Object? loadImages() async {
    await Icons.load(loadImage); return null;
  }

  Future<ImageBitmap> loadImage(String name) async {
    var result = await self.fetch("images/${name}.png".toJS).toDart;
    if (!result.ok) { throw Exception("Fetch failed for file: $name"); };
    return self.createImageBitmap(await result.blob().toDart).toDart..then((dynamic d) => log.debug("Loaded image: $name"));
  }
}

@JS("self")
external DedicatedWorkerGlobalScope get self;

void main() {
  new MapWorker(self);
}

