// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid;

/// Callback groups that sorted by their depth to prevent
/// unnecessary writes, when the parent removes its children.
class WriteGroup implements Comparable {
  final int depth;
  final List callbacks = [];
  WriteGroup(this.depth);

  int compareTo(WriteGroup other) => depth.compareTo(other.depth);
}

/// UpdateLoop is used to perform batched read and writes to the DOM.
///
/// The algorithm is quite simple:
///
/// ```
/// while (_writePriorityQueue.isNotEmpty) {
///   while (_writePriorityQueue.isNotEmpty) {
///     runWriteTask(_writePriorityQueue.removeFirst());
///   }
///   while (_readQueue.isNotEmpty) {
///     runReadTask(_readQueue.removeFirst());
///   }
/// }
/// while (_animationQueue.isNotEmpty) {
///   runAnimationTask(_animationQueue.removeFirst());
/// }
/// ```
///
/// It is implented in a slightly different way just to make it more
/// efficient.
///
/// TODO: integrate Dart Zones
/// TODO: add simple write queue for leaf nodes (animation mixin for comp?)
class UpdateLoop {
  static UpdateLoop _instance = new UpdateLoop();

  /// Write groups indexed by depth
  List<WriteGroup> _writeGroups = [];
  HeapPriorityQueue<WriteGroup> _writeQueue = new HeapPriorityQueue<WriteGroup>();

  List<Function> _readQueue = [];
  List<Function> _afterQueue = [];

  /// RAF id
  int _id = 0;

  /// TODO: just use scheduleMicroTask
  static void after(Function fn) {
    _instance._afterQueue.add(fn);
    _instance._requestAnimationFrame();
  }

  /// Add callback to the Read Queue
  static void read(Function fn) {
    _instance._readQueue.add(fn);
    _instance._requestAnimationFrame();
  }

  /// Add callback to the Write Queue
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

    while (_writeQueue.isNotEmpty) {
      while (_writeQueue.isNotEmpty) {
        final group = _writeQueue.first;
        final fn = group.callbacks.removeLast();
        if (group.callbacks.isEmpty) {
          _writeQueue.removeFirst();
        }
        fn();
      }
      while (_readQueue.isNotEmpty) {
        final rq = _readQueue;
        _readQueue = [];
        for (var i = 0; i < rq.length; i++) {
          rq[i]();
        }
      }
    }
    for (var i = 0; i < _afterQueue.length; i++) {
      _afterQueue[i]();
    }
    _afterQueue = [];
  }

  static void forceUpdate() {
    if (_instance._id != 0) {
      html.window.cancelAnimationFrame(_instance._id);
      _instance._id = 0;
      _instance._handleAnimationFrame(-1);
    }
  }
}