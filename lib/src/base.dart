// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid;

abstract class ComponentBase {
  static const renderedFlag = 1;
  static const attachedFlag = 1 << 1;
  static const readDOMFlag  = 1 << 2;
  static const cleanFlag    = 1 << 3;

  final ComponentBase parent;
  final Object key;
  final Symbol className;
  int _flags;

  // intrusive hlist of children components
  ComponentBase _children = null;
  ComponentBase _prev = null;
  ComponentBase _next = null;

  // intrusive hlist of invalidated children
  ComponentBase _invalidatedChildren = null;
  ComponentBase _invalidatedPrev = null;
  ComponentBase _invalidatedNext = null;

  bool get isAttached => (_flags & attachedFlag) == attachedFlag;
  bool get isRendered => (_flags & renderedFlag) == renderedFlag;
  bool get shouldReadDOM => (_flags & readDOMFlag) == readDOMFlag;
  bool get isDirty => (_flags & cleanFlag) != cleanFlag;

  set isRendered(bool v) {
    if (v) {
      _flags |= renderedFlag;
    } else {
      _flags &= ~renderedFlag;
    }
  }

  ComponentBase({this.parent: null, this.key: null, this.className: null, int flags: 0})
      : _flags = flags;

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
  void _update() {
    _updateChildren();
  }

  void _updateChildren() {
    var c = _invalidatedChildren;
    while (c != null) {
      final next = c._invalidatedNext;
      c._update();
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
    assert(!isAttached);

    var c = _children;
    while (c != null) {
      c.attached();
      c = c._next;
    }

    _flags |= attachedFlag;
  }

  /// Invoked when the Component is detached from the Document
  ///
  /// MainLoop state: DomWrite
  void detached() {
    assert(isAttached);

    var c = _children;
    while (c != null) {
      c.detached();
      c = c._next;
    }

    _flags &= ~attachedFlag;
  }

  void onEvent(ComponentEvent e) {}
  void onBroadcastEvent(ComponentEvent e) {}

  /// Broadcast event to children
  void broadcast(ComponentEvent e, [Symbol selector]) {
    var c = _children;
    while (c != null) {
      if (selector == null || c.className == selector) {
        c.onBroadcastEvent(e);
        c = c._next;
      }
    }
  }
}
