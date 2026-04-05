import 'dart:js_interop';
import 'package:web/web.dart';

abstract class RenderCommands {
  static const String loadImages = "load";
  static const String setSourceImage = "source";
  static const String render = "render";
}

@JS()
@staticInterop
@anonymous
extension type RendererSetSourceImageMessage._(JSObject _) implements JSObject {
  external factory RendererSetSourceImageMessage({required ImageBitmap image, required int seed});
  external ImageBitmap get image;
  external int get seed;
}

@JS()
@staticInterop
@anonymous
extension type RendererRenderMessage._(JSObject _) implements JSObject {
  external factory RendererRenderMessage({required int x, required int y, required int width, required int height});
  external int get x;
  external int get y;
  external int get width;
  external int get height;
}