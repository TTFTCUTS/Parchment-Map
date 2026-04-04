import "dart:async";
import "dart:js_interop";
import "package:web/web.dart";

import "../utility/path_utils.dart";

/// Provides an interface for a web worker with a main class based on WorkerBase
/// Instantiate a worker and handler with createWebWorker
class WorkerHandler {
    Worker? _worker;
    StreamController<Event> _errorController = new StreamController();
    late Stream<Event> onError = _errorController.stream;

    final Map<int, Completer<dynamic>> _pending = <int, Completer<dynamic>>{};
    int _commandId = 0;

    WorkerHandler._(Worker this._worker) {
        _worker!.addEventListener("error", (Event e) { _errorController.add(e); }.toJS);
        _worker!.addEventListener("message", _handleMessage.toJS);
    }

    void _handleMessage(MessageEvent event) {
        final WorkerReply reply = event.data as WorkerReply;
        if (reply.id != null) {
            final int id = reply.id!;

            if (_pending.containsKey(id)) {
                final Completer<dynamic> completer = _pending[id]!;

                if (reply.error != null) {
                    completer.completeError(new WorkerException(reply.error!), new StackTrace.fromString(reply.trace!));
                } else {
                    completer.complete(reply.payload);
                }
                _pending.remove(id);
            }
        }
    }

    Future<T?> sendCommand<T>(String command, {Object? payload, bool expectReply = true}) async {
        if (_worker == null) {
            throw new WorkerException("Worker is null");
        }

        late Completer<T> completer;

        int? id = null;
        if (expectReply) {
            completer = new Completer<T>();
            final int nextId = _commandId;
            _commandId++;

            _pending[nextId] = completer;
            id = nextId;
        }

        _worker?.postMessage(new WorkerMessage(command: command, id: id, payload: payload != null ? payload.toExternalReference : null));

        if (expectReply) { return completer.future; }

        return null;
    }

    void sendInstantCommand(String command, [dynamic payload]) => sendCommand(command, payload: payload, expectReply: false);

    void destroyWorker() {
        if (_worker == null) {
            throw new WorkerException("Worker is null");
        }
        _worker?.terminate();
        _worker = null;

        for (final Completer<dynamic> completer in _pending.values) {
            completer.completeError(new WorkerException("Worker was terminated"));
        }
    }
}

/// Path should be the file name of the dart worker file
WorkerHandler createWebWorker(String path) {
    final Worker worker = new Worker("${PathUtils.resolve(path)}.js".toJS);

    return new WorkerHandler._(worker);
}

class WorkerException implements Exception {
    String message;
    WorkerException(String this.message);

    @override
    String toString() => "WorkerException: $message";
}

@JS()
@staticInterop
@anonymous
extension type WorkerMessage._(JSObject _) implements JSObject {
  external factory WorkerMessage({required String command, int? id, ExternalDartReference? payload});
  external String get command;
  external int? get id;
  external ExternalDartReference? get payload;
}

@JS()
@staticInterop
@anonymous
extension type WorkerReply._(JSObject _) implements JSObject {
  external factory WorkerReply({ExternalDartReference? payload, int? id, String? error, String? trace});
  external ExternalDartReference? get payload;
  external int? get id;
  external String? get error;
  external String? get trace;
}