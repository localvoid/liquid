part of liquid;

class WriteGroup implements Comparable {
  final int depth;
  final List<Function> callbacks = [];
  WriteGroup(this.depth);

  int compareTo(WriteGroup other) => depth.compareTo(other.depth);
}

class UpdateLoop {
  static UpdateLoop _instance = new UpdateLoop();

  /// Write groups indexed by depth
  List<WriteGroup> _writeGroups = [];
  HeapPriorityQueue<WriteGroup> _writeQueue = new HeapPriorityQueue<WriteGroup>();

  List<Function> _readQueue = [];

  /// RAF id
  int _id = 0;

  static void read(Function fn) {
    _instance._readQueue.add(fn);
    _instance._requestAnimationFrame();
  }

  static void write(int depth, Function fn) {
    final g = _instance.getWriteGroup(depth);
    if (g.callbacks.isEmpty) {
      _instance._writeQueue.add(g);
    }
    g.callbacks.add(fn);
    _instance._requestAnimationFrame();
  }

  void _requestAnimationFrame() {
    if (_id == 0) {
      _id = html.window.requestAnimationFrame(_handleAnimationFrame);
    }
  }

  WriteGroup getWriteGroup(int depth) {
    if (depth >= _writeGroups.length) {
      var i = _writeGroups.length;
      while (i <= depth) {
        _writeGroups.add(new WriteGroup(i++));
      }
    }
    return _writeGroups[depth];
  }

  void _handleAnimationFrame(num t) {
    _id = 0;

    /// Yeah, that is how batching should properly work :)
    while (_writeQueue.isNotEmpty) {
      while (_writeQueue.isNotEmpty) {
        final group = _writeQueue.first;
        final fn = group.callbacks.removeLast();
        if (group.callbacks.isEmpty) {
          _writeQueue.removeFirst();
        }
        fn();

        while (_readQueue.isNotEmpty) {
          final rq = _readQueue;
          _readQueue = [];
          for (var i = 0; i < rq.length; i++) {
            rq[i]();
          }
        }
      }
    }
  }

  static void forceUpdate() {
    if (_instance._id != 0) {
      html.window.cancelAnimationFrame(_instance._id);
      _instance._id = 0;
      _instance._handleAnimationFrame(-1);
    }
  }
}