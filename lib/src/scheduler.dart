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

/// Scheduler for update tasks
///
/// TODO: add simple write queue for leaf nodes (animation mixin for comps)
class Scheduler {
  static Scheduler _instance = new Scheduler();

  ZoneSpecification _zoneSpec;
  Zone _zone;
  Queue<Function> _currentTasks = new Queue<Function>();

  /// Write groups indexed by depth
  List<WriteGroup> _writeGroups = [];
  HeapPriorityQueue<WriteGroup> _writeQueue = new HeapPriorityQueue<WriteGroup>();
  Completer _readCompleter;
  Completer _afterCompleter;

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

  Future _write(int depth) {
    _requestAnimationFrame();
    if (depth >= _writeGroups.length) {
      var i = _writeGroups.length;
      while (i <= depth) {
        _writeGroups.add(new WriteGroup(i++));
      }
    }
    final g = _writeGroups[depth];
    if (g.completer == null) {
      g.completer = new Completer();
      _writeQueue.add(g);
    }
    return g.completer.future;
  }

  Future _read() {
    _requestAnimationFrame();
    if (_readCompleter == null) {
      _readCompleter = new Completer();
    }
    return _readCompleter.future;
  }

  Future _after() {
    _requestAnimationFrame();
    if (_afterCompleter == null) {
      _afterCompleter = new Completer();
    }
    return _afterCompleter.future;
  }

  void _handleAnimationFrame(num t) {
    _rafId = 0;

    _zone.run(() {
      do {
        while (_writeQueue.isNotEmpty) {
          final writeGroup = _writeQueue.removeFirst();
          writeGroup.completer.complete();
          _runTasks();
          writeGroup.completer = null;
        }

        if (_readCompleter != null) {
          _readCompleter.complete();
          _runTasks();
          _readCompleter = null;
        }
      } while (_writeQueue.isNotEmpty);

      if (_afterCompleter != null) {
        _afterCompleter.complete();
        _runTasks();
        _afterCompleter = null;
      }
    });
  }

  static Zone get zone => _instance._zone;

  static Future write(int depth) => _instance._write(depth);
  static Future read() => _instance._read();
  static Future after() => _instance._after();

  static void forceUpdate() {
    if (_instance._rafId != 0) {
      html.window.cancelAnimationFrame(_instance._rafId);
      _instance._rafId = 0;
      _instance._handleAnimationFrame(-1);
    }
  }
}
