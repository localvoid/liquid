part of liquid;

///
/// loop {
///   void readDOM() {}
///   void writeDOM() {}
///
///   _update() {
///     if (isDirty) {
///       if (_readDOMFlag) {
///         _readDOMQueue.add(this);
///         return;
///       } else {
///         writeDOM();
///       }
///     }
///     _updateChildren();
///   }
///
///   _updateFinish() {
///     writeDOM();
///     _updateChildren();
///   }
///
///   _updateChildren() {
///     for (final c in children) {
///       c._update();
///     }
///   }
/// }
///
/// TODO: REFACTOR ALL THIS MESS!
class UpdateLoop {
  /// List of invalidated root components
  List<ComponentBase> _invalidatedRoots = [];

  /// readDOM queue
  List<ComponentBase> _readDOMQueue = [];

  /// RAF id
  int _id = 0;

  void addInvalidatedRoot(ComponentBase c) {
    if (_id == 0) {
      _id = html.window.requestAnimationFrame(_handleAnimationFrame);
    }
    _invalidatedRoots.add(c);
  }

  void _handleAnimationFrame(num t) {
    _id = 0;

    for (var i = 0; i < _invalidatedRoots.length; i++) {
      _invalidatedRoots[i]._update();
    }
    _invalidatedRoots = [];

    while (_readDOMQueue.isNotEmpty) {
      final queue = _readDOMQueue;
      _readDOMQueue = [];

      for (var i = 0; i < queue.length; i++) {
        queue[i].readDOM();
      }
      for (var i = 0; i < queue.length; i++) {
        queue[i]._updateFinish();
      }
    }
  }

  void forceUpdate() {
    if (_id != 0) {
      html.window.cancelAnimationFrame(_id);
      _id = 0;
      _handleAnimationFrame(0);
    }
  }
}

final _updateLoop = new UpdateLoop();

void addInvalidatedRoot(ComponentBase c) {
  _updateLoop.addInvalidatedRoot(c);
}

void addReadDOM(ComponentBase c) {
  _updateLoop._readDOMQueue.add(c);
}

void forceUpdate() {
  _updateLoop.forceUpdate();
}