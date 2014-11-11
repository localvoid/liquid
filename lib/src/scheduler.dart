// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid;

/// Write groups sorted by their depth to prevent unnecessary writes when the
/// parent removes its children.
class WriteGroup implements Comparable {
  /// Components depth
  final int depth;
  Completer completer;

  WriteGroup(this.depth);

  int compareTo(WriteGroup other) => depth.compareTo(other.depth);
}

class Frame {
  /// Write groups indexed by depth
  List<WriteGroup> writeGroups = [];
  HeapPriorityQueue<WriteGroup> writeQueue = new HeapPriorityQueue<WriteGroup>();
  Completer readCompleter;
  Completer afterCompleter;

  Future write(int depth) {
    if (depth >= writeGroups.length) {
      var i = writeGroups.length;
      while (i <= depth) {
        writeGroups.add(new WriteGroup(i++));
      }
    }
    final g = writeGroups[depth];
    if (g.completer == null) {
      g.completer = new Completer();
      writeQueue.add(g);
    }
    return g.completer.future;
  }

  Future read() {
    if (readCompleter == null) {
      readCompleter = new Completer();
    }
    return readCompleter.future;
  }

  Future after() {
    if (afterCompleter == null) {
      afterCompleter = new Completer();
    }
    return afterCompleter.future;
  }
}

/// Scheduler for update tasks
///
/// TODO: add simple write queue for leaf nodes (animation mixin for comps)
class Scheduler {
  static Scheduler _instance = new Scheduler();

  ZoneSpecification _zoneSpec;
  Zone _zone;
  Queue<Function> _currentTasks = new Queue<Function>();

  Frame _currentFrame;
  Frame getCurrentFrame() {
    assert(_currentFrame != null);
    return _currentFrame;
  }

  Frame _nextFrame;
  Frame getNextFrame() {
    if (_nextFrame == null) {
      _nextFrame = new Frame();
      _requestAnimationFrame();
    }
    return _nextFrame;
  }

  int _rafId = 0;

  Scheduler() {
    _zoneSpec = new ZoneSpecification(scheduleMicrotask: _scheduleMicrotask);
    _zone = Zone.current.fork(specification: _zoneSpec);
  }

  void _scheduleMicrotask(Zone self, ZoneDelegate parent, Zone zone, void f()) {
    _currentTasks.add(f);
  }

  void _runTasks() {
    while (_currentTasks.isNotEmpty) {
      _currentTasks.removeFirst()();
    }
  }

  void _requestAnimationFrame() {
    if (_rafId == 0) {
      _rafId = html.window.requestAnimationFrame(_handleAnimationFrame);
    }
  }

  void _handleAnimationFrame(num t) {
    _rafId = 0;

    _zone.run(() {
      _currentFrame = _nextFrame;
      _nextFrame = null;
      final wq = _currentFrame.writeQueue;

      do {
        while (wq.isNotEmpty) {
          final writeGroup = wq.removeFirst();
          writeGroup.completer.complete();
          _runTasks();
          writeGroup.completer = null;
        }

        if (_currentFrame.readCompleter != null) {
          _currentFrame.readCompleter.complete();
          _runTasks();
          _currentFrame.readCompleter = null;
        }
      } while (wq.isNotEmpty);

      if (_currentFrame.afterCompleter != null) {
        _currentFrame.afterCompleter.complete();
        _runTasks();
        _currentFrame.afterCompleter = null;
      }
    });
  }

  static Zone get zone => _instance._zone;

  static Frame get currentFrame => _instance.getCurrentFrame();
  static Frame get nextFrame => _instance.getNextFrame();

  static void forceUpdate() {
    if (_instance._rafId != 0) {
      html.window.cancelAnimationFrame(_instance._rafId);
      _instance._rafId = 0;
      _instance._handleAnimationFrame(html.window.performance.now());
    }
  }
}
