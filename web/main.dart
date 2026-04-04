library parchmentmap;

import 'package:web/web.dart';
import 'dart:js_interop';

import "worker/workerhandler.dart";
import "worker/commands.dart";

late HTMLCanvasElement canvas;
late CanvasRenderingContext2D ctx;

Future<void> main() async {
  canvas = document.querySelector("#canvas")! as HTMLCanvasElement;
  ctx = canvas.context2D;

  // set up worker
  WorkerHandler renderer = createWebWorker("renderer.worker.dart");
  await renderer.sendCommand(RenderCommands.loadImages);

  // get the input
  var response = await window.fetch("images/maptest.png".toJS).toDart;
  var bitmap = await window.createImageBitmap(await response.blob().toDart).toDart;

  // render output
  ImageBitmap rendered = await renderer.sendCommand(RenderCommands.render, payload: bitmap);
  ctx.drawImage(rendered, 0, 0);
}
