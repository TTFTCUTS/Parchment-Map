library parchmentmap;

import 'package:web/web.dart';
import 'dart:js_interop';

import "logging/logger.dart";

import "worker/workerhandler.dart";
import "worker/commands.dart";

late HTMLCanvasElement canvas;
late CanvasRenderingContext2D ctx;

const int regionSize = 500;

void main() async {
  Logger log = new Logger("Main", true);
  canvas = document.querySelector("#canvas")! as HTMLCanvasElement;
  ctx = canvas.context2D;

  // set up worker
  WorkerHandler renderer = createWebWorker("renderer.worker.dart");
  await renderer.sendCommand(RenderCommands.loadImages);

  // get the input
  var response = await window.fetch("images/maptest.png".toJS).toDart;
  var bitmap = await window.createImageBitmap(await response.blob().toDart).toDart;

  var startTime = DateTime.now();

  // set renderer input and seed
  await renderer.sendCommand(RenderCommands.setSourceImage, payload: RendererSetSourceImageMessage(image: bitmap, seed: 0));

  // make region render function
  var renderRegion = makeRegionRenderer(canvas, renderer, bitmap.width, bitmap.height);

  var renderStartTime = DateTime.now();
  log.info("Input processed after ${renderStartTime.millisecondsSinceEpoch - startTime.millisecondsSinceEpoch}ms");

  // render regions
  int xRegions = (bitmap.width / regionSize).ceil();
  int yRegions = (bitmap.height / regionSize).ceil();
  List<Future<Null>> regions = [];
  for (int y=0; y<yRegions; y++) {
    for (int x=0; x<xRegions; x++) {
      regions.add(renderRegion(x * regionSize, y * regionSize, regionSize, regionSize));
    }
  }
  await Future.wait(regions);

  var finishedTime = DateTime.now();
  log.info("Render finished after ${finishedTime.millisecondsSinceEpoch - renderStartTime.millisecondsSinceEpoch}ms");
  log.info("Finished after ${finishedTime.millisecondsSinceEpoch - startTime.millisecondsSinceEpoch}ms");
}

Future<Null> Function(int,int,int,int) makeRegionRenderer(HTMLCanvasElement canvas, WorkerHandler renderer, int width, int height) {
  return (int x, int y, int w, int h) async {
    int fx = x.clamp(0, width-1), fy = y.clamp(0, height-1);
    int fw = (w+(x-fx)).clamp(0, width-fx), fh = (h+(y-fy)).clamp(0, height-fy);

    canvas.context2D..fillStyle="black".toJS..fillRect(fx,fy,fw,fh);

    await renderer.sendCommand(RenderCommands.render, payload: RendererRenderMessage(x: fx, y: fy, width: fw, height: fh))
        .then((dynamic payload) { ctx.drawImage(payload as ImageBitmap, fx,fy, fw,fh); });
  };
}

