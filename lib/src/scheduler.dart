// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid;

/// Write groups sorted by their depth to prevent unnecessary writes when the
/// parent removes its children.
class _WriteGroup implements Comparable {
  /// Depth relative to other Contexts
  final int depth;

  Completer completer;

  _WriteGroup(this.depth);

  int compareTo(_WriteGroup other) => depth.compareTo(other.depth);
}

/// Frame tasks
class Frame {
  /// Write groups indexed by depth
  List<_WriteGroup> writeGroups = [];
  HeapPriorityQueue<_WriteGroup> writeQueue = new HeapPriorityQueue<_WriteGroup>();
  Completer readCompleter;
  Completer afterCompleter;

  /// Returns [Future] that completes when [Scheduler] launches write
  /// tasks for that [Frame]
  Future write(int depth) {
    if (depth >= writeGroups.length) {
      var i = writeGroups.length;
      while (i <= depth) {
        writeGroups.add(new _WriteGroup(i++));
      }
    }
    final g = writeGroups[depth];
    if (g.completer == null) {
      g.completer = new Completer();
      writeQueue.add(g);
    }
    return g.completer.future;
  }

  /// Returns [Future] that completes when [Scheduler] launches read
  /// tasks for that [Frame]
  Future read() {
    if (readCompleter == null) {
      readCompleter = new Completer();
    }
    return readCompleter.future;
  }

  /// Returns [Future] that completes when [Scheduler] finishes all
  /// read and write tasks for that [Frame]
  Future after() {
    if (afterCompleter == null) {
      afterCompleter = new Completer();
    }
    return afterCompleter.future;
  }
}

/// [Scheduler] runs [Frame]'s write/read tasks.
///
/// Whenever you add any task to the [nextFrame], Scheduler starts waiting
/// for the next frame with the requestAnimationFrame call and then runs all
/// tasks inside the Scheduler's [zone].
///
/// [Scheduler] runs all write tasks and microtasks that were registered
/// in its [zone], when all this tasks are finished, it starts running
/// reading tasks and microtasks, then it checks if there any write tasks
/// were added after read batch, if anything is added, it performs the loop
/// again, otherwise it runs all `after` tasks and finishes.
///
/// ```dart
/// while (writeTasks.isNotEmpty) {
///   while (writeTasks.isNotEmpty) {
///     writeTasks.removeFirst().start();
///     runMicrotasks();
///   }
///   while (readTasks.isNotEmpty) {
///     readTasks.removeFirst().start();
///     runMicrotasks();
///   }
/// }
/// while (afterTasks.isNotEmpty) {
///   afterTasks.removeFirst().start();
///   runMicrotasks();
/// }
/// ```
///
/// By executing tasks this way we can guarantee almost optimal read/write
/// batching.
///
/// TODO: add simple write queue for leaf nodes (animation mixin for comps)
class Scheduler {
  static Scheduler _instance = new Scheduler();

  bool _running = false;
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
    if (_running) {
      _currentTasks.add(f);
    } else {
      parent.scheduleMicrotask(zone, f);
    }
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
      _running = true;
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
      _running = false;
    });

  }

  /// [Scheduler]'s Zone
  static Zone get zone => _instance._zone;

  /// Current [Frame] that is executed right now, it is only possible
  /// to get current frame if the code is running inside of Scheduler
  /// execution context.
  static Frame get currentFrame => _instance.getCurrentFrame();

  /// Next [Frame].
  static Frame get nextFrame => _instance.getNextFrame();

  /// Force [Scheduler] to run tasks for the [nextFrame].
  static void forceUpdate() {
    if (_instance._rafId != 0) {
      html.window.cancelAnimationFrame(_instance._rafId);
      _instance._rafId = 0;
      _instance._handleAnimationFrame(html.window.performance.now());
    }
  }
}
