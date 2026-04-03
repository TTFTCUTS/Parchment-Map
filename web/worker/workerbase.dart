import "dart:js_interop";

import "package:web/web.dart";

import "workerhandler.dart";

/// Base class for web worker main classes
/// Extend this in the worker to automatically handle handshake and message passing
abstract class WorkerBase {
  final DedicatedWorkerGlobalScope workerContext;

  WorkerBase(DedicatedWorkerGlobalScope this.workerContext) {
    workerContext.onmessage = (MessageEvent event) {
      WorkerMessage data = event.data as WorkerMessage;
      _handleMessage(data);
    }.toJS;
  }

  Future<void> _handleMessage(WorkerMessage message) async {
    final Object? payload = message.payload?.toDartObject;
    final String command = message.command;

    if (message.id != null) {
      final int id = message.id!;

      Object? processedPayload;
      dynamic error;
      dynamic trace;

      try {
        processedPayload = await handleCommand(command, payload);
      }
      // ignore: avoid_catches_without_on_clauses
      catch (e, t) {
        error = e;
        trace = t;
      }

      WorkerReply? reply = null;
      if (error != null) {
        reply = new WorkerReply(id:id, error: error.toString(), trace: trace.toString());
      } else if (processedPayload != null) {
        reply = new WorkerReply(id:id, payload: processedPayload.toExternalReference);
      }

      workerContext.postMessage(reply == null ? new WorkerReply(id: id) : reply);
    } else {
      handleCommand(command, payload);
    }
  }

  Future<Object?> handleCommand(String command, Object? payload);
}
