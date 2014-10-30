// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid;

abstract class ComponentBase {
  final ComponentBase parent;

  // intrusive hlist of children components
  ComponentBase _children = null;
  ComponentBase _prev = null;
  ComponentBase _next = null;

  // intrusive hlist of invalidated children
  ComponentBase _invalidatedChildren = null;
  ComponentBase _invalidatedPrev = null;
  ComponentBase _invalidatedNext = null;

  bool _isAttached = false;
  bool get isAttached => _isAttached;

  final StreamController<ComponentEvent> _onEventController =
      new StreamController<ComponentEvent>.broadcast();

  /// Events from children
  Stream<ComponentEvent> get onEvent =>
      _onEventController.stream;

  final StreamController<ComponentEvent> _onBroadcastEventController =
      new StreamController<ComponentEvent>.broadcast();

  /// Broadcasted events from parents
  Stream<ComponentEvent> get onBroadcastEvent =>
      _onBroadcastEventController.stream;

  ComponentBase([this.parent = null]);

  /// MainLoop state: DomWrite
  void _addChild(ComponentBase c) {
    assert(c._prev == null);
    assert(c._next == null);

    c._next = _children;
    if (_children != null) {
      _children._prev = c;
    }
    _children = c;
  }

  /// MainLoop state: DomWrite
  void _removeChild(ComponentBase c) {
    if (c._prev == null) {
      _children = c._next;
      c._next = null;
    } else {
      c._prev._next = c._next;
      if (c._next != null) {
        c._next._prev = c._prev;
        c._next = null;
      }
      c._prev = null;
    }
  }

  /// MainLoop state: any
  void _addInvalidatedChild(ComponentBase c) {
    assert(c._invalidatedPrev == null);
    assert(c._invalidatedNext == null);

    c._invalidatedNext = _invalidatedChildren;
    if (_invalidatedChildren != null) {
      _invalidatedChildren._invalidatedPrev = c;
    }
    _invalidatedChildren = c;
  }

  /// MainLoop state: DomWrite
  void _removeInvalidatedChild(ComponentBase c) {
    if (c._invalidatedPrev == null) {
      _invalidatedChildren = c._invalidatedNext;
      c._invalidatedNext = null;
    } else {
      c._invalidatedPrev._invalidatedNext = c._invalidatedNext;
      if (c._invalidatedNext != null) {
        c._invalidatedNext._invalidatedPrev = c._invalidatedPrev;
        c._invalidatedNext = null;
      }
      c._invalidatedPrev = null;
    }
  }

  /// Update dirty Components
  ///
  /// MainLoop state: DomWrite
  void update() {
    var c = _invalidatedChildren;
    while (c != null) {
      final next = c._invalidatedNext;
      c.update();
      c._invalidatedPrev = null;
      c._invalidatedNext = null;
      c = next;
    }
    _invalidatedChildren = null;
  }

  /// Invoked when the Component is attached to the Document
  ///
  /// MainLoop state: DomWrite
  void attached() {
    assert(_isAttached == false);

    var c = _children;
    while (c != null) {
      c.attached();
      c = c._next;
    }

    _isAttached = true;
  }

  /// Invoked when the Component is detached from the Document
  ///
  /// MainLoop state: DomWrite
  void detached() {
    assert(_isAttached == true);

    var c = _children;
    while (c != null) {
      c.detached();
      c = c._next;
    }
  }

  /// Broadcast event to children
  void broadcast(ComponentEvent e) {
    var c = _children;
    while (c != null) {
      c._onBroadcastEventController.add(e);
      c = c._next;
    }
  }
}
