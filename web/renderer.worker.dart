import "dart:js_interop";

import "package:web/web.dart";

import "worker/workerbase.dart";
import "worker/commands.dart";
import "logging/logger.dart";
import "map/icons.dart";
import "map/mapdata.dart";
import "map/terraintype.dart";
import "map/fillfunction.dart";

class MapWorker extends WorkerBase {
  Logger log = new Logger("Render Worker", true);

  MapWorker(DedicatedWorkerGlobalScope context) : super(context);

  @override
  Future<Object?> handleCommand(String command, Object? payload) async {

    switch(command) {
      case RenderCommands.loadImages:
        return await loadImages();
      case RenderCommands.render:
        return render(payload as ImageBitmap);
    }

    return null;
  }

  ImageBitmap render(ImageBitmap source) {
    int w = source.width, h = source.height;
    var canvas = new OffscreenCanvas(w,h);
    var context = canvas.getContext("2d") as OffscreenCanvasRenderingContext2D;

    log.debug("Getting source data");
    var mapData = MapData.fromBitmap(source, TerrainTypes.GRASSLAND);

    log.debug("Converting source data");
    var imgData = context.getImageData(0, 0, w, h);
    var data = imgData.data;
    var agbrData = data.toDart.buffer.asUint32List();

    log.debug("Filling");
    for (int y=0; y<h; y++) {
      for (int x=0; x<w; x++) {
        TerrainType terrain = mapData.terrainAt(x, y);
        FillFunc fill = terrain.fillfunc == null ? FillFunctions.DEFAULT_FILL : terrain.fillfunc!;
        agbrData[y*w + x] = fill(x,y, mapData, false).to32Bit;
      }
    }

    log.debug("Drawing");
    context.putImageData(imgData, 0, 0);

    log.debug("Returning finished image");
    return canvas.transferToImageBitmap();
  }

  Object? loadImages() async {
    await Icons.load(loadImage); return null;
  }

  Future<ImageBitmap> loadImage(String name) async {
    var result = await self.fetch(name.toJS).toDart;
    if (!result.ok) { throw Exception("Fetch failed for file: $name"); };
    return self.createImageBitmap(await result.blob().toDart).toDart..then((dynamic d) => print("Loaded image: $name"));
  }
}

@JS("self")
external DedicatedWorkerGlobalScope get self;

void main() {
  new MapWorker(self);
}

