library parchmentmap;

import 'package:web/web.dart';
import 'dart:js_interop';

import "logging/logger.dart";
import "utility/extensions.dart";

import "worker/workerhandler.dart";
import "worker/commands.dart";

final Logger log = new Logger("Main", true);

late final HTMLCanvasElement canvas;
late final CanvasRenderingContext2D ctx;

late final HTMLInputElement renderButton;
late final HTMLInputElement seedInput;
late final HTMLInputElement imageInput;

late final WorkerHandler renderer;
bool rendering = false;
const int regionSize = 500;

void main() async {
  canvas = document.querySelector("#canvas")! as HTMLCanvasElement;
  ctx = canvas.context2D;

  renderButton = document.querySelector("#renderButton")! as HTMLInputElement..addEventListener("click", (Event e) {
    if (rendering) { return; }
    rendering = true;
    render()..then((Null _) { rendering = false; });
  }.toJS);
  seedInput = document.querySelector("#seedInput")! as HTMLInputElement..addEventListener("change", (Event e) {
    updateRenderButton();
  }.toJS);
  imageInput = document.querySelector("#imageInput")! as HTMLInputElement..addEventListener("change", (Event e) {
    updateRenderButton();
  }.toJS);

  // set up worker
  renderer = createWebWorker("renderer.worker.dart", poolSize: 8);
  await renderer.sendCommandToAll(RenderCommands.loadImages);

  imageInput.disabled = false;
  seedInput.disabled = false;
}

void updateRenderButton() {
  if (imageInput.files != null && imageInput.files!.length > 0 && seedInput.willValidate) {
    renderButton.disabled = false;
  }
  else {
    renderButton.disabled = true;
  }
}

Future<Null> render() async {
  // get the input
  //var response = await window.fetch("images/maptest.png".toJS).toDart;
  //var bitmap = await window.createImageBitmap(await response.blob().toDart).toDart;

  if (imageInput.files!.length < 1) { return; }

  ImageBitmap bitmap;
  int seed;
  try {
    File imageFile = imageInput.files![0];
    bitmap = await window.createImageBitmap(imageFile).toDart;
    seed = seedInput.valueAsNumber.toInt();
  }
  catch (error) {
    return;
  }

  // resize canvas
  canvas..width = bitmap.width..height = bitmap.height;

  var startTime = DateTime.now();

  // set renderer input and seed
  log.debug("Image: $bitmap");
  var message = new RendererSetSourceImageMessage(image: bitmap, seed: seed);
  log.debug(message.image);
  await renderer.sendCommandToAll(RenderCommands.setSourceImage, payload: message);

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
  return (int x, int y, int w, int h) {
    int fx = x.clamp(0, width-1), fy = y.clamp(0, height-1);
    int fw = (w+(x-fx)).clamp(0, width-fx), fh = (h+(y-fy)).clamp(0, height-fy);

    canvas.context2D..fillStyle="black".toJS..fillRect(fx,fy,fw,fh);

    return renderer.sendCommand(RenderCommands.render, payload: RendererRenderMessage(x: fx, y: fy, width: fw, height: fh))
      .then((dynamic payload) {
        log.debug("returned tile at $fx,$fy");
        ctx.drawImage(payload as ImageBitmap, fx,fy, fw,fh); }
      );
  };
}

