extension ListMult<T> on List<T> {
  operator *(int other) {
    return this.repeat(other);
  }

  List<T> repeat(int count) {
    List<T> out = <T>[];
    for (int i=0; i<count; i++) {
      out.addAll(this);
    }
    return out;
  }
}

extension MapGenerator<T,U> on Map<T,U> {
  Future<void> generateAsync(Iterable<T> source, Future<U> Function(T input) generator) async {
    var results = await Future.wait(source.map((T item) async => (item, await generator(item))));
    this.addEntries(results.map(((T, U) pair)  => MapEntry(pair.$1, pair.$2)));
  }
}