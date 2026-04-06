import "dart:async";
import "dart:collection";
import "dart:js_interop";
import "package:web/web.dart";

import "../utility/path_utils.dart";
import "../logging/logger.dart";

/// Provides an interface for a web worker with a main class based on WorkerBase
/// Instantiate a worker and handler with createWebWorker
class WorkerHandler {
  final Logger log = new Logger("Worker Handler", true);

  final List<Worker> _workers;
  final Queue<Worker> _idleWorkers = new Queue();
  final Queue<WorkerJob> _jobQueue = new Queue();
  final Map<Worker, WorkerJob<dynamic,dynamic>> _pendingWorkers = {};

  final StreamController<Event> _errorController = new StreamController();
  late final Stream<Event> onError = _errorController.stream;

  WorkerHandler._(List<Worker> this._workers) {
    for (Worker worker in _workers) {
      worker.addEventListener("error", (Event e) { _errorController.add(e); }.toJS);
      worker.addEventListener("message", (MessageEvent event) { return _handleMessage(worker, event); }.toJS);
    }

    _idleWorkers.addAll(_workers);
  }

  void _handleMessage(Worker worker, MessageEvent event) {
      final WorkerReply reply = event.data as WorkerReply;

      if (!_pendingWorkers.containsKey(worker)) { throw Exception("No pending job for returning worker"); }
      WorkerJob job = _pendingWorkers.remove(worker)!;

      if (job.completer != null) {
        if (reply.error != null) {
          job.completer!.completeError(new WorkerException(reply.error!), StackTrace.fromString(reply.trace!));
        } else {
          job.completer!.complete(reply.payload?.toDartObject);
        }
      }

      if (_jobQueue.isNotEmpty) {
        _sendWorkerMessage(worker, _jobQueue.removeFirst());
      }
      else {
        _idleWorkers.add(worker);
      }
  }

  Future<U?> sendCommand<T,U>(String command, {T? payload, bool expectReply = true}) async {
    WorkerJob<T,U> job = new WorkerJob(command, payload, expectReply ? new Completer<U>() : null );

    if (_idleWorkers.length > 0) {
      Worker worker = _idleWorkers.removeFirst();
      _sendWorkerMessage(worker, job);
    } else {
      log.debug("Adding job to queue: $job");
      _jobQueue.add(job);
    }

    if (expectReply) { return job.completer!.future; }

    return null;
  }

  void sendInstantCommand(String command, [dynamic payload]) => sendCommand(command, payload: payload, expectReply: false);

  Future<List<U?>?> sendCommandToAll<T,U>(String command, {T? payload, bool expectReply = true}) async {
    if (_pendingWorkers.isNotEmpty) { throw Exception("All workers must be idle to send command to all"); }
    List<Future<U?>> commands = [];
    for (Worker worker in _workers) {
      WorkerJob<T,U> job = new WorkerJob(command, payload, new Completer<U>() );
      commands.add(job.completer!.future);
      _idleWorkers.remove(worker);
      _sendWorkerMessage(worker, job);
    }
    if (expectReply) {
      return Future.wait(commands);
    }
    return null;
  }

  void sendInstantCommandToAll(String command, [dynamic payload]) => sendCommandToAll(command, payload: payload, expectReply: false);

  void _sendWorkerMessage(Worker worker, WorkerJob job) {
    log.debug("Sending job to worker: $job");
    var payload = job.payload != null ? (job.payload as Object).toExternalReference : null;
    _pendingWorkers[worker] = job;
    WorkerMessage message = new WorkerMessage(command: job.command, payload: payload);
    worker.postMessage(message);
  }

  void destroyWorker() {
      for (Worker worker in _workers) {
        worker.terminate();
        if (_pendingWorkers.containsKey(worker)) {
          _pendingWorkers[worker]!.completer?.completeError(new WorkerException("Worker was terminated"));
        }
      }
      _workers.clear();
      _pendingWorkers.clear();
  }
}

/// Path should be the file name of the dart worker file
WorkerHandler createWebWorker(String path, {int poolSize = 1}) {
  if (poolSize <= 0) { throw ArgumentError("Worker pool size cannot be less than 1"); }
  var jsPath = "${PathUtils.resolve(path)}.js".toJS;

  List<Worker> workers = [];
  for (int i=0; i<poolSize; i++) {
    workers.add(new Worker(jsPath));
  }

  return new WorkerHandler._(workers);
}

class WorkerException implements Exception {
    String message;
    WorkerException(String this.message);

    @override
    String toString() => "WorkerException: $message";
}

class WorkerJob<T,U> {
  final String command;
  final Completer<U>? completer;
  final T? payload;
  WorkerJob(String this.command, T? this.payload, [Completer<U>? this.completer]);

  @override
  String toString() {
    return "(Command: $command, Payload: ${payload.runtimeType}, Expects reply: ${completer != null})";
  }
}

@JS()
@staticInterop
@anonymous
extension type WorkerMessage._(JSObject _) implements JSObject {
  external factory WorkerMessage({required String command, ExternalDartReference? payload});
  external String get command;
  external ExternalDartReference? get payload;
}

@JS()
@staticInterop
@anonymous
extension type WorkerReply._(JSObject _) implements JSObject {
  external factory WorkerReply({ExternalDartReference? payload, String? error, String? trace});
  external ExternalDartReference? get payload;
  external String? get error;
  external String? get trace;
}