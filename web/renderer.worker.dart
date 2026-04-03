import "dart:js_interop";

import "package:web/web.dart";

import "worker/workerbase.dart";


class MapWorker extends WorkerBase {
  MapWorker(DedicatedWorkerGlobalScope context) : super(context);

  @override
  Future<Object?> handleCommand(String command, Object? payload) async {
    return "hello from worker: $payload";
  }

}

@JS("self")
external DedicatedWorkerGlobalScope get self;

void main() {
  new MapWorker(self);
}